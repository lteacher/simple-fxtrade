{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
rp = {}

id = '101-011-5748031-001'

describe 'positions', ->
  before ->
    rp = td.replace 'request-promise-native'
    fx = require '../../../index'
    fx.setAccount id

  describe 'GET /accounts/:accountId/[positions[/:id]|openPositions]', ->
    it 'should pass the parameters to get the positions for an account', ->
      fx.positions()

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/positions"
        method: 'GET'

    it 'should pass the parameters to get a position by id for an account', ->
      fx.positions id: 'AUD_USD'

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/positions/AUD_USD"
        method: 'GET'

    it 'should pass the parameters to get open positions for an account', ->
      fx.positions open: true

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/openPositions"
        method: 'GET'

    it 'should pass the parameters to get the positions for an account per normal', ->
      fx.positions open: false

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/positions"
        method: 'GET'

  describe 'PUT /accounts/:accountId/positions/:id', ->
    it 'should throw an error if missing required params', ->
      expect(-> fx.positions.close()).to.throw 'Required parameters missing: id'

    it 'should pass the parameters to close position by instrument id', ->
      fx.positions.close id: 'AUD_USD'

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/positions/AUD_USD/close"
        method: 'PUT'
