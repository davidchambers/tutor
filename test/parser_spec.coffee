should        = require 'should'
parser        = require '../parser'
indices       = require './fixtures/indices'
cards         = require './fixtures/cards'
languages     = require './fixtures/languages'
sets          = require './fixtures/sets'

{web_fixture} = require './test_helpers'
{matches_fixture} = require './test_helpers'

card_matches_fixture = (fixture) ->
  matches_fixture parser.card, fixture

language_matches_fixture = (fixture) ->
  matches_fixture parser.language, fixture

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

  describe '.set', ->
    it 'can parse the first page of homelands', (done) ->
      parser.set web_fixture('homelands_pg1'), (err, obj) ->
        obj.should.eql sets.homelands_pg1.response
        done()

  describe 'card parser', ->
    describe 'basic types', ->
      it 'can parse an artifact', card_matches_fixture cards.serrated_arrows
      it 'can parse an enchantment', card_matches_fixture cards.aether_storm
      it 'can parse an instant', card_matches_fixture cards.tunnel
      it 'can parse a planeswalker', card_matches_fixture cards.ajani_goldmane
      it 'can parse a sorcery', card_matches_fixture cards.recall
      it 'can parse a vanguard', card_matches_fixture cards.akroma_angel_of_wrath_avatar

    describe 'assorted cards', ->
      it 'can parse An-Havva Constable', card_matches_fixture cards.anhavva_constable
      it 'can parse Diamond Faerie', card_matches_fixture cards.diamond_faerie
      it 'can parse Darksteel Colossus', card_matches_fixture cards.darksteel_colossus
      it 'can parse Phantasmal Sphere', card_matches_fixture cards.phantasmal_sphere

    describe 'cards with specific features', ->
      it 'can parse a card with converted mana cost 0', card_matches_fixture cards.ancestral_vision
      it 'can parse a card with hybrid mana', card_matches_fixture cards.flame_javelin
      it 'can parse a card with phyrexian mana', card_matches_fixture cards.vault_skirge
      it 'can parse the first part of a multipart card', card_matches_fixture cards.fire
      it 'can parse the second part of a multipart card', card_matches_fixture cards.ice
      it 'can parse a card with tap and untap symbols', card_matches_fixture cards.crackleburr
      it 'can parse a card without abilities', card_matches_fixture cards.hill_giant
      it 'can parse the first side of a transforming card', card_matches_fixture cards.afflicted_deserter
      it 'can parse the second side of a transforming card', card_matches_fixture cards.werewolf_ransacker

    describe 'cards in other languages', ->
      it "can provide a card's details in German", card_matches_fixture cards.birds_of_paradise_de
      it "can provide a card's details in French", card_matches_fixture cards.birds_of_paradise_fr
      it "can provide a card's details in Japanse", card_matches_fixture cards.birds_of_paradise_ja
      it "can provide a card's details in Chinese Traditional", card_matches_fixture cards.birds_of_paradise_zh_cn
      it "can provide a card's details in Chinese Simplified", card_matches_fixture cards.birds_of_paradise_zh_tw

  describe 'language parser', ->
    it "can provide a card's language details", language_matches_fixture languages.birds_of_paradise
    it "can provide a card's language details for a card without translations", language_matches_fixture languages.black_lotus
    it "can provide a card's language details for a card with all translations", language_matches_fixture languages.drowned_catacomb
    it "can workaround portugese language bug", language_matches_fixture languages.inquisition_of_kozilek

