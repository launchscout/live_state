# LiveState

This project exists to facilitate building the servier side of embedded apps, or micro-front-end apps, 
in Elixir. 

## Installation

This package can be installed
by adding `live_state` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:live_state, "~> 0.2.0"},
    {:cors_plug, "~> 3.0"}
  ]
end
```

While `cors_plug` is not strictly required, you will very likely want it to be able to add to your endpoint so that
clients cannot connect to your channel.

## Usage

You'll want to use the `LiveState.Channel` behaviour in a channel:

```elixir
defmodule MyAppWeb.Channel do
  use LiveState.Channel, web_module: MyAppWeb
...
```

You'll then want to define your initial state using the `init/3` callback which will be
called after channel joins and is expected to return the initial state:

```elixir
def init(_channel, _payload, _socket), do: %{foo: "bar"}
```

State will likely be a map, but can be any term. It will be sent down as JSON so anything in it
must have `Jason.Encoder` implementation.

## Events

For events emitted from the client, you implement the `handle_event/3` callback. 

```elixir
  def handle_event("add_todo", todo, %{todos: todos}) do
    {:noreply, %{todos: [todo | todos]}}
  end
```

`handle_event` receives the following arguments

* event name
* payload
* current 

And returns a tuple whose last element is the new state. It can also return 
one or many events to dispatch on the calling DOM Element:

```elixir
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
```

## Testing

We need a test helper to make this a bit easier. Stay tuned! For now you can see the tests
in this codebase for how you can test with the channel helpers from Phoenix.

## Documentation

[Docs](https://hexdocs.pm/live_state/) are available in the [hex package](https://hex.pm/packages/live_state).

## Client

For the client, you will likely want to use the [phx-live-state](https://github.com/gaslight/live-state) npm.

## Examples

* https://github.com/launchscout/live_state_comments
* https://github.com/launchscout/livestate-comments
* https://github.com/launchscout/discord_element
* https://github.com/launchscout/discord-element
