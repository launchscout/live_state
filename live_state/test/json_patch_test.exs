defmodule LiveState.JSONPatchTest do
  use ExUnit.Case

  import Phoenix.ChannelTest
  alias LiveState.Test.PatchChannel
  alias LiveState.Test.UserSocket

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
    push(socket, "lvs_evt:change_foo", %{"foo" => "not_bar"})

    assert_push("state:patch", %{
      patch: [%{"op" => "replace", "path" => "/foo", "value" => "not_bar"}],
      version: 1
    })
  end

end
