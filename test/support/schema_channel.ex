defmodule LiveState.Test.SchemaChannel do
  @moduledoc false

  alias LiveState.Test.FakeSchema

  use LiveState.Channel, web_module: LiveState.Test.Web

  def init(_channel, _params, _socket) do
    {:ok,
     %{
       thing: %FakeSchema{
         foo: "bar",
         inserted_at: DateTime.utc_now(),
         updated_at: DateTime.utc_now()
       }
     }}
  end

  def handle_event("change_foo", %{"foo" => new_foo}, %{thing: thing}) do
    {:noreply,
     %{
       thing: %{thing | foo: new_foo, updated_at: DateTime.utc_now()}
     }}
  end
end
