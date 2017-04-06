_ = require 'lodash'
{validate} = require './utils'

# GET /accounts/:accountId/trades[/:id]
exports.trades = (req = {}) ->
  {id} = req
  route = switch
    when id? then "accounts/#{@options.accountId}/trades/#{id}"
    else "accounts/#{@options.accountId}/trades"

  return @request req, route

# PUT /accounts/:accountId/trades/:id/close
exports.trades.close = (req = {}) ->
  validate req, ['id']

  return @('put').request body: _.omit(req, 'id'), "accounts/#{@options.accountId}/trades/#{req.id}/close"

# PUT /accounts/:accountId/trades/:id/close
exports.trades.clientExtensions = (req = {}) ->
  validate req, ['id']

  return @('put').request body: _.omit(req, 'id'), "accounts/#{@options.accountId}/trades/#{req.id}/clientExtensions"

# PUT /accounts/:accountId/trades/:id/orders
exports.trades.orders = (req = {}) ->
  validate req, ['id']

  return @('put').request body: _.omit(req, 'id'), "accounts/#{@options.accountId}/trades/#{req.id}/orders"
