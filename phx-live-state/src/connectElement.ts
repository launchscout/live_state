import LiveState from "./LiveState";
import liveState from "./liveStateDecorator";

export type ConnectOptions = {
  properties?: Array<string>;
  attributes?: Array<string>;
  events?: {
    send?: Array<string>,
    receive?: Array<string>
  }
}

export const connectElement = (liveState: LiveState, el: HTMLElement, { properties, attributes, events }: ConnectOptions) => {
  if (el['liveState'] !== liveState) {
    liveState.connect();
    properties?.forEach((p) => connectProperty(liveState, el, p));
    attributes?.forEach((attr) => connectAtttribute(liveState, el, attr));
    events?.send?.forEach((eventName) => sendEvent(liveState, el, eventName));
    events?.receive?.forEach((eventName) => receiveEvent(liveState, el, eventName));
    el['liveState'] = liveState;
  }
}

export const connectProperty = (liveState: LiveState, el: HTMLElement, propertyName: string) => {
  liveState.addEventListener('livestate-change', ({ detail: state }) => {
    el[propertyName] = state[propertyName];
  });
}

export const connectAtttribute = (liveState: LiveState, el: HTMLElement, attr: string) => {
  liveState.addEventListener('livestate-change', ({ detail: state }) => {
    el.setAttribute(attr, state[attr]);
  });
}

export const receiveEvent = (liveState: LiveState, el: HTMLElement, eventName: string) => {
  liveState.addEventListener(eventName, ({ detail }) => {
    el.dispatchEvent(new CustomEvent(eventName, { detail }));
  });
}

export const sendEvent = (liveState: LiveState, el: HTMLElement, eventName: string) => {
  el.addEventListener(eventName, (event) => {
    const { detail } = event as CustomEvent
    liveState.dispatchEvent(new CustomEvent(eventName, { detail }));
  });
}

export default connectElement;