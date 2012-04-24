should = require 'should'
fs     = require 'fs'

parser   = require '../parser'
indices  = require './fixtures/indices'
cards    = require './fixtures/cards'
sets     = require './fixtures/sets'

web_fixture = (filename) ->
  filename = filename.toLowerCase().replace(/[ ,-]/g, "")
  fs.readFileSync("#{__dirname}/fixtures/web/#{filename}.html").toString()

parser_matches_fixture = (card_fixture) ->
  (done) ->
    parser.card web_fixture(card_fixture.response.name), (err, obj) ->
      obj.should.eql card_fixture.response
      done()

parser_builds_index = (func, fixture) ->
  (done) ->
    func web_fixture('gatherer_index'), (err, obj) ->
      obj.should.eql fixture
      done()

describe 'Parser', ->
  describe 'indices', ->
    describe '.sets', ->
      it 'extracts set names from index', parser_builds_index parser.sets, indices.sets
    describe '.formats', ->
      it 'should pass an array of format names', parser_builds_index parser.formats, indices.formats
    describe '.types', ->
      it 'should pass an array of types', parser_builds_index parser.types, indices.types
  describe '.card', ->
    describe 'old tests', ->
      it 'can find Recall', parser_matches_fixture cards.recall
      it 'can find Ancestral Vision', parser_matches_fixture cards.ancestral_vision # 0 converted mana cost
      it 'can find An-Havva Constable', parser_matches_fixture cards.constable
      it 'can find Diamond Faerie', parser_matches_fixture cards.diamond_faerie
      it 'can find Flame Javelin', parser_matches_fixture cards.flame_javelin #hybrid mana cost
      it 'can find Ajani Goldmane', parser_matches_fixture cards.ajani
      it 'can find Darksteel Colossus', parser_matches_fixture cards.colossus
      it 'can find Vault Skirge', parser_matches_fixture cards.skirge # phyrexian mana
      it 'can find Fire', parser_matches_fixture cards.fire # multipart card
      it 'can find Ice', parser_matches_fixture cards.ice # multipart card
      it 'can find Æther Storm', parser_matches_fixture cards.storm
      it 'can find Phantasmal Sphere', parser_matches_fixture cards.sphere
      it 'can find Serrated Arrows', parser_matches_fixture cards.arrows
    describe 'basic types', ->
      it 'can parse Artifacts'
      it 'can parse Creatures'
      it 'can parse Enchantements'
      it 'can parse Instants'
      it 'can parse Lands'
      it 'can parse Planeswalkers'
      it 'can parse Sorceries'
      it 'can parse Tribals'
      it 'can parse Planes'
      it 'can parse Vanguards', parser_matches_fixture cards.akroma
      it 'can parse Schemes'
    describe 'special cases', ->
      it 'can parse both sides of a transforming card'
      it 'can parse cards that have odd entities in their names'
      it 'can parse the BFM'
  describe '.set', ->
    describe 'old tests', ->
      it 'can parse the first page of homelands', (done) ->
        parser.set web_fixture('homelands_pg1'), (err, obj) ->
          obj.should.eql sets.homelands_pg1.response
          done()
    it 'can parse pages with the ` error'
    it 'can parse the last page of a set'
