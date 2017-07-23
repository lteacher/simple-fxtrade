{validate} = require './utils'

# GET /accounts/:id/pricing
exports.pricing = (req = {}) ->
  validate req, ['instruments']

  return @request req, "accounts/#{@options.accountId}/pricing"

# GET /accounts/:id/pricing/stream
exports.pricing.stream = (req = {}) ->
  validate req, ['instruments']

  return @subscribe req, "accounts/#{@options.accountId}/pricing/stream"
