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

  test "both working" do
    encoded =
      Poison.encode!(%{
        id: "5f17bf4ffce00d94dd21f8fa",
        index: 0,
        guid: "c1ce93fb-ca49-477d-b4e0-abeeb91e008c",
        isActive: false,
        balance: "$2,110.65",
        picture: "http://placehold.it/32x32",
        age: 32,
        eyeColor: "blue",
        name: "Glass Malone",
        gender: "male",
        company: "MYOPIUM",
        email: "glassmalone@myopium.com",
        phone: "+1 (818) 424-2087",
        address: "275 Cumberland Street, Waterford, Oklahoma, 9275",
        about:
          "Sint ad laborum ipsum aute sint amet cupidatat do ipsum deserunt elit. Nisi do ea nulla id enim mollit deserunt aute cupidatat. Labore elit reprehenderit officia aliqua anim deserunt ex dolor. Nulla exercitation aliquip amet ad velit minim.\r\n",
        registered: "2014-03-25T02:08:20 +03:00",
        latitude: -7.33016,
        longitude: 124.140386,
        tags: [
          "Lorem",
          "irure",
          "ullamco",
          "dolore",
          "amet",
          "tempor",
          "amet"
        ],
        friends: [
          %{
            id: 0,
            name: "Jaclyn Wilder"
          },
          %{
            id: 1,
            name: "Sargent Montoya"
          },
          %{
            id: 2,
            name: "Burns Coleman"
          }
        ],
        greeting: "Hello, Glass Malone! You have 9 unread messages.",
        favoriteFruit: "apple"
      })

    {:ok, input} = Qldbex.Native.to_ion(encoded)

    assert Qldbex.Native.from_ion(input) == {:ok, encoded}
  end
end
