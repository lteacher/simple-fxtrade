{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
axios = {}

id = '101-011-5748031-001'

describe 'accounts', ->
  before ->
    axios = td.replace 'axios'
    fx = require '../../../index'

  describe 'GET /accounts[/:id]', ->
    it 'should pass the parameters got get the accounts', ->
      fx.accounts()

      td.verify axios contains
        url: 'https://api-fxpractice.oanda.com/v3/accounts'
        method: 'GET'

    it 'should pass the parameters to get an account by id', ->
      fx.accounts {id}

      td.verify axios contains
        url: "https://api-fxpractice.oanda.com/v3/accounts/#{id}"
        method: 'GET'

  describe 'PATCH /accounts/:id', ->
    it 'should pass the parameters for patching by id', ->
      fx('patch').accounts {id, alias: 'Default'}

      td.verify axios contains
        url: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/configuration"
        method: 'PATCH'
        data: alias: 'Default'

  describe 'GET /accounts/:id/summary', ->
    it 'should pass the parameters to get the account summary', ->
      fx.setAccount id
      fx.summary()

      td.verify axios contains
        url: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/summary"
        method: 'GET'

  describe 'GET /accounts/:id/instruments', ->
    it 'should pass the parameters to get the account instruments', ->
      fx.setAccount id
      fx.instruments()

      td.verify axios contains
        url: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/instruments"
        method: 'GET'

  describe 'GET /accounts/:id/changes', ->
    it 'should throw an error if missing required params', ->
      fx.setAccount id
      expect(-> fx.changes()).to.throw(
        'Required parameters missing: sinceTransactionID'
      )

    it 'should pass the parameters to get the account changes', ->
      fx.setAccount id
      fx.changes sinceTransactionID: 20

      td.verify axios contains
        url: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/changes"
        method: 'GET'
        params: sinceTransactionID: 20
