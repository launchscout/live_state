import LiveState from 'phx-live-state';
import React from 'react';
import { createRoot } from 'react-dom/client';

import { TodoList } from './TodoList';
import { TodoForm } from './TodoForm';

window.addEventListener('DOMContentLoaded', (event) => {
  const reactContainer = document.getElementById('react-root');
  if (reactContainer) {
    window['liveState'] = new LiveState({url: 'ws://localhost:4002/socket', topic: 'todo:all'});
    const root = createRoot(reactContainer);
    root.render(
      <>
        <TodoList />
        <TodoForm />
      </>
    );
  }
});
