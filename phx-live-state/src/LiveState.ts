import { applyPatch } from 'json-joy/esm/json-patch';
import { Socket, Channel } from "phoenix";

export type LiveStateConfig = {

  /** The end point to connect to, should be a websocket url (ws or wss) */
  url?: string,

  /** The topic for the channel */
  topic?: string,

  /** will be sent as params on channel join */
  params?: object
}

export type LiveStateError = {
  /**
   * Describes what type of error occurred. 
   */
  kind: string;

  /** The original error payload, type depends on error */
  error: any;
}

export type LiveStateChange = {

  /** state version as known by the channel */
  version: number;
  
  state: object;
}

export type LiveStatePatch = {

  /** the version this patch is valid for  */
  version: number;

  /** the json patch to be applied */
  patch: any;
}

/**
 * This is the lower level API for LiveState. It connects to a 
 * [live_state]() channel over websockets and is responsible 
 * for maintaining the state. From the channel it receives `state:change` events which 
 * replace the state entirely, or `state:patch` events which contain a json 
 * patch to be applied.
 * 
 * ## Events
 * 
 * ### Dispatching
 * A `CustomEvent` dispatched to LiveState will be pushed over the channel as 
 * event with the `lvs_evt:` prefix and the detail property will become the payload
 * 
 * ### Listeners
 * 
 * Events which begin with `livestate-` are assumed to be livestate internal events.
 * The following CustomEvents are supported:
 * 
 * | Error             | Detail type             | Description                          |
 * | ----------------- | ----------------------- | ------------------------------------ |
 * | livestate-error   | {@link LiveStateError}  | Occurs on channel or socket errors   |
 * | livestate-change  | {@link LiveStateChange} | on `state:change` from channel       |
 * | livestate-patch   | {@link LiveStatePatch}  | on `state:patch` from channel        |
 * | livestate-connect | none                    | on successful socket or channel join |
 * 
 * Will occur on channel or socket errors. The `detail` will consist of 
 * 
 * And other event name not prefixed with `livestate-` will be assumed to be a channel
 * event and will result in a event being listened to on the channel, which when
 * received, will be dispatched as a CustomEvent of the same name with the payload 
 * from the channel event becoming the `detail` property.
 */
export class LiveState implements EventTarget {
  config: LiveStateConfig;
  channel: Channel;
  socket: Socket;
  state: any;
  stateVersion: number;
  connected: boolean = false;
  eventTarget: EventTarget;

  constructor(config: LiveStateConfig) {
    this.config = config;
    this.socket = new Socket(this.config.url, { logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}`, data) }) });
    this.channel = this.socket.channel(this.config.topic, this.config.params);
    this.eventTarget = new EventTarget();
  }

  /** connect to socket and join channel. will do nothing if already connected */
  connect() {
    if (!this.connected) {
      this.socket.onError((e) => this.emitError('socket error', e));
      this.socket.connect();
      this.channel.onError((e) => console.log('channel error', e));
      this.channel.join().receive("ok", () => {
        console.log('joined');
      }).receive('error', (e) => {
        this.emitError('channel join error', e)
      });
      this.channel.on("state:change", (state) => this.handleChange(state));
      this.channel.on("state:patch", (patch) => this.handlePatch(patch));
      this.connected = true;
    }
  }

  /** leave channel and disconnect from socket */
  disconnect() {
    this.channel && this.channel.leave();
    this.socket.disconnect();
    this.connected = false;
  }

  /** for events that begin with 'livestate-', add a listener. For
   * other events, additionally call `channel.on` to receive the event 
   * over the channel, which will then be dispatched.
   */
  addEventListener(type, listener, options?) {
    this.eventTarget.addEventListener(type, listener, options);
    if (!type.startsWith('livestate-')) {
      this.channel?.on(type, (payload) => {
        this.eventTarget.dispatchEvent(new CustomEvent(type, {detail: payload}));
      });      
    }
  }

  removeEventListener(type, listener, options?) {
    return this.eventTarget.removeEventListener(type, listener, options);
  }

  /** @deprecated */
  subscribe(subscriber: Function) {
    this.addEventListener('livestate-change', subscriber);
  }

  /** @deprecated */
  unsubscribe(subscriber) {
    this.removeEventListener('livestate-change', subscriber);
  }

  emitError(kind, error) {
    this.eventTarget.dispatchEvent(new CustomEvent<LiveStateError>('livestate-error', {
      detail: {
        kind, error
      }
    }))
  }

  handleChange({ state, version }) {
    this.state = state;
    this.stateVersion = version;
    this.eventTarget.dispatchEvent(new CustomEvent<LiveStateChange>('livestate-change', {
      detail: {
        state: this.state,
        version: this.stateVersion
      }
    }));
  }

  handlePatch({ patch, version }) {
    this.eventTarget.dispatchEvent(new CustomEvent<LiveStatePatch>('livestate-patch', {
      detail: {patch, version}
    }));
    if (version === this.stateVersion + 1) {
      const { doc, res } = applyPatch(this.state, patch, { mutate: false });
      this.state = doc;
      this.stateVersion = version;
      this.eventTarget.dispatchEvent(new CustomEvent<LiveStateChange>('livestate-change', {
        detail: {
          state: this.state,
          version: this.stateVersion
        }
      }));
    } else {
      this.channel.push('lvs_refresh');
    }
  }

  pushEvent(eventName, payload) {
    this.dispatchEvent(new CustomEvent(eventName, {detail: payload}));
  }

  /** Pushes the event over the channel, adding the `lvs_evt:` prefix and using the CustomEvent
   * detail property as the payload
   */
  dispatchEvent(event: Event) {
    this.channel.push(`lvs_evt:${event.type}`, (event as CustomEvent).detail);
    return true;
  }

  pushCustomEvent(event) { this.dispatchEvent(event); }
}

export default LiveState;

