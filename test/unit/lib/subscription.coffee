{EventEmitter} = require 'events'
{expect} = require 'chai'
td = require 'testdouble'
Subscription = require '../../../lib/subscription'

class MockEmitter extends EventEmitter
  constructor: ->
    super()

    @req = abort: => @emit 'end', 'its done!'

describe 'Subscription', ->
  emitter = null

  beforeEach -> emitter = new MockEmitter

  describe '#constructor', ->
    it 'should construct a new Subscription', ->
      sub = new Subscription

      expect(sub).to.be.instanceof EventEmitter
      expect(sub).to.be.instanceof Subscription

    it 'should construct a new Subscription with a given stream and options', ->
      sub = new Subscription emitter, json: true

      expect(sub.stream).to.be.ok
      expect(sub.options.json).to.be.ok


  describe '#on error', ->
    it 'should pass through and emit on error', (done) ->
      sub = new Subscription emitter
      sub.on 'error', (message) ->
        expect(message).to.be.equal 'Stuff failed'
        done()

      emitter.emit 'error', 'Stuff failed'

  describe '#on data', ->
    it 'should pass through and convert the json', (done) ->
      sub = new Subscription emitter, json: true
      sub.on 'data', (data) ->
        expect(data).to.be.eql stuff: 'worked'
        expect(sub.connected).to.be.ok
        done()

      emitter.emit 'data', '{"stuff":"worked"}'

    it 'should not explode if the data is empty and no event should be emitted', (done) ->
      sub = new Subscription emitter, json: true
      handler = td.func()
      sub.on 'data', handler
      sub.on 'end', ->
        expect(td.explain(handler).callCount).to.equal 0
        done()

      emitter.emit 'data', Buffer.from ''
      sub.disconnect()

    it 'should handle messages with multiple JSON entries in the buffer and empty whitespacing', (done) ->
      sub = new Subscription emitter, json: true
      handler = td.func()
      sub.on 'data', handler
      sub.on 'end', ->
        expect(td.explain(handler).callCount).to.equal 2
        td.verify handler stuff: 'worked'
        td.verify handler another: 'random message'
        done()

      emitter.emit 'data', '\r\n
        {"stuff":"worked"}\n
        {"another": "random message"}
      '
      sub.disconnect()


  describe '#on end / disconnect', ->
    it 'should disconnect the subscription', (done) ->
      sub = new Subscription emitter, json: true
      sub.on 'end', (data) ->
        expect(data).to.be.equal 'its done!'
        expect(sub.connected).to.not.be.ok
        done()
      sub.disconnect()
