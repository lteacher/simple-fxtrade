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
      if @options.json
        str = data.toString()

        if !str then return

        data = JSON.parse str

      @emit 'data', data

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
