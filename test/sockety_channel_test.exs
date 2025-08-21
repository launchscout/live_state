defmodule LiveState.SocketyChannelTest do
  use ExUnit.Case

  import Phoenix.ChannelTest
  alias LiveState.Test.SocketyChannel
  alias LiveState.Test.UserSocket

  @endpoint LiveState.Test.Endpoint

  setup do
    start_supervised(@endpoint)
    start_supervised(Phoenix.PubSub.child_spec(name: LiveState.Test.PubSub))

    {:ok, _, socket} =
      socket(UserSocket, "wut", %{})
      |> subscribe_and_join(SocketyChannel, "sockety:sock", %{})

    {:ok, %{socket: socket}}
  end

  test "init", %{socket: %{assigns: %{baz: baz}}} do
    assert baz == "bing"
    assert_push(
      "state:change",
      %{state: %{foo: "bar"}, version: 0}
    )
  end

  test "handle_event", %{socket: socket} do
    push(socket, "lvs_evt:something_sockety", %{"baz" => "wuzzle"})

    assert_push("state:patch", %{
      version: 1,
      patch: [%{"op" => "replace", "path" => "/foo", "value" => "altered bar"}]
    })
  end

  test "handle_message", %{socket: socket} do
    send(socket.channel_pid, "message too")

    assert_push("state:patch", %{
      version: 1,
      patch: [%{"op" => "replace", "path" => "/foo", "value" => "altered bar"}]
    })
  end

end
