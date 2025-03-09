defmodule LiveState.JSONPatchTest do
  use ExUnit.Case

  import Phoenix.ChannelTest
  alias LiveState.Test.PatchChannel
  alias LiveState.Test.UserSocket

  import LiveState.TestHelpers

  @endpoint LiveState.Test.Endpoint

  setup do
    start_supervised(@endpoint)
    start_supervised(Phoenix.PubSub.child_spec(name: LiveState.Test.PubSub))

    {:ok, _, socket} =
      socket(UserSocket, "wut", %{})
      |> subscribe_and_join(PatchChannel, "foo:all")

    {:ok, %{socket: socket}}
  end

  test "init" do
    assert_push("state:change", %{state: %{foo: "bar"}, version: 0})
  end

  test "handle_event", %{socket: socket} do
    send_event(socket, "change_foo", %{"foo" => "not_bar"})
    assert_state_patch([%{"op" => "replace", "path" => "/foo", "value" => "not_bar"}])
  end

  test "lvs_refresh", %{socket: socket} do
    send_event(socket, "change_foo", %{"foo" => "not_bar"})
    assert_state_patch([%{"op" => "replace", "path" => "/foo", "value" => "not_bar"}])
    push(socket, "lvs_refresh", %{})
    assert_push("state:change", %{state: %{foo: "not_bar"}, version: 1})
  end

  test "version rollover", %{socket: socket} do
    Enum.each(0..11, fn i -> push(socket, "lvs_evt:change_foo", %{"foo" => "bar #{i}"}) end)
    assert_push("state:patch", %{
      patch: [%{"op" => "replace", "path" => "/foo", "value" => "bar 11"}],
      version: 1
    })
  end

end
