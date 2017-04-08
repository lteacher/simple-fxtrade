{expect} = require 'chai'
{validate} = require '../../../lib/utils'

describe 'utils', ->
  describe '#validate', ->
    it 'should throw an error if request is missing required params', ->
      expect(-> validate id: 123, ['id', 'other']).to.throw(
        'Required parameters missing: other'
      )

    it 'should return if all valid parameters provided', ->
      validate id: 123, since: '2017-01-01', ['id', 'since']
