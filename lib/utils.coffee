_ = require 'lodash'

exports.validate = (req, required) ->
  invalid = _.difference required, _.keys req

  if _.isEmpty invalid then return

  throw new Error "Required parameters missing: #{invalid.join ', '}"
