defmodule LiveState.EncoderTest do
  use ExUnit.Case

  alias LiveState.Test.Thing

  test "encode" do
    assert LiveState.Encoder.encode(%{foo: "bar"}) == %{foo: "bar"}
  end

  test "encode with struct" do
    assert LiveState.Encoder.encode(%Thing{foo: "bar", bar: "baz"}) == %{foo: "bar"}
  end

  test "encode a list" do
    assert LiveState.Encoder.encode([%{foo: "bar"}, %Thing{foo: "baz", bar: "bing"}]) == [
             %{foo: "bar"},
             %{foo: "baz"}
           ]
  end

  test "encode a map" do
    assert LiveState.Encoder.encode(%{foo: %{thing: %Thing{foo: "baz", bar: "bing"}}}) == %{
             foo: %{thing: %{foo: "baz"}}
           }
  end

  test "derive" do
    assert LiveState.Encoder.encode(%LiveState.Test.OtherThing{
             bing: "baz",
             baz: "bing",
             wuzzle: "wuzzle"
           }) == %{bing: "baz", baz: "bing"}

    assert LiveState.Encoder.encode(%LiveState.Test.OnlyThing{
             bing: "baz",
             baz: "bing",
             wuzzle: "wuzzle"
           }) == %{wuzzle: "wuzzle", baz: "bing"}
  end
end
