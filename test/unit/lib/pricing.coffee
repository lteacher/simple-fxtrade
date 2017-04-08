_ = require 'lodash'
{expect} = require 'chai'
fx = require '../../../'

id = '101-011-5748031-001'

describe 'pricing', ->
  describe 'GET /accounts/:id/pricing', ->
    it 'should throw an error if missing required params', ->
      fx.setAccount id

      expect(-> fx.pricing()).to.throw 'Required parameters missing: instruments'

    it 'should return the pricing for an instrument', ->
      fx.setAccount id

      {prices: [{instrument, type}]} = await fx.pricing instruments: 'AUD_USD'
      expect(instrument).to.be.equal 'AUD_USD'
      expect(type).to.be.equal 'PRICE'

  describe 'GET /accounts/:id/pricing/stream', ->
    it 'should throw an error if missing required params', ->
      fx.setAccount id
      expect(-> fx.pricing.stream()).to.throw 'Required parameters missing: instruments'

    it 'should subscribe to the pricing stream', (done) ->
      fx.setAccount id
      stream = fx.pricing.stream instruments: 'AUD_USD'
      stream.on 'data', ({type}) ->
        expect(type).to.match /PRICE|HEARTBEAT/
        stream.disconnect()
        done()
