require('dotenv').load silent: true
_ = require 'lodash'
{expect} = require 'chai'
td = require 'testdouble'
contains = td.matchers.contains

fx = {}
axios = {}

disableMocks = ->
  td.reset()
  fx = require '../../index'

afterEach -> td.reset()

describe '--- Unit Tests ---', ->

  beforeEach ->
    axios = td.replace 'axios'
    fx = require '../../index'


  describe 'main package', ->
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
          dateTimeFormat: 'RFC3339'
          throwHttpErrors: true

    describe '#fx', ->
      it 'should allow the caller to temporarily set the http method', ->
        temp = fx 'post'
        expect(temp.method).to.be.equal 'POST'
        expect(temp.options).to.be.eql
          apiKey: process.env.OANDA_API_KEY
          live: false
          version: 'v3'
          dateTimeFormat: 'RFC3339'
          throwHttpErrors: true

    describe '#setAccount', ->
      it 'should set the accountId', ->
        expect(fx.options.accountId).to.not.be.ok
        fx.setAccount '12345'
        expect(fx.options.accountId).to.be.equal '12345'

    describe '#setDateTimeFormat', ->
      it 'should set the date time format', ->
        expect(fx.options.dateTimeFormat).to.be.equal 'RFC3339'
        fx.setDateTimeFormat 'UNIX'
        expect(fx.options.dateTimeFormat).to.be.equal 'UNIX'

      it 'should throw an error when given an invalid format', ->
        expect(-> fx.setDateTimeFormat 'INVALIDTHING').to.throw 'invalid date time format'

    describe '#configure', ->
      it 'should set the api options', ->
        temp = fx 'get'
        options =
          accountId: 234
          live: true
          version: 'v1'
          apiKey: '12'
          dateTimeFormat: 'RFC3339'
          throwHttpErrors: false

        temp.configure options
        expect(temp.options).to.be.eql options

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

      it 'should concatenate the route to the url', ->
        expect(fx.endpoint 'accounts/123').to.be.equal 'https://api-fxpractice.oanda.com/v3/accounts/123'

      it 'should throw an error when given an invalid mode', ->
        expect(-> fx.endpoint 'accounts/123', 'invalid').to.throw 'invalid mode'

    describe '#request', ->
      it 'should call request-promise respecting the provided url', ->
        fx.setAccount '1'
        await fx.request url: 'https://www.google.com'
        td.verify axios contains url: 'https://www.google.com'

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

      it 'should use the endpoint to set the correct api url', ->
        fx.setAccount '123'
        fx.request {}, 'accounts'
        td.verify axios contains url: 'https://api-fxpractice.oanda.com/v3/accounts'

      it 'should strip body and include properties as query parms', ->
        fx.setAccount '123'
        fx.request body: 'This is content', since: '2017-01-01', id: 1234, 'accounts'
        td.verify axios contains
          data: 'This is content'
          params: since: '2017-01-01'
          responseType: 'json'
          url: 'https://api-fxpractice.oanda.com/v3/accounts'

      it 'should always pass the authorization header', ->
        fx.setAccount '123'
        fx.request {}, 'accounts'
        td.verify axios contains
          headers: Authorization: "Bearer #{process.env.OANDA_API_KEY}"

    describe '#subscribe', ->
      # Disabled due to the new way we must subscribe
      it 'should call request passing the expected options', ->
        fx.setAccount '123'
        subscription =  fx.subscribe {}

        td.verify axios contains
          url: 'https://stream-fxpractice.oanda.com/v3/'
          headers: Authorization: "Bearer #{process.env.OANDA_API_KEY}"
          params: {}
          responseType: 'stream'

      it 'should throw an error for messed up requests', ->
        disableMocks()
        url = 'http://brokenurl.town'
        fx.setAccount '2'
        try
          stream = await fx.subscribe {url}
          expect.fail()
        catch err
          expect(err.message).to.match /ENOTFOUND brokenurl\.town/

      it 'should return ok without any errors', ->
        disableMocks()
        url = 'https://www.google.com'
        fx.setAccount '2'
        expect(await fx.subscribe {url, json: false}).to.be.ok
