import LiveState from "./live-state";

export type ConnectOptions = {
  properties?: Array<string>;
  attributes?: Array<string>;
  events?: {
    send?: Array<string>,
    receive?: Array<string>
  },
}

const connectElement = (liveState: LiveState, el: HTMLElement, { properties, attributes, events }: ConnectOptions) => {
  if (el['liveState'] !== liveState) {
    liveState.connect();
    liveState.subscribe((state: any) => {
      properties?.forEach((prop) => {
        el[prop] = state[prop];
      });
      attributes?.forEach((attr) => {
        el.setAttribute(attr, state[attr]);
      });
    });
    events?.send?.forEach((eventName) => {
      el.addEventListener(eventName, (customEvent: CustomEvent) => {
        console.log(el);
        console.log(`sending ${eventName}`);
        liveState.pushCustomEvent(customEvent)
      });
    });
    events?.receive?.forEach((eventName) => {
      liveState.channel.on(eventName, (event) => {
        el.dispatchEvent(new CustomEvent(eventName, { detail: event }));
      });
    });
    el['liveState'] = liveState;
  }
}

export default connectElement;