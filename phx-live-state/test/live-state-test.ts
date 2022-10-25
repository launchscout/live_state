import { expect } from "@esm-bundle/chai";
import LiveState from '../src/live-state';
import { connectElement } from "../src";
import { Channel } from 'phoenix';
import sinon from 'sinon';
import { html, LitElement } from 'lit';
import { property, customElement, state } from 'lit/decorators.js';
import { fixture } from '@open-wc/testing';
import { compare } from "fast-json-patch";

@customElement('test-element')
class TestElement extends LitElement {
  @property() foo: string;
  @state() bar: string;

  render() {
    return html`<div>${this.foo} ${this.bar}</div>`
  }
}

describe('LiveState', () => {
  let socketMock, liveState, stubChannel;
  beforeEach(() => {
    liveState = new LiveState("wss://foo.com", "stuff");
    socketMock = sinon.mock(liveState.socket);
    stubChannel = sinon.createStubInstance(Channel, {
      join: sinon.stub().returns({
        receive: sinon.stub()
      }),
      on: sinon.spy(),
      push: sinon.spy()
    });
  });

  it('connects to a socket and channel', () => {
    socketMock.expects('connect').exactly(1);
    socketMock.expects('channel').exactly(1).withArgs('stuff', { foo: 'bar' }).returns(stubChannel);
    liveState.connect({ foo: 'bar' });
    socketMock.verify();
  });

  it('does not connect if already connected', () => {
    socketMock.expects('connect').exactly(1);
    socketMock.expects('channel').exactly(1).withArgs('stuff', { foo: 'bar' }).returns(stubChannel);
    liveState.connect({ foo: 'bar' });
    liveState.connect({ foo: 'bar' });
    socketMock.verify();
  });

  it('notifies subscribers', () => {
    socketMock.expects('connect').exactly(1);
    socketMock.expects('channel').exactly(1).withArgs('stuff', { foo: 'bar' }).returns(stubChannel);
    liveState.connect({ foo: 'bar' });
    let state = { foo: 'bar' };
    liveState.subscribe(({ foo }) => state.foo = foo);
    expect(liveState.channel.on.callCount).to.equal(2)
    const onArgs = liveState.channel.on.getCall(0).args;
    expect(onArgs[0]).to.equal("state:change");
    const onHandler = onArgs[1];
    onHandler({state: { foo: 'wuzzle' }, version: 0});
    expect(state.foo).to.equal('wuzzle');
    expect(liveState.stateVersion).to.equal(0);
    socketMock.verify();
  });

  it('understands jsonpatch for state changes', () => {
    const initialState = { foo: "bar" };
    const newState = { foo: "baz", bing: [1, 2] };
    const patch = compare(initialState, newState);
    socketMock.expects('connect').exactly(1);
    socketMock.expects('channel').exactly(1).returns(stubChannel);
    liveState.connect({ foo: 'bar' });
    let state = {};
    liveState.subscribe((newState) => state = newState);

    const onChangeArgs = liveState.channel.on.getCall(0).args;
    expect(onChangeArgs[0]).to.equal("state:change");
    const onChangeHandler = onChangeArgs[1];
    onChangeHandler({state: initialState, version: 0});

    const onPatchArgs = liveState.channel.on.getCall(1).args;
    expect(onPatchArgs[0]).to.equal("state:patch");
    const onPatchHandler = onPatchArgs[1];
    onPatchHandler({patch, version: 1});

    expect(state).to.deep.equal(newState);
  });

  it('requests new state when receiving patch with incorrect version', () => {
    const initialState = { foo: "bar" };
    const newState = { foo: "baz", bing: [1, 2] };
    const patch = compare(initialState, newState);
    socketMock.expects('connect').exactly(1);
    socketMock.expects('channel').exactly(1).returns(stubChannel);
    liveState.connect({ foo: 'bar' });
    let state = {};
    liveState.subscribe((newState) => state = newState);

    const onChangeArgs = liveState.channel.on.getCall(0).args;
    expect(onChangeArgs[0]).to.equal("state:change");
    const onChangeHandler = onChangeArgs[1];
    onChangeHandler({state: initialState, version: 0});

    const onPatchArgs = liveState.channel.on.getCall(1).args;
    expect(onPatchArgs[0]).to.equal("state:patch");
    const onPatchHandler = onPatchArgs[1];
    onPatchHandler({patch, version: 2});

    expect(state).to.deep.equal(initialState);
    const pushCall = liveState.channel.push.getCall(0);
    expect(pushCall.args[0]).to.equal('lvs_refresh');
  });

  it('disconnects', () => {
    socketMock.expects('disconnect').exactly(1)
    liveState.disconnect();
    socketMock.verify();
  });

  it('pushes custom events over the channel', () => {
    socketMock.expects('connect').exactly(1);
    socketMock.expects('channel').exactly(1).withArgs('stuff').returns(stubChannel);
    liveState.connect();
    liveState.pushCustomEvent(new CustomEvent('sumpinhappend', { detail: { foo: 'bar' } }));
    const pushCall = liveState.channel.push.getCall(0);
    expect(pushCall.args[0]).to.equal('lvs_evt:sumpinhappend');
    expect(pushCall.args[1]).to.deep.equal({ foo: 'bar' });
  });

  it('pushes non custom event events over the channel', () => {
    socketMock.expects('connect').exactly(1);
    socketMock.expects('channel').exactly(1).withArgs('stuff').returns(stubChannel);
    liveState.connect();
    liveState.pushEvent('sumpinhappend', { foo: 'bar' });
    const pushCall = liveState.channel.push.getCall(0);
    expect(pushCall.args[0]).to.equal('lvs_evt:sumpinhappend');
    expect(pushCall.args[1]).to.deep.equal({ foo: 'bar' });
  });

  describe('connectElement', () => {
    beforeEach(() => {
      socketMock.expects('connect').exactly(1);
      socketMock.expects('channel').exactly(1).withArgs('stuff').returns(stubChannel);
    });

    it('updates on state changes', async () => {
      const el: TestElement = await fixture('<test-element></test-element>');
      connectElement(liveState, el, {
        properties: ['bar'],
        attributes: ['foo']
      });
      const stateChange = liveState.channel.on.getCall(0).args[1];
      stateChange({state: { foo: 'wuzzle', bar: 'wizzle' }, version: 1});
      await el.updateComplete;
      expect(el.bar).to.equal('wizzle');
      expect(el.shadowRoot.innerHTML).to.contain('wizzle');
      expect(el.getAttribute('foo')).to.equal('wuzzle');
      expect(el.shadowRoot.innerHTML).to.contain('wuzzle');
    });

    it('sends events', async () => {
      const el: TestElement = await fixture('<test-element></test-element>');
      connectElement(liveState, el, {
        properties: ['bar'],
        attributes: ['foo'],
        events: {
          send: ['sayHi']
        }
      });
      el.dispatchEvent(new CustomEvent('sayHi', { detail: { greeting: 'wazzaap' } }));
      expect(liveState.channel.push.callCount).to.equal(1);
      const pushCall = liveState.channel.push.getCall(0);
      expect(pushCall.args[0]).to.equal('lvs_evt:sayHi');
      expect(pushCall.args[1]).to.deep.equal({ greeting: 'wazzaap' });
    });

    it('connects idempotently', async () => {
      const el: TestElement = await fixture('<test-element></test-element>');
      connectElement(liveState, el, {
        properties: ['bar'],
        attributes: ['foo'],
        events: {
          send: ['sayHi']
        }
      });
      connectElement(liveState, el, {
        properties: ['bar'],
        attributes: ['foo'],
        events: {
          send: ['sayHi']
        }
      });
      el.dispatchEvent(new CustomEvent('sayHi', { detail: { greeting: 'wazzaap' } }));
      expect(liveState.channel.push.callCount).to.equal(1);
    });

    it('receives events', async () => {
      const el: TestElement = await fixture('<test-element></test-element>');
      connectElement(liveState, el, {
        properties: ['bar'],
        attributes: ['foo'],
        events: {
          send: ['sayHi'],
          receive: ['sayHiBack']
        }
      });
      const onArgs = liveState.channel.on.getCall(2).args;
      expect(onArgs[0]).to.equal("sayHiBack")
      const onHandler = onArgs[1];
      let eventDetail;
      el.addEventListener('sayHiBack', ({ detail }: CustomEvent) => { eventDetail = detail });
      onHandler({ foo: 'bar' })
      expect(eventDetail).to.deep.equal({ foo: 'bar' });
    });
  });

});