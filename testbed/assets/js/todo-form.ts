import { html, css, LitElement } from 'lit'
import { customElement, property, query } from 'lit/decorators.js'
import { liveState } from 'phx-live-state';

/**
 * An example element.
 *
 * @slot - This element has a slot
 * @csspart button - The button
 */
@customElement('todo-form')
@liveState({
  events: {
    send: ['add_todo']
  },
  context: 'todoLiveState'
})
export class TodoFormElement extends LitElement {

  @query("input[name='todo']")
  todoInput: HTMLInputElement | undefined;

  render() {
    return html`
      <div>
        <input name="todo" />
        <button @click=${this.addTodo}>Add Todo</button>
      </div>
    `
  }

  addTodo(_event : Event) {
    this.dispatchEvent(new CustomEvent('add_todo', {detail: {todo: this.todoInput!.value}}));
    this.todoInput!.value = '';
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'todo-form': TodoFormElement
  }
}
