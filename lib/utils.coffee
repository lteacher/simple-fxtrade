_ = require 'lodash'

exports.validate = (req, required) ->
  invalid = _.difference required, _.keys req

  if not _.isEmpty invalid
    throw new Error "Required parameters missing: #{invalid.join ', '}"
