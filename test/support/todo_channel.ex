defmodule LiveState.Test.TodoChannel do
  use LiveState.Channel, web_module: LiveState.Test.Web
  alias LiveState.Event

  def init(_channel, %{"token" => token}, _socket) do
    Phoenix.PubSub.subscribe(LiveState.Test.PubSub, "todos")
    {:ok, %{todos: [], token: token}}
  end

  def handle_event("add_todo", todo, %{todos: todos}) do
    {:noreply, %{todos: [todo | todos]}}
  end

  def handle_event("add_todo_with_one_reply", todo, %{todos: todos}) do
    {:reply, %Event{name: "reply_event", detail: %{foo: "bar"}}, %{todos: [todo | todos]}}
  end

  def handle_event("add_todo_with_two_replies", todo, %{todos: todos}) do
    {:reply,
     [
       %Event{name: "reply_event1", detail: %{foo: "bar"}},
       %Event{name: "reply_event2", detail: %{bing: "baz"}}
     ], %{todos: [todo | todos]}}
  end

  def handle_message({:todo_added, todo}, %{todos: todos}) do
    {:reply, %Event{name: "reply_event", detail: %{foo: "bar"}}, %{todos: [todo | todos]}}
  end
end
