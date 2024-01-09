# LiveState

This is the Elixir library for building servers for LiveState applications.

## What is LiveState?

The goal of LiveState is to make highly interactive web applications easier to build. Currently, in most such applications, clients send requests and receive responses from and to a server API. This essentially results in two applications, with state being managed in both in an ad hoc way.

LiveState uses a different approach. Clients dispatch events, which are sent to the server to be handled, and receive updates from the server any time application state changes. This allows state to have a single source of truth, and greatly reduces client code complexity. It also works equally well for applications where updates to state can occur independently from a user initiated, client side event (think "real time" applications such as chat, etc).

## How is LiveState different from LiveView?

LiveState shares similar goals to LiveView, but takes a different approach which allows for building different kinds of applications. LiveView allows the user to write all of the application code, both server logic and view presentation logic, in Elixir, and entirely manages the web client side of the application. LiveState event handlers are written in Elixir and are quite similar to LiveView event handlers, but LiveState relies on client code to render state and dispatch events. This trade-off keeps client side code simple, but allows LiveState to be used to build applications that are not as good of a fit for LiveView.

## Installation

This package can be installed
by adding `live_state` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:live_state, "~> 0.7.0"},
    {:cors_plug, "~> 3.0"}
  ]
end
```

While `cors_plug` is not strictly required, you will very likely want it to be able to add to your endpoint so that
clients cannot connect to your channel.

## Usage
First you need to set up a socket as you would with other normal [Phoenix Channels](https://hexdocs.pm/phoenix/channels.html)

1. On your Endpoint module, set up a socket for your channel:
```elixir
defmodule MyAppWeb.Endpoint do
  socket "/socket", PgLiveHeroWeb.Channels.LiveStateSocket
...
```
2. Then create the socket module with the topic to listen to:
```elixir
defmodule MyAppWeb.Socket do
  use Phoenix.Socket

  channel "topic", MyAppWeb.Channel
  @impl true
  def connect(_params, socket), do: {:ok, socket}

  @impl true
  def id(_), do: "random_id"
end
```
3. Create your channel using the `LiveState.Channel` behaviour:

```elixir
defmodule MyAppWeb.Channel do
  use LiveState.Channel, web_module: MyAppWeb
...
```

4. Then define your initial state using the `c:LiveState.Channel.init/3` callback, which will be called after channel joins and is expected to return the initial state:

```elixir
def init(_channel, _payload, _socket), do: {:ok, %{foo: "bar"}}
```

State must be a map. It will be sent down as JSON, so anything in it
must have a `Jason.Encoder` implementation.

## Events

For events emitted from the client, you implement the `c:LiveState.Channel.handle_event/3` callback. If you need access the socket in your event handler, you may implement
 `c:LiveState.Channel.handle_event/4`.

```elixir
  def handle_event("add_todo", todo, %{todos: todos}) do
    {:noreply, %{todos: [todo | todos]}}
  end
```

`c:LiveState.Channel.handle_event/3` receives the following arguments

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

## Documentation

* [Tutorial](docs/tutorial_start.md) - A step by step guide to building an embedded app using LiveState
* [API Docs](https://hexdocs.pm/live_state/) are available in the [hex package](https://hex.pm/packages/live_state).

## Related projects

## [phx-live-state](https://github.com/launchscout/phx-live-state)

The front end library npm package that implements sending and receiving events, and subscribing to state changes. It also facilitates building Custom Elements that are backed by LiveState.

## [live-templates](https://github.com/launchscout/live-templates)

Live-templates is an npm package that allows you to connect a front end template to a LiveState channel. Because it doesn't require a custom element or any other javascript code, it is probably the easiest way to get started with LiveState.

## [use-live-state](https://github.com/launchscout/use-live-state)

A react hook for LiveState.

## [live_state_testbed](https://github.com/launchscout/live_state_testbed)

This is a Phoenix project that mainly provides integration tests for LiveState. It's also a great place to see examples of how to use LiveState.

## Other resources

There are several examples of full LiveState projects. This [blog post](https://launchscout.com/blog/embedded-web-apps-with-livestate) covers building an embeddable custom element for a comments section. The relevant source code repos are:

* https://github.com/launchscout/live_state_comments
* https://github.com/launchscout/livestate-comments

[This talk from ElixirConf 2022](https://youtu.be/jLamITBMoVI) also covers LiveState in detail. The code examples from the talk are in the repos below:

* https://github.com/launchscout/discord_element
* https://github.com/launchscout/discord-element

