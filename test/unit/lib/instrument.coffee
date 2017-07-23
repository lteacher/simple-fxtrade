{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
axios = {}

id = '101-011-5748031-001'

describe 'candles', ->
  before ->
    axios = td.replace 'axios'
    fx = require '../../../index'
    fx.setAccount id

  describe 'GET /instruments/:accountId/candles', ->
    it 'should throw an error if missing required params', ->
      expect(-> fx.candles()).to.throw 'Required parameters missing: id'

    it 'should pass the parameters for getting the candles of a given instrument id', ->
      fx.candles id: 'AUD_USD', granularity: 'M1'
      td.verify axios contains
        url: 'https://api-fxpractice.oanda.com/v3/instruments/AUD_USD/candles'
        method: 'GET'
        params: granularity: 'M1'
