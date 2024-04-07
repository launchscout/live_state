defmodule LiveState.SchemaChanneltest do
  use ExUnit.Case

  import Phoenix.ChannelTest
  alias LiveState.Test.SchemaChannel
  alias LiveState.Test.UserSocket

  import LiveState.TestHelpers

  @endpoint LiveState.Test.Endpoint

  setup do
    start_supervised(@endpoint)
    start_supervised(Phoenix.PubSub.child_spec(name: LiveState.Test.PubSub))

    {:ok, _, socket} =
      socket(UserSocket, "wut", %{})
      |> subscribe_and_join(SchemaChannel, "foo:all")

    {:ok, %{socket: socket}}
  end

  test "init" do
    assert_push("state:change", %{state: %{thing: thing}, version: 0})
    assert thing == %{foo: "bar"}
  end

  test "handle_event", %{socket: socket} do
    send_event(socket, "change_foo", %{"foo" => "not_bar"})

    assert_push("state:patch", %{
      version: 1,
      patch: [%{"op" => "replace", "path" => "/thing/foo", "value" => "not_bar"}]
    })
  end
end
