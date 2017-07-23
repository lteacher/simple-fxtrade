exports.validate = (req, required) ->
  keys = Object.keys req

  invalid = (param for param in required when param not in keys)

  if invalid.length > 0 then throw new Error "Required parameters missing: #{invalid.join ', '}"

exports.assign = require 'lodash/assign'

exports.omit = (object, key) ->
  result = exports.assign {}, object
  delete result[key]
  return result
