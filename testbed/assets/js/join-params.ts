import { html, css, LitElement } from 'lit'
import { customElement, property, query } from 'lit/decorators.js'
import { liveState, liveStateConfig } from 'phx-live-state';

/**
 * An example element.
 *
 * @slot - This element has a slot
 * @csspart button - The button
 */
@customElement('join-params')
@liveState({topic: 'join_params', properties: ['result']})
export class JoinParamsElement extends LitElement {
  
  @property({attribute: 'the-url'})
  @liveStateConfig('url')
  theUrl: string = "foo";
  
  @property({attribute: 'api-key'})
  @liveStateConfig('params.api_key')
  apiKey: string = '';

  @property()
  // @liveStateProperty()
  result: string = '';

  render() {
    return html`
      <div>
        ${this.result}
      </div>
    `
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'join-params': JoinParamsElement
  }
}
