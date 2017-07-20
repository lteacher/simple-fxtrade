{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
rp = {}

id = '101-011-5748031-001'

describe 'transactions', ->
  before ->
    rp = td.replace 'request-promise-native'
    fx = require '../../../index'
    fx.setAccount id

  describe 'GET /accounts/:accountId/transactions[/:id]', ->
    it 'should pass the parameters to get the transactions for an account', ->
      fx.transactions pageSize: 10, type: 'CLIENT_CONFIGURE'

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/transactions"
        method: 'GET'
        qs: pageSize: 10, type: 'CLIENT_CONFIGURE'

    it 'should pass the parameters to get a transaction by id for an account', ->
      fx.transactions id: 123

      td.verify rp contains
        uri: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/transactions/123"
        method: 'GET'
