{expect} = require 'chai'
fx = require '../../../'

id = '101-011-5748031-001'

describe 'transactions', ->
  describe 'GET /accounts/:accountId/transactions[/:id]', ->
    it 'should throw an error if missing required params', ->
      fx.setAccount id
      {count, pageSize} = await fx.transactions()
      expect(count).to.be.above 50
      expect(pageSize).to.be.equal 100

    it 'should return a specified transaction id', ->
      fx.setAccount id
      {transaction: {alias, type}} = await fx.transactions id: 10
      expect(type).to.be.equal 'CLIENT_CONFIGURE'
      expect(alias).to.be.equal 'Default'

  describe 'GET /accounts/:accountId/transactions/stream', ->
    it 'should subscribe to the transactions stream', (done) ->
      fx.setAccount id
      stream = fx.transactions.stream()
      stream.on 'data', ({type}) ->
        expect(type).to.be.equal 'HEARTBEAT'
        stream.disconnect()
        done()
