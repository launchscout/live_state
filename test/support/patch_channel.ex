defmodule LiveState.Test.PatchChannel do
  @moduledoc false

  use LiveState.Channel, web_module: LiveState.Test.Web, json_patch: true

  def init(_channel, _params, _socket) do
    {:ok, %{foo: "bar"}}
  end

  def handle_event("change_foo", %{"foo" => new_foo}, _state) do
    {:noreply, %{foo: new_foo}}
  end
end
