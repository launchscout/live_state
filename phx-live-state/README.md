# phx-live-state

This is a package to help you build embedded micro-front-end applications. It connects to
a server running [LiveState](https://github.com/gaslight/live_state) and sends events and receives state (and possibly other events). 

## Version compatibility

This version, 0.7.0, requires version 0.5.0 of later of the `live_state` elixir library 
due to the addition of version tracking for state.

## Installation

```
npm install phx-live-state
```

## Documentation

See [api docs](docs/index.html)

## LiveState

This established the connection with a LiveState server. The constructor takes a config object containing the following properties:

* url
* topic
* params (passed in during channel join)

It is the default export from LiveState

```javascript
import LiveState from 'phx-live-state';
const liveState = new LiveState({url: 'ws://localhost:4000', topic: 'topicName'});
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
* params - an object which will be passed as parameters when joining the channel
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
* url
* topic
* params
* provide - share this LiveState instance as a context (see below)
  * scope
  * name
* context - connect to an existing LiveState instance (see below)
* properties - passed into `connectElement`
* events - passed into `connectElement`

```typescript
@liveState({
  url: 'http://foo.bar',
  topic: 'discord_chat:new',
  properties: ['messages'],
  events: {
    send: ['new_message', 'start_chat']
  }
})
```

## `liveStateConfig`

This decorator, introduced in version 0.8.0, adds the ability to have live state config properties be contributed by the element instance. They will override values from the `liveState` decorator on the class, if used. 

Example:

```typescript
@customElement('join-params')
@liveState({topic: 'join_params', properties: ['result']})
export class JoinParamsElement extends LitElement {
  
  @property({attribute: 'the-url'})
  @liveStateConfig('url')
  theUrl: string = "foo";
  
  @property({attribute: 'api-key'})
  @liveStateConfig('params.api_key')
  apiKey: string = '';
```

This will cause the `the-url` attribute of the element to be used as the url to connect to, and the `api-key` attribute to be passed as an `api_key` parameter to the channel join.

### Context

As of 0.7.0, we now support sharing LiveState instances via a context. The way this works is that one element will provide an instance like so:

```typescript
@liveState({
  channelName: "todo:all",
  properties: ['todos'],
  events: {
    send: ['add_todo']
  },
  provide: {
    scope: window,
    name: 'todoLiveState'
  }
})
```

This will cause the LiveState instance to be set on the `window` as `todoLiveState`. An element that wishes to connect to an existing LiveState instance uses the context property:

```typescript
@liveState({
  events: {
    send: ['add_todo']
  },
  context: 'todoLiveState'
})
```

This will find an instance with the specified name (in any scope). This will be handled regardless of order, if the consuming instance is created first a queue of consumers will be created that will be resolved and attached when the providing instance is created.

## Example

It's easiest to understand all this by example. Take a look at the following example projects:

* https://github.com/launchscout/livestate-comments
* https://github.com/launchscout/live_state_comments
* https://github.com/launchscout/discord_element
* https://github.com/launchscout/discord-element
