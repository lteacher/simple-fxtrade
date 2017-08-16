axios = require 'axios'
resources = require './lib'
Subscription = require './lib/subscription'
{omit, assign} = require './lib/utils'

# Return a replacement with the new httpMethod
fx = (method) ->
  fx.method = method.toUpperCase()
  return fx

# Allows configuration of the fx api
fx.configure = (options) ->
  @options = assign {}, @options, options

# Set the account id context as its needed for most routes
fx.setAccount = (id) -> @options.accountId = id

# Set the accept date time format
fx.setDateTimeFormat = (format) ->
  unless format in ['UNIX', 'RFC3339']
    throw new Error 'invalid date time format'

  @options.dateTimeFormat = format

# Execute a raw request
fx.request = (req, route, checkAccount = true) ->
  _validateRequest @options, checkAccount

  method = @method ? 'GET'
  @method = null

  responseType = 'json'

  if req.json? and !req.json then responseType = 'text'

  options = {
    method
    url: req.url ? @endpoint route
    headers:
      Authorization: "Bearer #{@options.apiKey}"
      'Accept-Datetime-Format': @options.dateTimeFormat
    data: req.body
    params: omit req, 'body'
    responseType
  }

  deferred = axios options

  if @options.fullResponse then return deferred

  # TODO: The ? are hacks because of the annoying testdouble framework
  # Need to remove them from here and also from the subscribe below
  return deferred
    ?.then ({status, headers, data}) -> assign {}, {status, headers}, data
    ?.catch (err) ->
      # If no response param then return the whole error
      unless err?.response?.status then return Promise.reject err

      {response} = err
      {status, headers, data} = response
      Promise.reject assign {}, {status, headers}, data


fx.subscribe = (req, route, checkAccount = true) ->
  _validateRequest @options, checkAccount

  options = {
    method: 'GET'
    url: req.url ? @endpoint route, 'stream'
    headers:
      Authorization: "Bearer #{@options.apiKey}"
      'Accept-Datetime-Format': @options.dateTimeFormat
    params: omit req, 'body'
    responseType: 'stream'
  }

  @method = null

  axios(options)?.then ({data}) -> new Subscription data, json: req.json ? true


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
  for srcName of source
    target[srcName] = source[srcName].bind target

    for fnName of source[srcName]
      target[srcName][fnName] = source[srcName][fnName].bind target

  return target

# Bootstrap the api
bootstrap = ->
  # Configure the defaults here
  fx.configure {
    apiKey: process.env.OANDA_API_KEY
    live: false
    version: 'v3'
    dateTimeFormat: 'RFC3339'
    throwHttpErrors: true
  }

  # Attach additional functions to the api
  assign fx, resources

  return _bindAll resources, fx

module.exports = bootstrap()
