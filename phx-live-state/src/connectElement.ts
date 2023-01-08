import LiveState from "./live-state";
import liveState from "./liveStateDecorator";

export type ConnectOptions = {
  properties?: Array<string>;
  attributes?: Array<string>;
  events?: {
    send?: Array<string>,
    receive?: Array<string>
  }
}

const connectElement = (liveState: LiveState, el: HTMLElement, { properties, attributes, events }: ConnectOptions) => {
  if (el['liveState'] !== liveState) {
    liveState.connect();
    liveState.addEventListener('livestate-change', ({detail: state}) => {
      properties?.forEach((prop) => {
        el[prop] = state[prop];
      });
      attributes?.forEach((attr) => {
        el.setAttribute(attr, state[attr]);
      });
    });
    events?.send?.forEach((eventName) => {
      sendEvent(liveState, el, eventName);
    });
    events?.receive?.forEach((eventName) => {
      receiveEvent(liveState, el, eventName);
    });
    el['liveState'] = liveState;
  }
}

const receiveEvent = (liveState: LiveState, el: HTMLElement, eventName: string) => {
  liveState.addEventListener(eventName, ({detail}) => {
    el.dispatchEvent(new CustomEvent(eventName, {detail}));
  });
}

const sendEvent = (liveState: LiveState, el: HTMLElement, eventName: string) => {
  el.addEventListener(eventName, (event) => {
    const {detail} = event as CustomEvent
    liveState.dispatchEvent(new CustomEvent(eventName, {detail}));
  });
}

export default connectElement;