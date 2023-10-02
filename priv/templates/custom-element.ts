import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { liveState, liveStateConfig } from 'phx-live-state';

@customElement('<%= tag_name %>')
@liveState({
  topic: '<%= channel_name %>:all'
})
export class <%= element_class %> extends LitElement {

  @liveStateConfig('url')
  @property()
  url: string = '';

  render() {
    return html`<h1>Hello there!</h1>`
  }
}