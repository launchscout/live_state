import { state } from 'lit/decorators';
import React, { Component } from 'react';
import { liveState } from './live_state_react';
import useLiveState from 'use-live-state';


export const TodoList = () => {

  const [state, pushEvent] = useLiveState(liveState, {});

  return (
    <ul>
      {(state as any).todos && (state as any).todos.map((todo) => <li>{todo}</li>)}
    </ul>
  );
}