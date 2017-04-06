require('dotenv').load silent: true
_ = require 'lodash'
rp = require 'request-promise-native'
request = require 'request'
resources = require './lib'
Subscription = require './lib/subscription'

# Return a replacement with the new httpMethod
fx = (method) -> _.assign {}, fx, method: _.toUpper method

# Allows configuration of the fx api
fx.configure = (options) ->
  @options = _.assign {}, @options, options

# Set the account id context as its needed for most routes
fx.setAccount = (id) -> @options.accountId = id

# Execute a raw request
fx.request = (req, route, checkAccount = true) ->
  _validateRequest @options, checkAccount

  return rp {
    @method
    uri: req.uri ? @endpoint route
    headers: Authorization: "Bearer #{@options.apiKey}"
    body: req.body
    qs: _.omit req, 'body'
    resolveWithFullResponse: req.fullResponse
    simple: false
    json: true
  }

fx.subscribe = (req, route, checkAccount = true) ->
  _validateRequest @options, checkAccount

  options = {
    @method
    uri: req.uri ? @endpoint route
    headers: Authorization: "Bearer #{@options.apiKey}"
    qs: _.omit req, 'body'
    json: true
  }

  return new Subscription request options, (err, res) ->
    if err then throw new Error "Failed to subscribe to: #{uri}"


# Get the fx api endpoint adjusted per route
fx.endpoint = (route, mode = 'api') ->
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

# Bootstrap the api
bootstrap = ->
  # Configure the defaults here
  fx.configure {
    apiKey: process.env.OANDA_API_KEY
    live: false
    version: 'v3'
  }

  # Set the default http method
  fx.method = 'GET'

  # Attach additional functions to the api
  _.assign fx, resources

  # Ensure binding to fx for all functions
  _.each resources, (resource, resourceName) ->
    fx[resourceName] = _.bind resource, fx

    _.each resource, (fn, fnName) ->
      fx[resourceName][fnName] = _.bind fn, fx

  return fx

module.exports = bootstrap()
