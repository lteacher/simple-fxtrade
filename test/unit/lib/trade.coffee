_ = require 'lodash'
{expect} = require 'chai'
fx = require '../../../'

id = '101-011-5748031-001'

describe 'trades', ->
  describe 'GET /accounts/:accountId/trades[/:id]', ->
    # TODO: Need to return actual trades
    it 'should throw an error if missing required params', ->
      fx.setAccount id

      {trades} = await fx.trades()
      expect(trades).to.be.ok
