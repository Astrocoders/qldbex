defmodule Qldbex do
  @moduledoc false
  alias Qldbex.Session
  alias Qldbex.Native

  defp prepare_request!(ledger_name) do
    {:ok, %{"StartSession" => %{"SessionToken" => session_token}}} =
      Session.start_session(ledger_name)
      |> ExAws.request()

    {:ok, %{"StartTransaction" => %{"TransactionId" => transaction_id}}} =
      Session.start_transaction(session_token) |> ExAws.request()

    {session_token, transaction_id}
  end

  defp send_command!(statement, parameters, ledger_name) do
    {session_token, transaction_id} = prepare_request!(ledger_name)

    {:ok, %{"ExecuteStatement" => %{"FirstPage" => %{"Values" => values}}}} =
      Session.execute_statement(session_token, transaction_id, statement, parameters)
      |> ExAws.request()

    {values, session_token, transaction_id}
  end

  defp process_command_response!(response) do
    Enum.map(response, fn %{"IonBinary" => item} ->
      Native.from_ion(item)
    end)
  end

  defp base_query(table_name) do
    "SELECT id, t.* FROM #{table_name} as t by id"
  end

  defp build_returning_insert(table_name, items) do
    condition = Enum.map_join(items, " OR ", &"id = '#{&1}'")

    "#{base_query(table_name)} WHERE #{condition}"
  end

  defp cast_value(value) when is_list(value) do
    "#{Enum.map(value, &cast_value/1)}"
  end

  defp cast_value(value) when is_map(value) do
    "#{transform_map(value)}"
  end

  defp cast_value(value) when is_integer(value) do
    "#{value}"
  end

  defp cast_value(value) when is_float(value) do
    "#{value}"
  end

  defp cast_value(value) do
    "'#{value}'"
  end

  defp transform_map(item_map) do
    pairs = Map.keys(item_map) |> Enum.map(&{Atom.to_string(&1), item_map[&1]})

    pairs_mapped =
      Enum.map(pairs, fn {k, v} -> "'#{k}': #{cast_value(v)}" end)
      |> Enum.join(",")

    "{ " <> pairs_mapped <> " }"
  end

  defp get_ledger_name!() do
    ledger_name = Application.get_env(:qldbex, :ledger_name, "")

    if String.length(ledger_name) == 0 do
      raise "Missing ledger name"
    end

    ledger_name
  end

  def request!(statement, parameters \\ []) do
    ledger_name = get_ledger_name!()

    {response, session_token, _} = send_command!(statement, parameters, ledger_name)

    _ = Session.end_session(session_token)

    process_command_response!(response)
  end

  def request_mutation!(table_name, statement, parameters \\ []) do
    ledger_name = get_ledger_name!()

    {response, session_token, transaction_id} = send_command!(statement, parameters, ledger_name)

    response_processed = process_command_response!(response)

    _ =
      Session.commit_transaction(session_token, transaction_id, statement, parameters)
      |> ExAws.request()

    _ = Session.end_session(session_token)

    ids =
      Enum.map(response_processed, &Poison.decode/1)
      |> Enum.map(fn {:ok, %{"documentId" => id}} -> id end)

    returning_query = build_returning_insert(table_name, ids)

    request!(returning_query) |> Enum.map(&Poison.decode!/1)
  end

  def create_table!(table_name) do
    request!("CREATE TABLE #{table_name}")
  end

  def sum_by_field!(table_name, field, clause) do
    [response] =
      request!("SELECT SUM(\"#{field}\") as total FROM #{table_name} as t WHERE #{clause}")

    %{"total" => total} = Poison.decode!(response)

    case total do
      "" -> 0.0
      value -> value
    end
  end

  def insert_many!(table_name, items) do
    values = Enum.map(items, &transform_map/1) |> Enum.join(", ")

    request_mutation!(table_name, "INSERT INTO #{table_name} <<#{values}>>")
  end

  def insert_one!(table_name, item) do
    value = transform_map(item)

    request_mutation!(table_name, "INSERT INTO #{table_name} VALUE #{value}")
  end

  def update_by_clause!(table_name, clause, value, table_alias) do
    request_mutation!(
      table_name,
      "UPDATE #{table_name} AS #{table_alias} SET #{value} WHERE #{clause}"
    )
  end

  def update_by_id!(table_name, id, value, table_alias) do
    request_mutation!(
      table_name,
      "UPDATE #{table_name} AS #{table_alias} BY pid SET #{value} WHERE pid = '#{id}'"
    )
  end

  def find_by_id!(table_name, id) do
    request!("#{base_query(table_name)} WHERE id = '#{id}'") |> Enum.map(&Poison.decode!/1)
  end

  def find_by_clause!(table_name, clause) do
    request!("#{base_query(table_name)} WHERE #{clause}") |> Enum.map(&Poison.decode!/1)
  end
end
