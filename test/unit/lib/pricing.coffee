{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
axios = {}

id = '101-011-5748031-001'

describe 'pricing', ->
  before ->
    axios = td.replace 'axios'
    fx = require '../../../index'
    fx.setAccount id

  describe 'GET /accounts/:id/pricing', ->
    it 'should throw an error if missing required params', ->
      expect(-> fx.pricing()).to.throw 'Required parameters missing: instruments'

    it 'should pass the parameters to get the pricing for a list of instruments', ->
      fx.pricing instruments: 'AUD_USD'

      td.verify axios contains
        url: "https://api-fxpractice.oanda.com/v3/accounts/#{id}/pricing"
        method: 'GET'
        params: instruments: 'AUD_USD'
