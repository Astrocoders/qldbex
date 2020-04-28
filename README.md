# Qldbex

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `qldbex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:qldbex, "~> 0.1.0"}
  ]
end
```

```
config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :qldbex,
  ledger_name: "my_ledger"
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/qldbex](https://hexdocs.pm/qldbex).

