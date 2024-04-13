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
    assert %{foo: "bar", inserted_at: _date_string} = thing
  end

  test "handle_event", %{socket: socket} do
    send_event(socket, "change_foo", %{"foo" => "not_bar"})

    assert_push("state:patch", %{
      version: 1,
      patch: patches
    })
    paths = patches |> Enum.map(& &1["path"])
    assert "/thing/foo" in paths
    assert "/thing/updated_at" in paths
  end
end
