should   = require 'should'
parser   = require '../parser'
indices  = require './fixtures/indices'
sets     = require './fixtures/sets'
fixtures = require './fixtures'

card_matches_fixture = (fixture) ->
  fixtures.matcher parser.card, fixtures.card fixture

language_matches_fixture = (fixture) ->
  fixtures.matcher parser.language, fixtures.language fixture

parser_builds_index = (func, fixture) ->
  (done) ->
    func fixtures.web('gatherer_index'), (err, obj) ->
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
      parser.set fixtures.web('homelands_pg1'), (err, obj) ->
        obj.should.eql sets.homelands_pg1.response
        done()

  describe 'card parser', ->
    describe 'basic types', ->
      it 'can parse an artifact', card_matches_fixture 'serrated_arrows'
      it 'can parse an enchantment', card_matches_fixture 'aether_storm'
      it 'can parse an instant', card_matches_fixture 'tunnel'
      it 'can parse a planeswalker', card_matches_fixture 'ajani_goldmane'
      it 'can parse a sorcery', card_matches_fixture 'recall'
      it 'can parse a vanguard', card_matches_fixture 'akroma_angel_of_wrath_avatar'

    describe 'assorted cards', ->
      it 'can parse An-Havva Constable', card_matches_fixture 'anhavva_constable'
      it 'can parse Diamond Faerie', card_matches_fixture 'diamond_faerie'
      it 'can parse Darksteel Colossus', card_matches_fixture 'darksteel_colossus'
      it 'can parse Phantasmal Sphere', card_matches_fixture 'phantasmal_sphere'

    describe 'cards with specific features', ->
      it 'can parse a card with converted mana cost 0', card_matches_fixture 'ancestral_vision'
      it 'can parse a card with hybrid mana', card_matches_fixture 'flame_javelin'
      it 'can parse a card with phyrexian mana', card_matches_fixture 'vault_skirge'
      it 'can parse the first part of a multipart card', card_matches_fixture 'fire'
      it 'can parse the second part of a multipart card', card_matches_fixture 'ice'
      it 'can parse a card with tap and untap symbols', card_matches_fixture 'crackleburr'
      it 'can parse a card without abilities', card_matches_fixture 'hill_giant'
      it 'can parse the first side of a transforming card', card_matches_fixture 'afflicted_deserter'
      it 'can parse the second side of a transforming card', card_matches_fixture 'werewolf_ransacker'
      it 'can parse a card with multiline flavor text', card_matches_fixture 'canyon_minotaur'
      it 'can parse a card with quoted flavor text and no attribution', card_matches_fixture 'akroma_angel_of_wrath_de'

    describe 'cards in other languages', ->
      it "can provide a card's details in German", card_matches_fixture 'birds_of_paradise_de'
      it "can provide a card's details in French", card_matches_fixture 'birds_of_paradise_fr'
      it "can provide a card's details in Japanse", card_matches_fixture 'birds_of_paradise_ja'
      it "can provide a card's details in Russian", card_matches_fixture 'birds_of_paradise_ru'
      it "can provide a card's details in Chinese Traditional", card_matches_fixture 'birds_of_paradise_zh_tw'
      it "can provide a card's details in Chinese Simplified", card_matches_fixture 'birds_of_paradise_zh_cn'

    describe 'cards from un-sets', ->
      it 'can parse cards with fractional power', card_matches_fixture 'cardpecker'
      it 'can parse cards with fractional toughness', card_matches_fixture 'cheap_ass'

  describe 'language parser', ->
    it "can provide a card's language details", language_matches_fixture 'birds_of_paradise'
    it "can provide a card's language details for a card without translations", language_matches_fixture 'black_lotus'
    it "can provide a card's language details for a card with all translations", language_matches_fixture 'drowned_catacomb'
    it 'can work around Portuguese language bug', language_matches_fixture 'inquisition_of_kozilek'
