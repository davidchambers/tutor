vows     = require 'vows'
should   = require 'should'
gatherer = require '../gatherer'
indices = require './fixtures/indices'

should_get = (expectation) ->
  (err, result) ->
    should.not.exist err
    should.exist result
    result.should.eql expectation

vows.describe('Gatherer API').addBatch(
  '.sets':
    topic: -> gatherer.sets @callback
    'should pass an array of set names': should_get (indices.sets)
  '.formats':
    topic: -> gatherer.formats @callback
    'should pass an array of format names': should_get (indices.formats)
  '.types':
    topic: -> gatherer.types @callback
    'should pass an array of basic types': should_get (indices.types)
).export module
