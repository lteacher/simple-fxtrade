_ = require 'lodash'
{validate} = require './utils'

# GET /accounts/:accountId/[positions[/:id]|openPositions]
exports.positions = (req = {}) ->
  {id, open} = req
  route = switch
    when id? then "accounts/#{@options.accountId}/positions/#{id}"
    when open then "accounts/#{@options.accountId}/openPositions"
    else "accounts/#{@options.accountId}/positions"

  return @request req, route

# PUT /accounts/:accountId/positions/:id/close
exports.positions.close = (req = {}) ->
  validate req, ['id']

  return @('put').request body: _.omit(req, 'id'), "accounts/#{@options.accountId}/trades/#{req.id}/close"
