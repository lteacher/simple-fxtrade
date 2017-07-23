{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
axios = {}

id = '101-011-5748031-001'

describe 'transactions', ->
  before ->
    axios = td.replace 'axios'
    fx = require '../../../index'
    fx.setAccount id

  describe 'GET /accounts/:accountId/transactions[/:id]', ->
    it 'should pass the parameters to get the transactions for an account', ->
      fx.transactions pageSize: 10, type: 'CLIENT_CONFIGURE'

      td.verify axios contains
        url: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/transactions"
        method: 'GET'
        params: pageSize: 10, type: 'CLIENT_CONFIGURE'

    it 'should pass the parameters to get a transaction by id for an account', ->
      fx.transactions id: 123

      td.verify axios contains
        url: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/transactions/123"
        method: 'GET'
