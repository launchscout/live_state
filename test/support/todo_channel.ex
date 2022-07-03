defmodule LiveState.Test.TodoChannel do
  use LiveState.LiveStateChannel, web_module: LiveState.Test.Web

  def init(_socket) do
    Phoenix.PubSub.subscribe(LiveState.Test.PubSub, "todos")
    {:ok, %{todos: []}}
  end

  def handle_event("add_todo", todo, %{todos: todos}) do
    {:noreply, %{todos: [todo | todos]}}
  end

  def handle_message({:todo_added, todo}, %{todos: todos}) do
    {:ok, %{todos: [todo | todos]}}
  end

end
