import connectElement, { ConnectOptions } from "./connectElement";
import LiveState, { LiveStateConfig } from "./live-state";
import { registerContext, observeContext } from 'wc-context';
import 'reflect-metadata';

export type LiveStateDecoratorOptions = {
  channelName?: string,
  provide?: {
    scope: object,
    name: string | undefined
  },
  context?: string
} & ConnectOptions & LiveStateConfig


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
    const liveState = buildLiveState(element, options);
    connectElement(liveState, element, options);
  }
  return element.liveState;
}

export const extractConfig = (element): LiveStateConfig => {
  const elementConfig = element._liveStateConfig ?
    Object.keys(element._liveStateConfig).reduce((config, key) => {
      if (element._liveStateConfig[key] instanceof Function) {
        const configFn = element._liveStateConfig[key];
        config[key] = configFn.apply(element);
      } else {
        config[key] = element._liveStateConfig[key];
      }
      return config;
    }, {}) : {}
  flattenParams(elementConfig);
  return elementConfig;
}

const flattenParams = (object) => {
  const params = Object.keys(object).filter((key) => key.startsWith('params.')).reduce((params, key) => {
    params[key.replace('params.', '')] = object[key];
    return params;
  }, {});
  object.params = params;
}

export const buildLiveState = (element: any, { url, topic, params }: LiveStateDecoratorOptions) => {
  const elementConfig = extractConfig(element);
  const config = Object.assign({ url, topic, params }, elementConfig);
  return new LiveState(config);
}

export const liveState = (options: LiveStateDecoratorOptions) => {
  return (targetClass: Function) => {
    Reflect.defineMetadata('liveStateConfig', options, targetClass);
    const superConnected = targetClass.prototype.connectedCallback;
    targetClass.prototype.connectedCallback = function () {
      superConnected?.apply(this);
      connectToLiveState(this, options);
    }
    const superDisconnected = targetClass.prototype.disconnectedCallback;
    targetClass.prototype.disconnectedCallback = function () {
      superDisconnected?.apply(this)
      this.liveState && this.liveState.disconnect();
    }
  }
}

export const liveStateConfig = (configProperty) => {
  return (proto, propertyName) => {
    proto._liveStateConfig = proto._liveStateConfig || {};
    proto._liveStateConfig[configProperty] = function() {return this[propertyName]; }
  }
}
export default liveState;
