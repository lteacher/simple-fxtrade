_ = require 'lodash'
{expect} = require 'chai'
fx = require '../../../'

id = '101-011-5748031-001'

describe 'accounts', ->
  describe 'GET /accounts[/:id]', ->
    it 'should get the accounts', ->
      {accounts} = await fx.accounts()

      expect(_.size(accounts)).to.be.equal 1

    it 'should return the account by id', ->
      {account} = await fx.accounts {id}

      expect(account.id).to.be.equal id
      expect(account.alias).to.be.equal 'Primary'

  describe 'PATCH /accounts/:id', ->
    it 'should configure the account', ->
      {clientConfigureTransaction: {alias}} = await fx('patch').accounts {id, body: alias: 'Default'}
      expect(alias).to.be.equal 'Default'

      # Change back to Primary
      fx('patch').accounts {id, body: alias: 'Primary'}

  describe 'GET /accounts/:id/summary', ->
    it 'should return the account summary', ->
      fx.setAccount id
      {account} = await fx.summary()

      expect(account.id).to.be.equal id

  describe 'GET /accounts/:id/instruments', ->
    it 'should return the account instruments', ->
      fx.setAccount id
      {instruments} = await fx.instruments()
      pair = _.first _.filter instruments, name: 'AUD_USD'

      expect(pair.displayName).to.be.equal 'AUD/USD'

  describe 'GET /accounts/:id/changes', ->
    it 'should throw an error if missing required params', ->
      fx.setAccount id
      expect(-> fx.changes()).to.throw(
        'Required parameters missing: sinceTransactionID'
      )

    it 'should return the account changes', ->
      fx.setAccount id
      {changes: {transactions}} = await fx.changes sinceTransactionID: 20

      expect(_.isEmpty transactions).to.not.be.ok
