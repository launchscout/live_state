import { liveState, extractConfig, liveStateConfig } from '../src/liveStateDecorator';
import { fixture } from '@open-wc/testing';
import { customElement } from 'lit/decorators.js';
import { expect } from '@esm-bundle/chai';

class InstanceDecorated {

  @liveStateConfig('topic')
  blarg: string = 'stuff';

  @liveStateConfig('params.foo')
  yadda: string = 'other stuff';
}

describe('liveStateConfig', () => {
  it('adds instance config', () => {
    const instanceDecorated = new InstanceDecorated();
    const config = extractConfig(instanceDecorated);
    expect(config.topic).to.eql('stuff');
    expect(config.params['foo']).to.eql('other stuff'); 
  });
});