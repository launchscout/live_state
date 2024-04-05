defmodule LiveState.Test.EncoderChannel do
  @moduledoc false

  alias LiveState.Test.OtherThing

  use LiveState.Channel, web_module: LiveState.Test.Web, json_patch: true

  def init(_channel, _params, _socket) do
    {:ok, %{thing: %OtherThing{bing: "baz", baz: "bing", wuzzle: "wuzzle"}}}
  end

  def handle_event("change_baz", %{"baz" => new_baz}, _state) do
    {:noreply, %{thing: %OtherThing{bing: "baz", baz: new_baz, wuzzle: "super wuzzle"}}}
  end
end
