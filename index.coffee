require('dotenv').load silent: true
_ = require 'lodash'
rp = require 'request-promise-native'
request = require 'request'
resources = require './lib'
Subscription = require './lib/subscription'

# Return a replacement with the new httpMethod
fx = (method) ->
  fx.method = _.toUpper method
  return fx

# Allows configuration of the fx api
fx.configure = (options) ->
  @options = _.assign {}, @options, options

# Set the account id context as its needed for most routes
fx.setAccount = (id) -> @options.accountId = id

# Execute a raw request
fx.request = (req, route, checkAccount = true) ->
  _validateRequest @options, checkAccount

  method = @method ? 'GET'
  @method = null

  return rp {
    method
    uri: req.uri ? @endpoint route
    headers: Authorization: "Bearer #{@options.apiKey}"
    body: req.body
    qs: _.omit req, 'body'
    resolveWithFullResponse: req.fullResponse
    simple: false
    json: req.json ? true
  }

fx.subscribe = (req, route, checkAccount = true) ->
  _validateRequest @options, checkAccount

  options = {
    method: @method
    uri: req.uri ? @endpoint route, 'stream'
    headers: Authorization: "Bearer #{@options.apiKey}"
    qs: _.omit req, 'body'
    json: req.json ? true
  }

  @method = null

  return new Subscription request(options, (err, res) ->
    if err then throw new Error "Failed to subscribe to: #{options.uri}"
  ), json: options.json

# Get the fx api endpoint adjusted per route
fx.endpoint = (route = '', mode = 'api') ->
  {live, version} = @options

  unless mode in ['api', 'stream'] then throw new Error 'invalid mode'

  return switch
    when live then "https://#{mode}-fxtrade.oanda.com/#{version}/#{route}"
    else "https://#{mode}-fxpractice.oanda.com/#{version}/#{route}"

# Ensure certain options are set before request execution
_validateRequest = (options, checkAccount) ->
  unless options.apiKey
    throw new Error 'Api key is not set. Use configure or env OANDA_API_KEY'

  if checkAccount and !options.accountId
    throw new Error 'Account id must be set for this request'

# Ensure deep binding
_bindAll = (source, target) ->
  _.each source, (srcFn, srcName) ->
    target[srcName] = _.bind srcFn, target

    _.each srcFn, (fn, fnName) ->
      target[srcName][fnName] = _.bind fn, target

  return target

# Bootstrap the api
bootstrap = ->
  # Configure the defaults here
  fx.configure {
    apiKey: process.env.OANDA_API_KEY
    live: false
    version: 'v3'
  }

  # Attach additional functions to the api
  _.assign fx, resources

  return _bindAll resources, fx, fx

module.exports = bootstrap()
