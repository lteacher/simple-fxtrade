_ = require 'lodash'
{EventEmitter} = require 'events'

class Subscription extends EventEmitter
  constructor: (stream, options) ->
    super()
    @stream = stream
    @options = _.assign {}, json: true, options

    @stream.on 'data', (data) =>
      if @options.json then data = JSON.parse data.toString()

      @emit 'data', data

    @stream.on 'error', (error) => @emit 'error', error

    @stream.on 'end', => @emit 'end'


  disconnect: -> @stream.abort()

module.exports = Subscription
