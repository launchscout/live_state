import LiveState from "phx-live-state";

export const liveState = new LiveState('ws://localhost:4002/socket', 'todo:all');

