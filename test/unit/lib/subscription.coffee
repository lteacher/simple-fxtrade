{EventEmitter} = require 'events'
{expect} = require 'chai'
Subscription = require '../../../lib/subscription'

class MockEmitter extends EventEmitter
  constructor: ->
    super()

    @req = abort: => @emit 'end', 'its done!'

describe 'Subscription', ->
  describe '#constructor', ->
    it 'should construct a new Subscription', ->
      sub = new Subscription

      expect(sub).to.be.instanceof EventEmitter
      expect(sub).to.be.instanceof Subscription

    it 'should construct a new Subscription with a given stream and options', ->
      sub = new Subscription new MockEmitter, json: true

      expect(sub.stream).to.be.ok
      expect(sub.options.json).to.be.ok


  describe '#on error', ->
    it 'should pass through and emit on error', (done) ->
      emitter = new MockEmitter
      sub = new Subscription emitter
      sub.on 'error', (message) ->
        expect(message).to.be.equal 'Stuff failed'
        done()

      emitter.emit 'error', 'Stuff failed'

  describe '#on data', ->
    it 'should pass through and convert the json', (done) ->
      emitter = new MockEmitter
      sub = new Subscription emitter, json: true
      sub.on 'data', (data) ->
        expect(data).to.be.eql stuff: 'worked'
        expect(sub.connected).to.be.ok
        done()

      emitter.emit 'data', '{"stuff":"worked"}'

  describe '#on end / disconnect', ->
    it 'should disconnect the subscription', (done) ->
      emitter = new MockEmitter
      sub = new Subscription emitter, json: true
      sub.on 'end', (data) ->
        expect(data).to.be.equal 'its done!'
        expect(sub.connected).to.not.be.ok
        done()
      sub.disconnect()
