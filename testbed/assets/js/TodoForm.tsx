import React, { Component, useRef } from 'react';
import useLiveState from 'use-live-state';

export const TodoForm = () => {

  const input = useRef(null);

  const [_state, pushEvent] = useLiveState(window['liveState'], {});

  const onButtonClick = () => {
    pushEvent('add_todo', {todo: input.current.value});
    input.current.value = '';
  };

  return (
    <div>
      <input name="todo" ref={input} />
      <button onClick={onButtonClick}>Add Todo</button>
    </div>
  );
}