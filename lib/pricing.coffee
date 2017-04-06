_ = require 'lodash'
{validate} = require './utils'

# GET /accounts/:id/pricing
exports.pricing = (req = {}) ->
  validate req, ['instruments']

  return @request req, "accounts/#{@options.accountId}/pricing"

# TODO: Need to allow req parms. Also instruments is mandatory
# GET /accounts/:id/pricing/stream
exports.pricing.stream = (req = {}) ->
  validate req, ['instruments']

  req.uri = @endpoint "accounts/#{@options.accountId}/pricing/stream", 'stream'

  return @subscribe req
