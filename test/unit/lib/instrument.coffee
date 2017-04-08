_ = require 'lodash'
{expect} = require 'chai'
fx = require '../../../'

id = '101-011-5748031-001'

describe 'instruments (candles)', ->
  describe 'GET /instruments/:accountId/candles', ->
    it 'should throw an error if missing required params', ->
      fx.setAccount id

      expect(-> fx.candles()).to.throw 'Required parameters missing: id'

    it 'should return the candles for a given instrument', ->
      fx.setAccount id

      {granularity, candles, instrument} = await fx.candles id: 'AUD_USD'
      expect(instrument).to.be.equal 'AUD_USD'
      expect(granularity).to.be.equal 'S5'
      expect(_.size candles).to.be.equal 500
