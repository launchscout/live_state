defmodule LiveState.LiveStateChannelTest do
  use ExUnit.Case

  import Phoenix.ChannelTest
  alias LiveState.Test.TodoChannel
  alias LiveState.Test.UserSocket

  @endpoint LiveState.Test.Endpoint

  setup do
    start_supervised(@endpoint)
    start_supervised(Phoenix.PubSub.child_spec(name: LiveState.Test.PubSub))

    {:ok, _, socket} =
      socket(UserSocket, "wut", %{})
      |> subscribe_and_join(TodoChannel, "todos:all", %{"id" => 1})

    {:ok, %{socket: socket}}
  end

  test "init" do
    assert_push("state:change", %{todos: []})
  end

  test "handle_event", %{socket: socket} do
    push(socket, "lvs_evt:add_todo", %{"description" => "Do the thing"})
    assert_push("state:change", %{todos: [%{"description" => "Do the thing"}]})
  end

  test "handle_message" do
    Phoenix.PubSub.broadcast(
      LiveState.Test.PubSub,
      "todos",
      {:todo_added, %{"description" => "And another one"}}
    )

    assert_push("state:change", %{todos: [%{"description" => "And another one"}]})
  end
end
