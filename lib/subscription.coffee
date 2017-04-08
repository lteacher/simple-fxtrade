_ = require 'lodash'
{EventEmitter} = require 'events'

class Subscription extends EventEmitter
  constructor: (stream, options) ->
    super()
    unless stream? then return

    @connected = false
    @stream = stream
    @options = _.assign {}, json: true, options

    @stream.on 'data', (data) =>
      @connected = true
      if @options.json then data = JSON.parse data.toString()

      @emit 'data', data

    @stream.on 'error', (error) =>
      @connected = false
      @emit 'error', error

    @stream.on 'end', =>
      @connected = false
      @emit 'end'

  connect: ->
    @stream()
    @connected = true

  disconnect: ->
    @connected = false
    @stream.abort()

module.exports = Subscription
