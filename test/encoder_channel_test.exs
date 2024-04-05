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

  test "init" do
    assert_push("state:change", %{state: %{thing: thing}, version: 0})
    assert thing == %{bing: "baz", baz: "bing"}
  end

  test "handle_event", %{socket: socket} do
    send_event(socket, "change_baz", %{"baz" => "not_bing"})
    assert_push("state:change", %{state: %{thing: thing}, version: 1})
    assert thing == %{bing: "baz", baz: "not_bing"}
  end

end
