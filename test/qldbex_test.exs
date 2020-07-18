defmodule QldbexTest do
  use ExUnit.Case
  doctest Qldbex

  @ion_string "{ timestamp: 2020-04-28T18:00:00Z, some_string: \"Hello\", some_decimal: 48762123.31837, some_bool: true, some_int: 1, some_struct: {metadata: 1, metadata2: \"2\", metadata3: 1.10}, some_array: [\"1\", 2, 3.10, true, {name: 1}, {name: { another_level: [1, 2, 3, 5, [\"outro aninhado\", 1, 2, 10.0]] }}] }"
  @ion_binary "4AEA6u7/gYPe+4e++Il0aW1lc3RhbXCLc29tZV9zdHJpbmeMc29tZV9kZWNpbWFsiXNvbWVfYm9vbIhzb21lX2ludItzb21lX3N0cnVjdIhtZXRhZGF0YYltZXRhZGF0YTKJbWV0YWRhdGEzinNvbWVfYXJyYXmNYW5vdGhlcl9sZXZlbN7kimiAD+SEnJKAgIuFSGVsbG+MV8UEb1TnZT2NEY4hAY/akCEBkYEyklLCbpO+toExIQJTwgE2EdOEIQHep4TepJS+oSEBIQIhAyEFvpeOjm91dHJvIGFuaW5oYWRvIQEhAlLBZA=="
  @ion_string_representation "{ \"timestamp\": \"2020-04-28T15:00:00-03\", \"some_string\": \"Hello\", \"some_decimal\": 48762123.31837, \"some_bool\": true, \"some_int\": 1, \"some_struct\": { \"metadata\": 1, \"metadata2\": \"2\", \"metadata3\": 1.1000000000000001 }, \"some_array\": [ \"1\", 2, 3.1000000000000001, true, { \"name\": 1 }, { \"name\": { \"another_level\": [ 1, 2, 3, 5, [ \"outro aninhado\", 1, 2, 10.0 ] ] } } ] }"
  @ion_json_representation Poison.decode!(@ion_string_representation)

  @transaction_id "1313123127378123789178937189"
  @statement "INSERT INTO deposits VALUES 123"
  @parameters []

  test "Native to_ion" do
    {:ok, res} = Qldbex.Native.to_ion(@ion_string)
    assert res == @ion_binary
  end

  test "Native from_ion" do
    {:ok, res} = Qldbex.Native.from_ion(@ion_binary)
    assert Poison.decode!(res) == @ion_json_representation
  end
end
