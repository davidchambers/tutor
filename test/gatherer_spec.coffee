should = require 'should'

gatherer = require '../gatherer'
cards    = require './fixtures/cards'
sets     = require './fixtures/sets'

err_404 =
  error: 'Not Found'
  status: 404

err_302 =
  error: null
  status: 302

describe 'Gatherer API', ->
  describe '.fetch_card', ->
    it 'makes a request to gatherer based on parameters'
  describe '.fetch_set', ->
    describe 'when given an undefined page parameter', ->
      it 'requests the first page of the set'
    describe 'when given a page parameter of zero', ->
      it 'gives a 404 error'
    describe 'when given a nonexistent page parameter', ->
        it 'gives a 404 error'