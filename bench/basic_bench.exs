defmodule BasicBench do
  use Benchfella

  @transaction_id "1313123127378123789178937189"
  @statement "INSERT INTO deposits VALUES 123"

  bench "Native Generate digest" do
    {:ok, hash} =
      Qldbex.Native.generate_commit_digest(
        @transaction_id,
        @statement
      )

    hash
  end
end
