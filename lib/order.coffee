_ = require 'lodash'
{validate} = require './utils'

# GET /accounts/:accountId/orders[/:id]
exports.orders = (req = {}) ->
  {id} = req
  route = switch
    when id? then "accounts/#{@options.accountId}/orders/#{id}"
    else "accounts/#{@options.accountId}/orders"

  return @request req, route

# POST /accounts/:accountId/orders
exports.orders.create = (req = {}) ->
  validate req, ['order']

  return @('post').request body: req, "accounts/#{@options.accountId}/orders"

# PUT /accounts/:accountId/orders/:id
exports.orders.replace = (req = {}) ->
  validate req, ['id', 'order']

  return @('put').request body: _.omit(req, 'id'), "accounts/#{@options.accountId}/orders/#{req.id}"

# PUT /accounts/:accountId/orders/:id/cancel
exports.orders.cancel = (req = {}) ->
  validate req, ['id']

  return @('put').request body: _.omit(req, 'id'), "accounts/#{@options.accountId}/orders/#{req.id}/cancel"

# PUT /accounts/:accountId/orders/:id/clientExtensions
exports.orders.clientExtensions = (req = {}) ->
  validate req, ['id']

  return @('put').request body: _.omit(req, 'id'), "accounts/#{@options.accountId}/orders/#{req.id}/clientExtensions"
