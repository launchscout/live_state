defmodule LiveState.Test.AuthorizedChannel do
  use LiveState.Channel, web_module: LiveState.Test.Web

  def authorize(_channel, %{"password" => "secret"}, socket) do
    {:ok, socket}
  end

  def authorize(_channel, _payload, _socket) do
    {:error, "Go away!"}
  end

  def init(_channel, _payload, _socket) do
    {:ok, %{authorized: true}}
  end

  def handle_event(_event_name, _payload, state) do
    {:noreply, state}
  end
end
