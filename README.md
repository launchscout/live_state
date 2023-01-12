# LiveState

## What is LiveState?

The goal of LiveState is to make building highly interactive web applications easier to build. Currently in most such applications clients send requests and receive responses from and to a server API. This essentially results in two applications, with state being managed in both in an ad hoc way.

LiveState uses a different approach. Clients dispatch events, which are sent to the server to be handled, and receive updates from the server any time application state changes. This allows state to have a single source of truth, and greatly reduces client code complexity. It also works equally well for applications where updates to state can occur indepently from a user initiated client side event (think "real time" applications such as chat, etc).

## How is LiveState different from LiveView?

LiveState shares similar goals to LiveView, but takes a different approach which allows for building different kinds of applications. LiveView allows the user to write all of the application code, both server logic and view presentation logic, in Elixir, and manages the web client side of the application entirely. LiveState event handlers are written in Elixir and quite similar to LiveView event handlers, but LiveState relies on client code to render state and dispatch events. This trade-off keeps client side code simple, but allows LiveState to be used to build applications that are not as good of a fit for LiveView.

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

## Related projects

## [phx-live-state](https://github.com/launchscout/phx-live-state)

The front end library npm package that implements sending and receiving events, and subscribing to state changes. It also facilitates building Custom Elements that are backed by LiveState.

## [use-live-state](https://github.com/launchscout/use-live-state)

A react hook for LiveState.

## [live_state_testbed](https://github.com/launchscout/live_state_testbed)

This is a phoenix project that mainly provides integration tests for LiveState.

## Learning resources

There are several examples of full LiveState projects. This [blog post](https://launchscout.com/blog/embedded-web-apps-with-livestate) covers building a embeddable comments section custom element. The relevant source code repos:

* https://github.com/launchscout/live_state_comments
* https://github.com/launchscout/livestate-comments

[This talk from ElixirConf 2022](https://youtu.be/jLamITBMoVI) also covers LiveState in detail. The code examples from the talk are in the repos below:

* https://github.com/launchscout/discord_element
* https://github.com/launchscout/discord-element

