should   = require 'should'

gatherer = require '../gatherer'
indices  = require './fixtures/indices'

should_get = (expectation) ->
  (err, result) ->
    should.not.exist err
    should.exist result
    result.should.eql expectation

describe 'Gatherer API', ->
  describe '.sets', ->
    it 'should pass an array of set names', (done) ->
      gatherer.sets (err, obj) ->
        obj.should.eql indices.sets
        done()
  describe '.formats', ->
    it 'should pass an array of format names', (done) ->
      gatherer.formats (err, obj) ->
        obj.should.eql indices.formats
        done()
  describe '.types', ->
    it 'should pass an array of types', (done) ->
      gatherer.types (err, obj) ->
        obj.should.eql indices.types
        done()