defmodule LiveState.TransformersTest do
  use ExUnit.Case

  import Phoenix.ChannelTest
  alias LiveState.Test.TransformerChannel
  alias LiveState.Test.UserSocket

  import LiveState.TestHelpers

  @endpoint LiveState.Test.Endpoint

  setup do
    start_supervised(@endpoint)
    start_supervised(Phoenix.PubSub.child_spec(name: LiveState.Test.PubSub))

    {:ok, _, socket} =
      socket(UserSocket, "wut", %{})
      |> subscribe_and_join(TransformerChannel, "foo")

    {:ok, %{socket: socket}}
  end

  test "init" do
    assert_push(
      "state:change",
    %{state: %{camelCased: "foo"}, version: 0}
    )
  end

  test "handle_event", %{socket: socket} do
    send_event(socket, "doThing", %{"snakeCased" => "foo"})
    assert_state_change %{camelCased: "bar"}
  end

end
