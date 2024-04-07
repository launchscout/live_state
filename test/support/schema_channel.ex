defmodule LiveState.Test.SchemaChannel do
  @moduledoc false

  alias LiveState.Test.FakeSchema

  use LiveState.Channel, web_module: LiveState.Test.Web

  def init(_channel, _params, _socket) do
    {:ok,
     %{
       thing: %FakeSchema{
         foo: "bar",
         __meta__: %{random: "garbage"}
       }
     }}
  end

  def handle_event("change_foo", %{"foo" => new_foo}, _state) do
    {:noreply,
     %{
       thing: %FakeSchema{
         foo: new_foo,
         __meta__: %{random: "more garbage"}
       }
     }}
  end
end
