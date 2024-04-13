defmodule LiveState.Test.MessageBuilderTest do
  use ExUnit.Case

  alias LiveState.MessageBuilder

  test "update_state_message" do
    assert {"state:patch",
            %{
              patch: [%{"op" => "replace", "path" => "/foo", "value" => "baz"}],
              version: 1
            }} = MessageBuilder.update_state_message(%{foo: "bar"}, %{foo: "baz"}, 1)
  end

  test "build_state_change_message" do
    assert {"state:change",
            %{
              state: %{foo: "baz"},
              version: 1
            }} =
             MessageBuilder.new_state_message(%{foo: "baz", wut: "bar"}, 1, ignore_keys: [:wut])
  end

  test "update_state_message with datetime" do
    assert {"state:patch",
            %{
              patch: [%{"op" => "replace", "path" => "/time", "value" => _value}],
              version: 1
            }} =
             MessageBuilder.update_state_message(
               %{time: DateTime.utc_now()},
               %{time: DateTime.utc_now() |> DateTime.add(10, :minute)},
               1
             )
  end

  test "update_state_message with date" do
    assert {"state:patch",
            %{
              patch: [%{"op" => "replace", "path" => "/date", "value" => _value}],
              version: 1
            }} =
             MessageBuilder.update_state_message(
               %{date: Date.utc_today()},
               %{date: Date.utc_today() |> Date.add(10)},
               1
             )
  end

end
