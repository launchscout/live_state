import LiveState from 'phx-live-state';
import { useState, useEffect } from 'react';

const useLiveState = (liveState: LiveState, intialState: any) => {
  const [state, setState] = useState(intialState);
  useEffect(() => {
    liveState.connect({});
    const subscription = liveState.subscribe((state) => setState(state));
    return () => {
      liveState.unsubscribe(subscription);
    };
  });

  const pushEvent = (event, payload) => {
    liveState.pushEvent(event, payload);
  }

  return [state, pushEvent];
}

export default useLiveState