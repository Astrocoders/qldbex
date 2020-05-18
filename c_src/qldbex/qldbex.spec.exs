module(Qldbex.Native)

callback(:load)

spec(init() :: {:ok :: label, state} | {:error :: label, error_code :: int})

spec(
  to_ion(json_string :: string) ::
    {:ok :: label, base64 :: string} | {:error :: label, error_reason :: string}
)

spec(
  from_ion(json_string :: string) ::
    {:ok :: label, decoded :: string} | {:error :: label, error_reason :: string}
)

spec(
  generate_commit_digest(transaction_id :: string, statement :: string) ::
    {:ok :: label, digest :: string} | {:error :: label, error_reason :: string}
)
