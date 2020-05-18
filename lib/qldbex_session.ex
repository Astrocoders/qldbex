defmodule Qldbex.Session do
  @type parameter :: [
          {:ion_binary, binary}
          | {:ion_text, binary}
        ]

  @type start_session_request :: [
          {:ledger_name, binary}
        ]

  @type start_transaction_request :: []

  @type end_session_request :: []

  @type commit_transaction_request :: [
          {:transaction_id, binary}
          | {:commit_digest, binary}
        ]

  @type abort_transaction_request :: []

  @type execute_statement_request :: [
          {:transaction_id, binary}
          | {:statement, binary}
          | {:parameters, list(parameter)}
        ]

  @type fetch_page_request :: [
          {:transaction_id, binary}
          | {:next_page_token, binary}
        ]

  @type send_command_request :: [
          {:session_token, binary | nil}
          | {:start_session, start_session_request | nil}
          | {:start_transaction, start_transaction_request | nil}
          | {:end_session, end_session_request | nil}
          | {:commit_transaction, commit_transaction_request | nil}
          | {:abort_transaction, abort_transaction_request | nil}
          | {:execute_statement, execute_statement_request | nil}
          | {:fetch_page, fetch_page_request | nil}
        ]

  @spec send_command(request :: send_command_request) :: ExAws.Operation.JSON.t()
  def send_command(request) do
    data = %{
      "SessionToken" => request.session_token,
      "StartSession" => %{
        "LedgerName" => get_in(request, [:start_session, :ledger_name])
      },
      "StartTransaction" => %{},
      "EndSession" => %{},
      "CommitTransaction" => %{
        "TransactionId" => get_in(request, [:commit_transaction, :transaction_id]),
        "CommitDigest" => get_in(request, [:commit_transaction, :commit_digest])
      },
      "AbortTransaction" => %{},
      "ExecuteStatement" => %{
        "TransactionId" => get_in(request, [:execute_statement, :transaction_id]),
        "Statement" => get_in(request, [:execute_statement, :statement]),
        "Parameters" => get_in(request, [:execute_statement, :parameters])
      },
      "FetchPage" => %{
        "TransactionId" => get_in(request, [:fetch_page, :transaction_id]),
        "NextPageToken" => get_in(request, [:fetch_page, :next_page_token])
      }
    }

    request(data)
  end

  @spec start_session(ledger_name :: binary) :: ExAws.Operation.JSON.t()
  def start_session(ledger_name) do
    data = %{
      "StartSession" => %{
        "LedgerName" => ledger_name
      }
    }

    request(data)
  end

  @spec start_transaction(session_token :: binary) :: ExAws.Operation.JSON.t()
  def start_transaction(session_token) do
    data = %{
      "SessionToken" => session_token,
      "StartTransaction" => %{}
    }

    request(data)
  end

  @spec execute_statement(
          session_token :: binary,
          transaction_id :: binary,
          statement :: binary,
          parameters :: list(parameter)
        ) :: ExAws.Operation.JSON.t()
  def execute_statement(session_token, transaction_id, statement, parameters) do
    data = %{
      "SessionToken" => session_token,
      "ExecuteStatement" => %{
        "TransactionId" => transaction_id,
        "Statement" => statement,
        "Parameters" => parameters
      }
    }

    request(data)
  end

  @spec commit_transaction(
          session_token :: binary,
          transaction_id :: binary,
          statement :: binary,
          parameters :: list(binary)
        ) :: ExAws.Operation.JSON.t()
  def commit_transaction(session_token, transaction_id, statement, _parameters) do
    # @TODO: Pass params
    {:ok, commit_digest} = Qldbex.Native.generate_commit_digest(transaction_id, statement)

    data = %{
      "SessionToken" => session_token,
      "CommitTransaction" => %{
        "TransactionId" => transaction_id,
        "CommitDigest" => commit_digest
      }
    }

    request(data)
  end

  @spec abort_transaction(session_token :: binary) :: ExAws.Operation.JSON.t()
  def abort_transaction(session_token) do
    data = %{
      "SessionToken" => session_token,
      "AbortTransaction" => %{}
    }

    request(data)
  end

  @spec end_session(session_token :: binary) :: ExAws.Operation.JSON.t()
  def end_session(session_token) do
    data = %{
      "SessionToken" => session_token,
      "EndSession" => %{}
    }

    request(data)
  end

  @spec fetch_page(
          session_token :: binary,
          next_page_token :: binary,
          transaction_id :: binary
        ) :: ExAws.Operation.JSON.t()
  def fetch_page(session_token, next_page_token, transaction_id) do
    data = %{
      "SessionToken" => session_token,
      "FetchPage" => %{
        "TransactionId" => transaction_id,
        "NextPageToken" => next_page_token
      }
    }

    request(data)
  end

  defp request(data) do
    ExAws.Operation.JSON.new(:"session.qldb", %{
      http_method: :post,
      path: "/",
      data: data,
      headers: [
        {"Content-Type", "application/x-amz-json-1.0"},
        {"X-Amz-Target", "QLDBSession.SendCommand"},
        {"SignedHeaders", "host;x-amz-target"}
      ],
      service: :"session.qldb"
    })
  end
end
