import {LitElement, ReactiveController, ReactiveControllerHost} from 'lit';
import LiveState from './live-state';

type Options = {
  url?: string,
  channel?: string,
  connectParams?: object,
  properties?: Array<string>,
  events?: {
    send: Array<string>,
    receive: Array<string>
  }
}

export class LiveStateController implements ReactiveController {

  host: LitElement;

  liveState: LiveState;

  options: Options;

  state: any;

  constructor(host: LitElement, options: Options) {
    this.host = host;
    this.options = options;
    host.addController(this)
  }

  hostConnected() {
    this.liveState = new LiveState(
      (this.host as any).url || this.options.url, 
      (this.host as any).channel || this.options.channel
    );
    this.liveState.connect(this.options.connectParams);
    this.liveState.subscribe((state: any) => {
      this.state = state;
      this.options.properties.forEach((prop) => {
        this.host[prop] = this.state[prop];
      });
      this.host.requestUpdate();
    });
    this.options.events?.send?.forEach((eventName) => {
      this.host.addEventListener(eventName, (customEvent: CustomEvent) => this.liveState.pushCustomEvent(customEvent));
    });
    this.options.events?.receive?.forEach((eventName) => {
      this.liveState.channel.on(eventName, (event) => {
        this.host.dispatchEvent(new CustomEvent(eventName, {detail: event}));
      });
    })
  }

  hostDisconnected() {
    this.liveState?.disconnect();
  }
}
