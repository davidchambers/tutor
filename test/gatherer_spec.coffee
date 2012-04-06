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

recursive_property_comparison = (response, fixture) ->
  for property, value of fixture
    if value? and typeof value is 'object' and value.constructor isnt Array
      recursive_property_comparison response[property], fixture[property]
    else if value?
      # .should.have.property does strict comparison, which fails for
      # objects this test should consider identical (arrays, etc)
      response[property].should.eql fixture[property]
    else
      # Because we need this test for the occasional null property,
      # should.js must be explicitly required, rather than implicitly
      # via mocha.opts
      should.not.exist response[property]

test_response = (api_func, fixture) ->
  (done) ->
    api_func fixture.params, (err, obj) ->
      recursive_property_comparison obj, fixture.response
      done()

gets_card = (card_fixture) ->
  test_response gatherer.fetch_card, card_fixture

gets_set = (set_fixture) ->
  test_response gatherer.fetch_set, set_fixture

describe 'Gatherer API', ->
  describe '.fetch_card', ->
    describe 'when given an id parameter', ->
      it 'errors out on an invalid id', gets_card
        params: ['1A7gaf', null]
        response: err_302
      describe 'for a sorcery card', ->
        it 'can find Recall', gets_card cards.recall
        it 'can find Ancestral Vision', gets_card cards.ancestral_vision # 0 converted mana cost
      describe 'for a creature card', ->
        it 'can find An-Havva Constable', gets_card cards.constable
        it 'can find Diamond Faerie', gets_card cards.diamond_faerie
      describe 'for an instant card', ->
        describe 'with hybrid mana cost', ->
          it 'can find Flame Javelin', gets_card cards.flame_javelin
      describe 'for a planeswalker card', ->
        it 'can find Ajani Goldmane', gets_card cards.ajani
      describe 'for an artifact creature card', ->
        it 'can find Darksteel Colossus', gets_card cards.colossus
        describe 'with a phyrexian mana cost', ->
          it 'can find Vault Skirge', gets_card cards.skirge
      describe 'for a multipart card', ->
        describe 'with a part name', ->
          it 'can find Fire', gets_card cards.fire
          it 'can find Ice', gets_card cards.ice
        describe 'without a part name', ->
          it 'errors out' # currently, it seems to choose a card at random
    describe 'when given an object with property "name" as a parameter', ->
      describe 'for an enchantment card', ->
        it 'can find Æther Storm', gets_card cards.storm
      describe 'for a creature card', ->
        it 'can find Phantasmal Sphere', gets_card cards.sphere
      describe 'for an artifact card', ->
        it 'can find Serrated Arrows', gets_card cards.arrows
  describe '.fetch_set', ->
    describe 'when given an invalid name parameter', ->
      it 'gives a 404 error', gets_set
        params: {name: 'Foo', page: undefined}
        response: err_404
    describe 'when given a valid name parameter', ->
      describe 'and an undefined page parameter', ->
        it 'gets the first page', gets_set sets.homelands_pg1
      describe 'and a page parameter of zero', ->
        it 'gives a 404 error', gets_set
          params: {name: 'Homelands', page: 0}
          response: err_404
      describe 'and a nonexistent page', ->
        it 'gives a 404 error', gets_set
          params: {name: 'Homelands', page: 8}
          response: err_404
