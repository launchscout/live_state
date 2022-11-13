# use-lives-state

This package provides a lil tiny react hook to facilitate React components that have their state managed by LiveState.

## Usage

Add it just like any npm:

```
npm install use-live-state
```

Make a LiveState instance:

```typescript
import LiveState from "phx-live-state";

export const liveState = new LiveState('ws://localhost:4002/socket', 'todo:all');
```

Then, in your components:

```typescript
import React, { Component } from 'react';
import { liveState } from './live_state';
import useLiveState from 'use-live-state';


export const TodoList = () => {

  const [state, _pushEvent] = useLiveState(liveState, {});

  return (
    <ul>
      {(state as any).todos && (state as any).todos.map((todo) => <li>{todo}</li>)}
    </ul>
  );
}
```

```typescript
import React, { Component, useRef } from 'react';
import { liveState } from './live_state_react';
import useLiveState from 'use-live-state';

export const TodoForm = () => {

  const input = useRef(null);

  const [_state, pushEvent] = useLiveState(liveState, {});

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
```

To see an example project of how all this fits together, check out https://github.com/launchscout/live_state/tree/main/testbed

