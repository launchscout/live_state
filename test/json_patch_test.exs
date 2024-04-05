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

  test "version rollover", %{socket: socket} do
    Enum.each(0..11, fn i -> push(socket, "lvs_evt:change_foo", %{"foo" => "bar #{i}"}) end)
    for _i <- (0..10) do
      assert_push("state:patch", _)
    end
    assert_push("state:patch", {:binary, raw_message})
    assert %{
      "patch" => [%{"op" => "replace", "path" => "/foo", "value" => "bar 11"}],
      "version" => 1
    } = Jason.decode!(raw_message)
  end

end
