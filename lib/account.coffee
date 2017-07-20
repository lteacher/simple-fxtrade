_ = require './lodash'
{validate} = require './utils'

# GET | PATCH /accounts[/:id]
exports.accounts = (req = {}) ->
  {id} = req

  if @method is 'PATCH'
    validate req, ['id']

    return @request body: _.omit(req, 'id'), "accounts/#{id}/configuration", false

  route = switch
    when id? then "accounts/#{id}"
    else 'accounts'

  return @request req, route, false

# GET /accounts/:accountId/summary
exports.summary = (req = {}) ->
  return @request req, "accounts/#{@options.accountId}/summary"

# GET /accounts/:accountId/instruments
exports.instruments = (req = {}) ->
  return @request req, "accounts/#{@options.accountId}/instruments"

# GET /accounts/:accountId/changes
exports.changes = (req = {}) ->
  validate req, ['sinceTransactionID']

  return @request req, "accounts/#{@options.accountId}/changes"
