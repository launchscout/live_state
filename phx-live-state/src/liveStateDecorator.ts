import connectElement, { ConnectOptions } from "./connectElement";
import LiveState from "./live-state";
import { registerContext, observeContext } from 'wc-context';

export type LiveStateDecoratorOptions = {
  channelName?: string,
  url?: string,
  provide?: {
    scope: object,
    name: string | undefined
  },
  context?: string
} & ConnectOptions

const connectToLiveState = (element: any, options: LiveStateDecoratorOptions) => {
  if (options.provide) {
    const { scope, name } = options.provide;
    const liveState = scope[name] ? scope[name] :
      scope[name] = buildLiveState(element, options);
    registerContext(scope, name, liveState)
    connectElement(liveState, element, options as any);
  } else if (options.context) {
    observeContext(element, options.context, element, (element, liveState) => {
      connectElement(liveState, element, options as any);
    });
  } else {
    element.liveState = buildLiveState(element, options)
  }
  return element.liveState;
}

const buildLiveState = (element: any, options: LiveStateDecoratorOptions) => {
  return new LiveState({url: options.url || element.url, topic: options.channelName || element.channelName});
}

const liveState = (options: LiveStateDecoratorOptions) => {
  return (targetClass: Function) => {
    const superConnected = targetClass.prototype.connectedCallback;
    targetClass.prototype.connectedCallback = function () {
      superConnected.apply(this);
      connectToLiveState(this, options);
    }
    const superDisconnected = targetClass.prototype.disconnectedCallback;
    targetClass.prototype.disconnectedCallback = function () {
      console.log('disconnecting...');
      superDisconnected.apply(this)
      this.liveState && this.liveState.disconnect();
    }
  }
}

export default liveState;
