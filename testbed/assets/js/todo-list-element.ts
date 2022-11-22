import { html, css, LitElement } from 'lit'
import { customElement, property, query } from 'lit/decorators.js'
import { liveState, liveStateConfig } from 'phx-live-state';

/**
 * An example element.
 *
 * @slot - This element has a slot
 * @csspart button - The button
 */
@customElement('todo-list')
@liveState({
  topic: "todo:all",
  properties: ['todos'],
  events: {
    send: ['add_todo']
  },
  provide: {
    scope: window,
    name: 'todoLiveState'
  }
})
export class TodoListElement extends LitElement {
  /**
   * Copy for the read the docs hint.
   */
  @property()
  todos: Array<string> | undefined;

  @property()
  @liveStateConfig('url')
  url: string = "foo";
  
  render() {
    return html`
      <div>
        This is my todo list
        <ul>
          ${this.todos?.map(todo => html`<li>${todo}</li>`)}
        </ul>
      </div>
    `
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'todo-list': TodoListElement
  }
}
