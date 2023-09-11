defmodule <%= module %>Channel do
  @moduledoc false

  use LiveState.Channel, web_module: <%= web_module %>

  @impl true
  def init(_channel, _params, _socket) do
    {:ok, %{}}
  end

  @impl true
  def handle_event("do_something", _payload, state) do
    {:noreply, Map.put(state, :foo, "bar")}
  end

end
