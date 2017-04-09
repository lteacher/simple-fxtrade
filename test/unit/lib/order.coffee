{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
rp = {}

id = '101-011-5748031-001'

describe 'orders', ->
  before ->
    rp = td.replace 'request-promise-native'
    fx = require '../../../'
    fx.setAccount id

  describe 'POST /accounts/:accountId/orders', ->
    it 'should throw an error if missing required params', ->
      expect(-> fx.orders.create()).to.throw 'Required parameters missing: order'

    it 'should pass the parameters to create an order', ->
      order =
        units: 1
        instrument: 'AUD_USD'
        timeInForce: 'FOK'
        type: 'MARKET'
        positionFill: 'DEFAULT'
        tradeId: 6368

      fx.orders.create {order}

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/orders"
        method: 'POST'
        body: {order}

  describe 'GET /accounts/:accountId/orders[/:id]', ->
    it 'should pass the parameters get the orders for an account', ->
      fx.orders()

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/orders"
        method: 'GET'

    it 'should pass the parameters get an order by id for an account', ->
      fx.orders id: 1234

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/orders/1234"
        method: 'GET'

  describe 'PUT /accounts/:accountId/orders/:id', ->
    it 'should throw an error if missing required params', ->
      expect(-> fx.orders.replace()).to.throw 'Required parameters missing: id, order'

    it 'should pass the parameters to replace an order', ->
      order =
        units: 1
        instrument: 'AUD_USD'
        timeInForce: 'FOK'
        type: 'MARKET'
        positionFill: 'DEFAULT'
        tradeId: 6368

      fx.orders.replace {id: 1234, order}

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/orders/1234"
        method: 'PUT'
        body: {order}

  describe 'PUT /accounts/:accountId/orders/:id/cancel', ->
    it 'should throw an error if missing required params', ->
      expect(-> fx.orders.cancel()).to.throw 'Required parameters missing: id'

    it 'should pass the parameters to cancel an order', ->
      fx.orders.cancel id: 1234

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/orders/1234/cancel"
        method: 'PUT'

  describe 'PUT /accounts/:accountId/orders/:id/clientExtensions', ->
    it 'should throw an error if missing required params', ->
      expect(-> fx.orders.clientExtensions()).to.throw 'Required parameters missing: id'

    it 'should pass the parameters to modify client extensions', ->
      clientExtensions = id: 'ABC123', tag: 'MEGA1', comment: 'awesome dood'
      tradeClientExtensions = id: '998876', tag: 'A1', comment: 'Wowz'

      fx.orders.clientExtensions {id: 1234, clientExtensions, tradeClientExtensions}

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/orders/1234/clientExtensions"
        method: 'PUT'
        body: {clientExtensions, tradeClientExtensions}
