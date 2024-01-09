defmodule LiveState.Test.TransformerChannel do
  @moduledoc false

  use LiveState.Channel,
    web_module: LiveState.Test.Web,
    event_transformer: [],
    state_transformer: []

  @impl true
  def init(_channel, _params, _socket) do
    {:ok, %{camel_cased: "foo"}}
  end

  @impl true
  def handle_event("do_thing", %{snake_cased: _}, state) do
    {:noreply, %{camel_cased: "bar"}, state}
  end

end
