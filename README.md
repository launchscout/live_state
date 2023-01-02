# LiveState

## What is LiveState?

The goal of LiveState is to make building highly interactive web applications easier to build. Currently in most such applications clients send requests and receive responses from and to a server API. This essentially results in two applications, with state being managed in both in an ad hoc way.

LiveState uses a different approach. Clients dispatch events, which are sent to the server to be handled, and receive updates from the server any time application state changes. This allows state to have a single source of truth, and greatly reduces client code complexity. It also works equally well for applications where updates to state can occur indepently from a user initiated client side event (think "real time" applications such as chat, etc).

## How is LiveState different from LiveView?

LiveState shares similar goals to LiveView, but takes a different approach which allows for building different kinds of applications. LiveView allows the user to write all of the application code, both server logic and view presentation logic, in Elixir, and manages the web client side of the application entirely. LiveState event handlers are written in Elixir and quite similar to LiveView event handlers, but LiveState relies on client code to render state and dispatch events. This trade-off keeps client side code simple, but allows LiveState to be used to build applications that are not as good of a fit for LiveView.

## Repo organization

The code for LiveState is organized into several sub-projects:

## [live_state](live_state)

This is the Elixir library to power to backend of a LiveState project. It consists mainly of a Phoenix Channel behaviour

## [phx-live-state](phx-live-state)

The front end library npm package that implements sending and receiving events, and subscribing to state changes. It also facilitates building Custom Elements that are backed by LiveState.

## [use-live-state](use-live-state)

A react hook for LiveState.

## [testbed](testbed)

This is a phoenix project that mainly provides integration tests for LiveState.

## Learning resources

There are several examples of full LiveState projects. This [blog post](https://launchscout.com/blog/embedded-web-apps-with-livestate) covers building a embeddable comments section custom element. The relevant source code repos:

* https://github.com/launchscout/live_state_comments
* https://github.com/launchscout/livestate-comments

[This talk from ElixirConf 2022](https://youtu.be/jLamITBMoVI) also covers LiveState in detail. The code examples from the talk are in the repos below:

* https://github.com/launchscout/discord_element
* https://github.com/launchscout/discord-element
