_ = require 'lodash'
{expect} = require 'chai'
fx = require '../../../'

id = '101-011-5748031-001'

describe 'accounts', ->
  describe 'POST /accounts/:accountId/orders', ->
    it 'should throw an error if missing required params', ->
      fx.setAccount id
      expect(-> fx.orders.create()).to.throw(
        'Required parameters missing: order'
      )

    it.skip 'should create an order', ->
      fx.setAccount id

      result = await fx.orders.create order: {
        id
        units: 1
        instrument: 'AUD_USD'
        timeInForce: 'FOK'
        type: 'MARKET'
        positionFill: 'DEFAULT'
        tradeId: 6368
      }

    it.skip 'should return the orders for an account', ->
      fx.setAccount id

      # TODO: Will need to mock these
