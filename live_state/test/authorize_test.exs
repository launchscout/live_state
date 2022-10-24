defmodule LiveState.AuthorizeTest do
  use ExUnit.Case

  import Phoenix.ChannelTest
  alias LiveState.Test.UserSocket

  @endpoint LiveState.Test.Endpoint

  setup do
    start_supervised(@endpoint)
    start_supervised(Phoenix.PubSub.child_spec(name: LiveState.Test.PubSub))

    {:ok, %{socket: socket(UserSocket, "wut", %{})}}
  end

  test "successful join", %{socket: socket} do
    assert {:ok, _result, _socket} = socket |> subscribe_and_join("authorized:all", %{"password" => "secret"})
    assert_push("state:change", %{state: %{authorized: true}, version: 0})
  end

  test "unsuccessful join", %{socket: socket} do
    assert {:error, reason} = socket |> subscribe_and_join("authorized:all", %{"password" => "garbage"})
  end

end
