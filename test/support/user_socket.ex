defmodule LiveState.Test.UserSocket do
  @moduledoc false

  use Phoenix.Socket

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels

  channel("todos:*", LiveState.Test.TodoChannel)
  channel("transformer", LiveState.Test.TransformerChannel)
  channel("foo:*", LiveState.Test.PatchChannel)
  channel("authorized:*", LiveState.Test.AuthorizedChannel)

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.LiveStateCommentsWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
