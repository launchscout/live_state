# LiveState

This project exists to facilitate building the servier side of embedded apps, or micro-front-end apps, 
in Elixir. It is a monorepo consisting of several subprojects:

## [live_state](live_state/README.md)

This is the Elixir library to power to backend of a LiveState project. It consists mainly of a Phoenix Channel behaviour

## [phx-live-state](phx-live-state/README.md)

The front end library npm package that allows for elements to send and receive events, and subscribe to state changes.

## [testbed](testbed)

This is a phoenix project that mainly provides integration tests for LiveState.

## Example LiveState projects

* https://github.com/launchscout/live_state_comments
* https://github.com/launchscout/livestate-comments
* https://github.com/launchscout/discord_element
* https://github.com/launchscout/discord-element
