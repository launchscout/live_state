defmodule LiveState.LiveStateChannelTest do
  use ExUnit.Case

  import Phoenix.ChannelTest
  alias LiveState.Test.BadInitChannel
  alias LiveState.Test.UserSocket

  import LiveState.TestHelpers

  @endpoint LiveState.Test.Endpoint

  setup do
    start_supervised(@endpoint)
    start_supervised(Phoenix.PubSub.child_spec(name: LiveState.Test.PubSub))

    {:ok, _, socket} =
      socket(UserSocket, "wut", %{})
      |> subscribe_and_join(BadInitChannel, "wutever", %{})

    {:ok, %{socket: socket}}
  end

  test "init" do
    assert_push(
      "error",
      %{message: "you stink"}
    )
  end

end
