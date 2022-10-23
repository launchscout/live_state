# phx-live-state

This is a package to help you build embedded micro-front-end applications. It connects to
a server running [LiveState](https://github.com/gaslight/live_state) and sends events and receives state (and possibly other events). 

## Version compatibility

This version, 0.5.0, requires version 0.5.0 of later of the `live_state` elixir library 
due to the addition of version tracking for state.

## Installation

```
npm install phx-live-state
```

## Usage

## LiveState

This established the connection with a LiveState server. The constructor takes two arguments:

* url
* channel name

It is the default export from LiveState

```javascript
import LiveState from 'phx-live-state';
const liveState = new LiveState('ws://localhost:4000', 'channelName');
```

## connectElement

```javascript
import { connectElement } from 'phx-live-state';
```

This is a function designed to connect an HTML Element with livestate and takes the following arguments:

* liveState - a LiveState instance
* el - an HTMLElement
* options

The options object allows the following properties:

* properties - A list of properties managed by LiveState. These will be updated any time a state property of the same name changes.
* attributes 
* events - A list of attributes managed by LiveState. These will be updated any time a state property of the same name changes.
  * send - events to listen to on the element and send to the LiveState server. They are expected to be CustomEvents with a detail, which will be sent as the payload
  * receive - events that can be pushed from the LiveState server and will then be dispatched as a CustomEvent of the same name on the element

## `@liveState()` decorator

This typescript class decorator will:
* Adds a `connectedCallback` method that sets a `liveState` property and calls `connectElement`
* Adds a `disconnectedCallback` method that calls `disconnect` on the `liveState` instance

Both will call inherited callbacks.

The decorator expects to passed an object with the following properties, all of which
are optional:
* url (defaults to `this.url` if not passed)
* channelName (defaults to `this.channelName` if not passed)
* shared - pass true to use shared `LiveState` instance on `window.__liveState`. Will create and set if not found
* properties - passed into `connectElement`
* events - passed into `connectElement`

```typescript
@liveState({
  channelName: 'discord_chat:new',
  properties: ['messages'],
  events: {
    send: ['new_message', 'start_chat']
  }
})
```

## Example

It's easiest to understand all this by example. Take a look at the following example projects:

* https://github.com/launchscout/livestate-comments
* https://github.com/launchscout/live_state_comments
* https://github.com/launchscout/discord_element
* https://github.com/launchscout/discord-element
