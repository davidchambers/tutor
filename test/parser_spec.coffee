should = require 'should'
fs     = require 'fs'

parser   = require '../parser'
indices  = require './fixtures/indices'
cards    = require './fixtures/cards'
sets     = require './fixtures/sets'

web_fixture = (filename) ->
  fs.readFileSync("#{__dirname}/fixtures/web/#{filename}.html").toString()

card_should_match = (obj_fixture, filename) ->
  (done) ->
    parser.card web_fixture(filename), (err, obj) ->
      obj.should.eql obj_fixture.response
      done()

parse_match = (obj_fixture, filename) ->
  (done) ->
    parser.card web_fixture(filename), (err, obj) ->
      obj.should.eql obj_fixture.response
      done()

describe 'Parser', ->
  describe 'indices', ->
    page = web_fixture 'gatherer_index'
    describe '.sets', ->
      it 'extracts set names from index', (done) ->
        parser.sets page, (err, obj) ->
          obj.should.eql indices.sets
          done()
    describe '.formats', ->
      it 'should pass an array of format names', (done) ->
        parser.formats page, (err, obj) ->
          obj.should.eql indices.formats
          done()
    describe '.types', ->
      it 'should pass an array of types', (done) ->
        parser.types page, (err, obj) ->
          obj.should.eql indices.types
          done()
  describe '.card', ->
    describe 'old tests', ->
      it 'can find Recall', card_should_match cards.recall, 'recall'
      it 'can find Ancestral Vision', card_should_match cards.ancestral_vision, 'ancestralvision' # 0 converted mana cost
      it 'can find An-Havva Constable', card_should_match cards.constable, 'anhavvaconstable'
      it 'can find Diamond Faerie', card_should_match cards.diamond_faerie, 'diamondfaerie'
      it 'can find Flame Javelin', card_should_match cards.flame_javelin, 'flamejavelin' #hybrid mana cost
      it 'can find Ajani Goldmane', card_should_match cards.ajani, 'ajani'
      it 'can find Darksteel Colossus', card_should_match cards.colossus, 'darksteelcolossus'
      it 'can find Vault Skirge', card_should_match cards.skirge, 'vaultskirge' # phyrexian mana
      it 'can find Fire', card_should_match cards.fire, 'fire' # multipart card
      it 'can find Ice', card_should_match cards.ice, 'ice' # multipart card
      it 'can find Æther Storm', parse_match cards.storm, 'aetherstorm'
      it 'can find Phantasmal Sphere', parse_match cards.sphere, 'phantasmalsphere'
      it 'can find Serrated Arrows', parse_match cards.arrows, 'serratedarrows'
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
      it 'can parse Vanguards'
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
