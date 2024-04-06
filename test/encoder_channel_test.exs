defmodule LiveState.EncoderChannelTest do
  use ExUnit.Case

  import Phoenix.ChannelTest
  alias LiveState.Test.OtherThing
  alias LiveState.Test.EncoderChannel
  alias LiveState.Test.UserSocket

  import LiveState.TestHelpers

  @endpoint LiveState.Test.Endpoint

  setup do
    start_supervised(@endpoint)
    start_supervised(Phoenix.PubSub.child_spec(name: LiveState.Test.PubSub))

    {:ok, _, socket} =
      socket(UserSocket, "wut", %{})
      |> subscribe_and_join(EncoderChannel, "foo:all")

    {:ok, %{socket: socket}}
  end

  test "json patch is computed after serialization", %{socket: socket} do
    send_event(socket, "change_baz", %{"baz" => "not_bing"})
    assert_push("state:patch", {:binary, payload})
    assert %{
      "patch" => [%{"op" => "replace", "path" => "/thing/baz", "value" => "not_bing"}],
      "version" => 1
    } = Jason.decode!(payload)
  end

end
