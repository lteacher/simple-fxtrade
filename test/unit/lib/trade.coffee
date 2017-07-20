{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
rp = {}

id = '101-011-5748031-001'

describe 'trades', ->
  before ->
    rp = td.replace 'request-promise-native'
    fx = require '../../../index'
    fx.setAccount id

  describe 'GET /accounts/:accountId/trades[/:id]', ->
    it 'should pass the parameters to get the trades for an account', ->
      fx.trades count: 10, instrument: 'AUD_USD'

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/trades"
        method: 'GET'
        qs: count: 10, instrument: 'AUD_USD'

    it 'should set the state filter to open', ->
      fx.trades open: true

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/trades"
        method: 'GET'
        qs: state: 'OPEN'

    it 'should not change the state filter', ->
      fx.trades open: false, state: 'CLOSED' # pointless but testable

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/trades"
        method: 'GET'
        qs: state: 'CLOSED'

    it 'should pass the parameters to get a trade by id for an account', ->
      fx.trades id: 123

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/trades/123"
        method: 'GET'

  describe 'PUT /accounts/:accountId/trades/:id/close', ->
    it 'should pass the parameters to close a trade by id', ->
      fx.trades.close id: 123

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/trades/123/close"
        method: 'PUT'

  describe 'PUT /accounts/:accountId/trades/:id/clientExtensions', ->
    it 'should pass the parameters to set the client extensions for a trade', ->
      clientExtensions = id: 'ABC123', tag: 'MEGA1', comment: 'awesome dood'
      fx.trades.clientExtensions {id: 123, clientExtensions}

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/trades/123/clientExtensions"
        method: 'PUT'
        body: {clientExtensions}

  describe 'PUT /accounts/:accountId/trades/:id/orders', ->
    # TODO: Not putting much into this test, looks like an 'interesting' route...
    it 'should pass the parameters to mess with the trades dependent orders', ->
      takeProfit = timeInForce: 'GTC', price: '1.6000', type: 'TAKE_PROFIT'

      fx.trades.orders {id: 123, takeProfit}

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/trades/123/orders"
        method: 'PUT'
        body: {takeProfit}
