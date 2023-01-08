import { applyPatch } from 'json-joy/esm/json-patch';
import { Socket, Channel } from "phoenix";

export type LiveStateConfig = {
  url?: string,
  topic?: string,
  params?: object
}

export class LiveState {
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
    this.eventTarget = new EventTarget();
  }

  connect(params?) {
    if (!this.connected) {
      this.socket.onError((e) => this.emitError('socket error', e));
      this.socket.connect();
      this.channel = this.socket.channel(this.config.topic, params || this.config.params);
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

  disconnect() {
    this.channel && this.channel.leave();
    this.socket.disconnect();
  }

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

  subscribe(subscriber: Function) {
    this.addEventListener('livestate-change', subscriber);
  }

  unsubscribe(subscriber) {
    this.removeEventListener('livestate-change', subscriber);
  }

  emitError(type, error) {
    this.eventTarget.dispatchEvent(new CustomEvent('livestate-error', {
      detail: {
        type, error
      }
    }))
  }

  handleChange({ state, version }) {
    this.state = state;
    this.stateVersion = version;
    this.eventTarget.dispatchEvent(new CustomEvent('livestate-change', {detail: this.state}));
  }

  handlePatch({ patch, version }) {
    if (version === this.stateVersion + 1) {
      const { doc, res } = applyPatch(this.state, patch, { mutate: false });
      this.state = doc;
      this.stateVersion = version;
      this.eventTarget.dispatchEvent(new CustomEvent('livestate-change', {detail: this.state}));
      this.eventTarget.dispatchEvent(new CustomEvent('livestate-patch', {detail: patch}));
    } else {
      this.channel.push('lvs_refresh');
    }
  }

  pushEvent(eventName, payload) {
    this.dispatchEvent(new CustomEvent(eventName, {detail: payload}));
  }

  dispatchEvent(event: CustomEvent) {
    this.channel.push(`lvs_evt:${event.type}`, event.detail);
  }

  pushCustomEvent(event) { this.dispatchEvent(event); }
}

export default LiveState;

