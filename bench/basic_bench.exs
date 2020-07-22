defmodule BasicBench do
  use Benchfella

  @transaction_id "1313123127378123789178937189"
  @statement "INSERT INTO deposits VALUES 123"

  # bench "Native Generate digest" do
  #   {:ok, hash} =
  #     Qldbex.Native.generate_commit_digest(
  #       @transaction_id,
  #       @statement
  #     )

  #   hash
  # end

  bench "Native From Ion" do
    {:ok, json} =
      Qldbex.Native.from_ion(
        "4AEA6u7/gYPe+4e++Il0aW1lc3RhbXCLc29tZV9zdHJpbmeMc29tZV9kZWNpbWFsiXNvbWVfYm9vbIhzb21lX2ludItzb21lX3N0cnVjdIhtZXRhZGF0YYltZXRhZGF0YTKJbWV0YWRhdGEzinNvbWVfYXJyYXmNYW5vdGhlcl9sZXZlbN7kimiAD+SEnJKAgIuFSGVsbG+MV8UEb1TnZT2NEY4hAY/akCEBkYEyklLCbpO+toExIQJTwgE2EdOEIQHep4TepJS+oSEBIQIhAyEFvpeOjm91dHJvIGFuaW5oYWRvIQEhAlLBZA=="
      )

    json
  end
end
