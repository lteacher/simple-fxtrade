_ = require 'lodash'
{validate} = require './utils'

# GET | PATCH /accounts[/:id]
exports.accounts = (req = {}) ->
  {id} = req

  if @method is 'patch' then validate req, ['id']

  route = switch
    when @method is 'PATCH'
      validate req, ['id']
      "accounts/#{id}/configuration"
    when id? then 'accounts'
    else "accounts/#{id}"

  return @request req, route, false

# GET /accounts/:accountId/summary
exports.summary = (req = {}) ->
  return @request req, "accounts/#{@options.accountId}/summary"

# GET /accounts/:accountId/instruments
exports.instruments = (req = {}) ->
  return @request req, "accounts/#{@options.accountId}/instruments"

# TODO: PATCH /accounts/:accountId/configuration
exports.configuration = (req = {}) ->
  return @('patch').request req, "accounts/#{@options.accountId}/instruments"

# TODO: GET /accounts/:accountId/changes
exports.changes = (req = {}) ->
  return @request req, "accounts/#{@options.accountId}/changes"
