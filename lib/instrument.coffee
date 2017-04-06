_ = require 'lodash'
{validate} = require './utils'

# GET /instruments/:accountId/candles
exports.candles = (req = {}) ->
  validate req, ['id']

  return @request req, "instruments/#{req.id}/candles", false
