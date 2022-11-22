import { state } from 'lit/decorators';
import React, { Component } from 'react';
import useLiveState from 'use-live-state';


export const TodoList = () => {

  const [state, pushEvent] = useLiveState(window['liveState'], {});

  return (
    <ul>
      {(state as any).todos && (state as any).todos.map((todo) => <li>{todo}</li>)}
    </ul>
  );
}