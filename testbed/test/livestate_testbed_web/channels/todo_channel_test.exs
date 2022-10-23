defmodule LivestateTestbedWeb.TodoChannelTest do
  use LivestateTestbedWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      LivestateTestbedWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(LivestateTestbedWeb.TodoChannel, "todo:lobby")

    %{socket: socket}
  end

  @tag :skip
  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  @tag :skip
  test "shout broadcasts to todo:lobby", %{socket: socket} do
    push(socket, "shout", %{"hello" => "all"})
    assert_broadcast "shout", %{"hello" => "all"}
  end

  @tag :skip
  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
