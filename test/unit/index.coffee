_ = require 'lodash'
{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
request = {}
rp = {}

disableMocks = ->
  td.reset()
  fx = require '../../'

describe 'main package', ->
  beforeEach ->
    request = td.replace 'request'
    rp = td.replace 'request-promise-native'
    fx = require '../../'

  afterEach -> td.reset()

  describe 'module exports', ->
    it 'should export correctly', ->
      expect(fx).to.be.ok

    it 'should be a function', ->
      expect(_.isFunction fx).to.be.ok

    it 'should setup the correct defaults', ->
      expect(fx.options).to.be.eql
        apiKey: process.env.OANDA_API_KEY
        live: false
        version: 'v3'

  describe '#fx', ->
    it 'should allow the caller to temporarily set the http method', ->
      temp = fx 'post'
      expect(temp.method).to.be.equal 'POST'
      expect(temp.options).to.be.eql
        apiKey: process.env.OANDA_API_KEY
        live: false
        version: 'v3'

  describe '#setAccount', ->
    it 'should set the accountId', ->
      fx.setAccount '12345'
      expect(fx.options.accountId).to.be.equal '12345'

  describe '#configure', ->
    it 'should set the api options', ->
      temp = fx 'get'
      temp.configure accountId: 234, live: true, version: 'v1', apiKey: '12'
      expect(temp.options).to.be.eql
        accountId: 234
        apiKey: '12'
        live: true
        version: 'v1'

  describe '#endpoint', ->
    it 'should return the practice api endpoint when not live', ->
      expect(fx.endpoint()).to.be.equal 'https://api-fxpractice.oanda.com/v3/'

    it 'should return the trade api endpoint when live', ->
      temp = fx 'get'
      temp.configure live: true
      expect(temp.endpoint()).to.be.equal 'https://api-fxtrade.oanda.com/v3/'

    it 'should return the practice stream endpoint when not live', ->
      expect(fx.endpoint '', 'stream').to.be.equal 'https://stream-fxpractice.oanda.com/v3/'

    it 'should return the trade api endpoint when live', ->
      temp = fx 'get'
      temp.configure live: true
      expect(temp.endpoint '', 'stream').to.be.equal 'https://stream-fxtrade.oanda.com/v3/'

    it 'should concatenate the route to the uri', ->
      expect(fx.endpoint 'accounts/123').to.be.equal 'https://api-fxpractice.oanda.com/v3/accounts/123'

    it 'should throw an error when given an invalid mode', ->
      expect(-> fx.endpoint 'accounts/123', 'invalid').to.throw 'invalid mode'

  describe '#request', ->
    it 'should call request-promise respecting the provided uri', ->
      fx.setAccount '1'
      await fx.request uri: 'https://www.google.com'
      td.verify rp contains uri: 'https://www.google.com'

    it 'should reject as an error when there is no apiKey set', ->
      temp = fx 'get'
      temp.configure apiKey: undefined

      try
        temp.request 'accounts'
        expect.fail()
      catch {message}
        expect(message).to.match /Api key is not set/

    it 'should reject as an error when validating the accountId', ->
      temp = fx 'get'
      temp.configure accountId: undefined

      try
        temp.request 'accounts'
        expect.fail()
      catch {message}
        expect(message).to.match /Account id must be set for this request/

    it 'should use the endpoint to set the correct api uri', ->
      fx.setAccount '123'
      fx.request {}, 'accounts'
      td.verify rp contains uri: 'https://api-fxpractice.oanda.com/v3/accounts'

    it 'should strip body and include properties as query parms', ->
      fx.setAccount '123'
      fx.request body: 'This is content', since: '2017-01-01', id: 1234, 'accounts'
      td.verify rp contains
        body: 'This is content'
        qs: since: '2017-01-01'
        json: true
        uri: 'https://api-fxpractice.oanda.com/v3/accounts'

    it 'should always pass the authorization header', ->
      fx.setAccount '123'
      fx.request {}, 'accounts'
      td.verify rp contains
        headers: Authorization: "Bearer #{process.env.OANDA_API_KEY}"

  describe '#subscribe', ->
    it 'should call request passing the expected options', ->
      fx.setAccount '123'
      subscription =  fx.subscribe {}

      td.verify request contains(
        uri: 'https://stream-fxpractice.oanda.com/v3/'
        headers: Authorization: "Bearer #{process.env.OANDA_API_KEY}"
        qs: {}
        json: true
        ), td.matchers.anything()

    it 'should throw an error for messed up requests', ->
      disableMocks()
      uri = 'ttzhso://brokenuri.town'
      fx.setAccount '2'
      expect(-> fx.subscribe {uri}).to.throw 'Failed to subscribe to: ' + uri

    it 'should return ok without any errors', ->
      disableMocks()
      uri = 'https://www.google.com'
      fx.setAccount '2'
      expect(fx.subscribe {uri, json: false}).to.be.ok
