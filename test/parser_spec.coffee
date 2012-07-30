should = require 'should'
fs     = require 'fs'

parser    = require '../parser'
indices   = require './fixtures/indices'
cards     = require './fixtures/cards'
languages = require './fixtures/languages'
sets      = require './fixtures/sets'

web_fixture = (filename) ->
  filename = filename.toLowerCase().replace(/[ ,-]/g, "")
  fs.readFileSync("#{__dirname}/fixtures/web/#{filename}.html").toString()

card_matches_fixture = (card_fixture) ->
  (done) ->
    parser.card web_fixture(card_fixture.name || card_fixture.response.name), (err, obj) ->
      obj.should.eql card_fixture.response
      done()
    , card_fixture.options

language_matches_fixture = (language_fixture) ->
  (done) ->
    parser.language web_fixture(language_fixture.name || language_fixture.params.name), (err, obj) ->
      obj.should.eql language_fixture.response
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
      it 'can find Recall', card_matches_fixture cards.recall
      it 'can find Ancestral Vision', card_matches_fixture cards.ancestral_vision # 0 converted mana cost
      it 'can find An-Havva Constable', card_matches_fixture cards.anhavva_constable
      it 'can find Diamond Faerie', card_matches_fixture cards.diamond_faerie
      it 'can find Flame Javelin', card_matches_fixture cards.flame_javelin #hybrid mana cost
      it 'can find Ajani Goldmane', card_matches_fixture cards.ajani_goldmane
      it 'can find Darksteel Colossus', card_matches_fixture cards.darksteel_colossus
      it 'can find Vault Skirge', card_matches_fixture cards.vault_skirge # phyrexian mana
      it 'can find Fire', card_matches_fixture cards.fire # multipart card
      it 'can find Ice', card_matches_fixture cards.ice # multipart card
      it 'can find Æther Storm', card_matches_fixture cards.aether_storm
      it 'can find Phantasmal Sphere', card_matches_fixture cards.phantasmal_sphere
      it 'can find Serrated Arrows', card_matches_fixture cards.serrated_arrows
      it 'can find Crackleburr', card_matches_fixture cards.crackleburr # tap/untap symbols
      it 'can find Hill Giant', card_matches_fixture cards.hill_giant # it crashes the server
    describe 'basic types', ->
      it 'can parse Artifacts'
      it 'can parse Creatures'
      it 'can parse Enchantments'
      it 'can parse Instants'
      it 'can parse Lands'
      it 'can parse Planeswalkers'
      it 'can parse Sorceries'
      it 'can parse Tribals'
      it 'can parse Planes'
      it 'can parse Vanguards', card_matches_fixture cards.akroma_angel_of_wrath_avatar
      it 'can parse Schemes'
    describe 'special cases', ->
      it 'can parse the first side of a transforming card', card_matches_fixture cards.afflicted_deserter
      it 'can parse the second side of a transforming card', card_matches_fixture cards.werewolf_ransacker
      it 'can parse cards that have odd entities in their names'
      it 'can parse the BFM'
    describe 'printed=true', ->
      it "can provide a card's original wording", card_matches_fixture cards.tunnel
      it "can provide a card's details in French", card_matches_fixture cards.birds_of_paradise_fr
      it "can provide a card's details in Japanse", card_matches_fixture cards.birds_of_paradise_ja
      it "can provide a card's details in Chinese Traditional", card_matches_fixture cards.birds_of_paradise_zh_cn
      it "can provide a card's details in Chinese Simplified", card_matches_fixture cards.birds_of_paradise_zh_tw
      it "can provide a card's details in German", card_matches_fixture cards.birds_of_paradise_de
  describe '.language', ->
    it "can provide a card's language details", language_matches_fixture languages.birds_of_paradise
    it "can provide a card's language details for a card without translations", language_matches_fixture languages.black_lotus
    it "can provide a card's language details for a card with all translations", language_matches_fixture languages.drowned_catacomb
    it "can workaround portugese language bug", language_matches_fixture languages.inquisition_of_kozilek
  describe '.set', ->
    describe 'old tests', ->
      it 'can parse the first page of homelands', (done) ->
        parser.set web_fixture('homelands_pg1'), (err, obj) ->
          obj.should.eql sets.homelands_pg1.response
          done()
    it 'can parse pages with the ` error'
    it 'can parse the last page of a set'
