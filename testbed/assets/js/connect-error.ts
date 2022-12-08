import { html, css, LitElement } from 'lit'
import { customElement, property, query, state } from 'lit/decorators.js'
import { liveState, liveStateConfig } from 'phx-live-state';

/**
 * An example element.
 *
 * @slot - This element has a slot
 * @csspart button - The button
 */
@customElement('connect-error')
@liveState({topic: 'garbage', url: 'ws://localhost:4001/socket'})
export class ConnectErrorElement extends LitElement {
  
  constructor() {
    super();
    this.addEventListener('livestate:error', (e: CustomEvent<{type: string}>) => {
      this.errorDescription = e.detail.type;
    })
  }

  @state()
  errorDescription = '';

  render() {
    return html`
      <div>
        ${this.errorDescription}
      </div>
    `
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'connect-error': ConnectErrorElement
  }
}

declare global {
  interface HTMLElementEventMap {
    'livestate:error': CustomEvent<{ type: string, source: object }>;
  }
}