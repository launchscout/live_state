import LiveState from 'phx-live-state';
import { useState, useEffect } from 'react';

const useLiveState = (liveState: LiveState, intialState: any) => {
  const [state, setState] = useState(intialState);
  useEffect(() => {
    liveState.connect();
    const handleStateChange = ({detail: state}) => setState(state);
    liveState.addEventListener('livestate-change', handleStateChange);
    return () => {
      liveState.removeEventListener('livestate-change', handleStateChange);
    };
  });

  const pushEvent = (event, payload) => {
    liveState.pushEvent(event, payload);
  }

  return [state, pushEvent];
}

export default useLiveState