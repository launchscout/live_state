import { expect } from "@esm-bundle/chai";
import LiveState from '../src/live-state';
import { connectElement } from "../src";
import { Channel } from 'phoenix';
import sinon from 'sinon';
import { html, LitElement } from 'lit';
import { property, customElement, state } from 'lit/decorators.js';
import { fixture } from '@open-wc/testing';
import { compare } from "fast-json-patch";


describe('LiveState', () => {
  let socketMock, liveState, stubChannel, receiveStub;
  beforeEach(() => {
    liveState = new LiveState({url: "wss://foo.com", topic: "stuff"});
    socketMock = sinon.mock(liveState.socket);
    receiveStub = sinon.stub();
    receiveStub.withArgs("ok", sinon.match.func).returns({receive: receiveStub});

    stubChannel = sinon.createStubInstance(Channel, {
      join: sinon.stub().returns({
        receive: receiveStub
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

  it('sends params from config on channel join', () => {
    liveState.config.params = {bing: 'baz'};
    socketMock.expects('connect').exactly(1);
    socketMock.expects('channel').exactly(1).withArgs('stuff', { bing: 'baz' }).returns(stubChannel);
    liveState.connect();
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
    liveState.subscribe(({ detail: {foo} }) => state.foo = foo);
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
    liveState.subscribe(({detail: newState}) => state = newState);

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
    liveState.subscribe(({detail: newState}) => state = newState);

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

  it('sends errors to subscribers', () => {
    socketMock.expects('connect').exactly(1);
    socketMock.expects('channel').exactly(1).withArgs('stuff').returns(stubChannel);
    liveState.connect();
    const errorHandler = receiveStub.getCall(1).args[1];
    let errorType, source;
    liveState.addEventListener('livestate-error', ({detail: {type, error}}) => {
      errorType = type;
      source = error;
    });
    errorHandler({reason: 'unmatched topic'});
    expect(errorType).to.equal('channel join error');
    expect(source.reason).to.equal('unmatched topic');
  });

});