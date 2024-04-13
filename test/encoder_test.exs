defmodule LiveState.EncoderTest do
  use ExUnit.Case

  alias LiveState.Test.Thing
  alias LiveState.Test.FakeSchema

  test "encode" do
    assert LiveState.Encoder.encode(%{foo: "bar"}) == %{foo: "bar"}
  end

  test "encode with struct" do
    assert LiveState.Encoder.encode(%Thing{foo: "bar", bar: "baz"}) == %{foo: "bar"}
  end

  test "encode date" do
    today = Date.utc_today()
    assert LiveState.Encoder.encode(today) == Date.to_iso8601(today)
  end

  test "encode fake schema" do
    now = DateTime.utc_now()
    iso_date = DateTime.to_iso8601(now)
    assert %{
             foo: "bar",
             inserted_at: ^iso_date
           } =
             LiveState.Encoder.encode(%FakeSchema{foo: "bar", inserted_at: now},
               ignore_keys: [:__meta__]
             )
  end

  test "encode without keys" do
    assert LiveState.Encoder.encode(%{foo: "wut", __meta__: "blah"}, ignore_keys: [:__meta__]) ==
             %{foo: "wut"}
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
