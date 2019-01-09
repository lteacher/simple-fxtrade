{EventEmitter} = require 'events'
{assign} = require './utils'

class Subscription extends EventEmitter
  constructor: (stream, options) ->
    super()
    unless stream? then return

    @connected = false
    @stream = stream
    @options = assign {}, options

    @stream.on 'data', (data) =>
      @connected = true

      # On some occasions OANDA will send multiple JSON messages into the stream
      # which are separated by newline. In those instances we split and parse each
      # message individually ignoring empty strings.
      messages = switch
        when @options.json
          data
            .toString()
            .split /\r?\n/
            .filter Boolean
            .map JSON.parse
        else [data]

      messages.forEach (message) => @emit 'data', message

    @stream.on 'error', (error) =>
      @connected = false
      @emit 'error', error

    @stream.on 'end', (data) =>
      @connected = false
      @emit 'end', data

  connect: ->
    @stream()
    @connected = true

  disconnect: ->
    @connected = false
    @stream.req.abort()

module.exports = Subscription
