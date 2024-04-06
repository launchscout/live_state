defmodule LiveState.Test.JsonDifferTest do
  use ExUnit.Case

  test "performance" do
    map = Enum.reduce(1..1_00000, %{}, fn i, map ->
      Map.put(map, "foo_#{i}", "bar")
    end)
    map2 = map |> Map.put("foo_997", "bing")
    {usec, _} = :timer.tc(fn ->
      json1 = Jason.encode!(map)
      json2 = Jason.encode!(map2)

      LiveState.JSONDiffer.build_patch_message(json1, json2, 2)
    end)
    IO.inspect(usec / 1_000, label: "rust json diffing")
    {elixir_usec, _} = :timer.tc(&JSONDiff.diff/2, [map, map2])
    IO.inspect(elixir_usec / 1_000, label: "elixir json diffing")
  end
end
