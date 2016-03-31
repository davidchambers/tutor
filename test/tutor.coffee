assert    = require 'assert'
{exec}    = require 'child_process'
fs        = require 'fs'
url       = require 'url'

nock      = require 'nock'
Q         = require 'q'
_         = require 'underscore'

gatherer  = require '../lib/gatherer'
tutor     = require '..'


card_url = (args...) ->
  gatherer.card.url(args...).substr(gatherer.origin.length)

capitalize = (text) -> text.replace /./, (chr) -> chr.toUpperCase()

toSlug = (value) ->
  "#{value}".toLowerCase().replace(/[ ]/g, '-').replace(/[^\w-]/g, '')

eq = assert.strictEqual

index = (fn, test) -> (done) ->
  scope = nock gatherer.origin
    .get '/Pages/Default.aspx'
    .replyWithFile 200, "#{__dirname}/fixtures/index.html"

  fn (err, data) ->
    test err, data
    scope.done()
    done()

page_ranges =
  'Apocalypse':           [0..1]
  'Eventide':             [0..1]
  'Future Sight':         [0..1]
  'Lorwyn':               [0..2]
  'New Phyrexia':         [0..1]
  'Rise of the Eldrazi':  [0..2]
  'Saviors of Kamigawa':  [0..1]
  'Shadowmoor':           [0..2]
  'Unhinged':             [0..1]
  'Vanguard':             [0..1]

set = (name, test) -> (done) ->
  filenames = _.map page_ranges[name], (suffix) ->
    "#{__dirname}/fixtures/sets/#{toSlug name}~#{suffix}"

  promises = _.map filenames, (filename) ->
    deferred = Q.defer()
    fs.readFile filename, 'utf8', deferred.makeNodeResolver()
    deferred.promise

  Q.all promises
  .done (bodies) ->
    scope = nock gatherer.origin
    _.each _.zip(filenames, bodies), ([filename, body]) ->
      scope
        .get url.parse(body).path
        .replyWithFile 200, "#{filename}.html"

    tutor.set name, (err, cards) ->
      test err, cards
      scope.done()
      done()

card = (details, test) -> (done) ->
  switch
    when _.isNumber details then details = id: details
    when _.isString details then details = name: details

  scope = nock gatherer.origin
  for resource in ['details', 'languages', 'printings']
    parts = [toSlug details.id ? details.name]
    parts.push toSlug details.name if 'id' of details and 'name' of details
    parts.push resource
    scope
      .get card_url "#{capitalize resource}.aspx", details
      .replyWithFile 200, "#{__dirname}/fixtures/cards/#{parts.join('~')}.html"
    if (pages = details._pages?[resource]) > 1
      for page in [2..pages]
        scope
          .get card_url "#{capitalize resource}.aspx", details, {page}
          .replyWithFile 200, "#{__dirname}/fixtures/cards/#{parts.join('~')}~#{page}.html"

  tutor.card details, (err, card) ->
    test err, card
    scope.done()
    done()


describe 'tutor.formats', ->

  it 'provides an array of format names',
    index tutor.formats, (err, formatNames) ->
      eq err, null
      assert _.isArray formatNames
      assert _.contains formatNames, 'Invasion Block'


describe 'tutor.sets', ->

  it 'provides an array of set names',
    index tutor.sets, (err, setNames) ->
      eq err, null
      assert _.isArray setNames
      assert _.contains setNames, 'Arabian Nights'


describe 'tutor.types', ->

  it 'provides an array of types',
    index tutor.types, (err, types) ->
      eq err, null
      assert _.isArray types
      assert _.contains types, 'Land'


describe 'tutor.set', ->

  it 'extracts names',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[0].name, 'Ajani Goldmane'

  it 'extracts mana costs',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[0].name, 'Ajani Goldmane'
      eq cards[0].mana_cost, '{2}{W}{W}'

  it 'extracts mana costs containing hybrid mana symbols',
    set 'Eventide', (err, cards) ->
      eq err, null
      eq cards[99].name, 'Crackleburr'
      eq cards[99].mana_cost, '{1}{U/R}{U/R}'

  it 'extracts mana costs containing Phyrexian mana symbols',
    set 'New Phyrexia', (err, cards) ->
      eq err, null
      eq cards[75].name, 'Vault Skirge'
      eq cards[75].mana_cost, '{1}{B/P}'

  it 'extracts mana costs containing double-digit mana symbols', #71
    set 'Rise of the Eldrazi', (err, cards) ->
      eq err, null
      eq cards[11].name, 'Ulamog, the Infinite Gyre'
      eq cards[11].mana_cost, '{11}'

  it 'includes mana costs discerningly',
    set 'Future Sight', (err, cards) ->
      eq err, null
      eq cards[176].name, 'Horizon Canopy'
      assert not _.has cards[176], 'mana_cost'
      eq cards[41].name, 'Pact of Negation'
      assert _.has cards[41], 'mana_cost'

  it 'calculates converted mana costs',
    set 'Shadowmoor', (err, cards) ->
      eq err, null
      eq cards[91].name, 'Flame Javelin'
      eq cards[91].mana_cost, '{2/R}{2/R}{2/R}'
      eq cards[91].converted_mana_cost, 6

  it 'extracts supertypes',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[246].name, 'Doran, the Siege Tower'
      eq cards[246].supertypes.length, 1
      eq cards[246].supertypes[0], 'Legendary'

  it 'extracts types',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[246].name, 'Doran, the Siege Tower'
      eq cards[246].types.length, 1
      eq cards[246].types[0], 'Creature'

  it 'extracts subtypes',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[246].name, 'Doran, the Siege Tower'
      eq cards[246].subtypes.length, 2
      eq cards[246].subtypes[0], 'Treefolk'
      eq cards[246].subtypes[1], 'Shaman'

  it 'extracts rules text',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[75].text, '''
        Flying

        When Mulldrifter enters the battlefield, draw two cards.

        Evoke {2}{U} (You may cast this spell for its evoke cost. \
        If you do, it's sacrificed when it enters the battlefield.)
      '''

  it 'handles consecutive hybrid mana symbols',
    set 'Eventide', (err, cards) ->
      eq err, null
      eq cards[138].text, '''
        {R/W}: Figure of Destiny becomes a Kithkin Spirit with base \
        power and toughness 2/2.

        {R/W}{R/W}{R/W}: If Figure of Destiny is a Spirit, it becomes \
        a Kithkin Spirit Warrior with base power and toughness 4/4.

        {R/W}{R/W}{R/W}{R/W}{R/W}{R/W}: If Figure of Destiny is a \
        Warrior, it becomes a Kithkin Spirit Warrior Avatar with base \
        power and toughness 8/8, flying, and first strike.
      '''

  it.skip 'extracts color indicators',
    set 'Future Sight', (err, cards) ->
      eq err, null
      eq cards[173].name, 'Dryad Arbor'
      eq cards[173].color_indicator, 'Green'

  it.skip 'includes color indicators discerningly',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      for card in cards
        assert not _.has card, 'color_indicator'

  it 'extracts image_url and gatherer_url', #73
    set 'Lorwyn', (err, cards) ->
      eq err, null
      for card in cards
        assert _.has card, 'image_url'
        assert _.has card, 'gatherer_url'

  it 'extracts stats',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[77].name, 'Pestermite'
      eq cards[77].power, 2
      eq cards[77].toughness, 1

  it 'handles fractional stats', #39
    set 'Unhinged', (err, cards) ->
      eq err, null
      eq cards[48].name, 'Bad Ass'
      eq cards[48].power, 3.5
      eq cards[48].toughness, 1
      eq cards[4].name, 'Cheap Ass'
      eq cards[4].power, 1
      eq cards[4].toughness, 3.5
      eq cards[15].name, 'Little Girl'
      eq cards[15].power, 0.5
      eq cards[15].toughness, 0.5

  it 'handles dynamic stats',
    set 'Future Sight', (err, cards) ->
      eq err, null
      eq cards[152].name, 'Tarmogoyf'
      eq cards[152].power, '*'
      eq cards[152].toughness, '1+*'

  it 'extracts loyalties',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[0].name, 'Ajani Goldmane'
      eq cards[0].loyalty, 4

  it 'includes loyalties discerningly',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[77].name, 'Pestermite'
      assert not _.has cards[77], 'loyalty'

  it 'extracts hand modifiers',
    set 'Vanguard', (err, cards) ->
      eq err, null
      eq cards[17].name, 'Eladamri'
      eq cards[17].hand_modifier, -1

  it 'extracts life modifiers',
    set 'Vanguard', (err, cards) ->
      eq err, null
      eq cards[17].name, 'Eladamri'
      eq cards[17].life_modifier, 15

  it 'includes expansion',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq card.expansion, 'Lorwyn' for card in cards

  it 'extracts rarities',
    set 'New Phyrexia', (err, cards) ->
      eq err, null
      eq cards[129].name, 'Batterskull'
      eq cards[129].rarity, 'Mythic Rare'
      eq cards[103].name, 'Birthing Pod'
      eq cards[103].rarity, 'Rare'
      eq cards[56].name, 'Dismember'
      eq cards[56].rarity, 'Uncommon'
      eq cards[34].name, 'Gitaxian Probe'
      eq cards[34].rarity, 'Common'
      eq cards[167].name, 'Island'
      eq cards[167].rarity, 'Land'

  it 'extracts versions',
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards[0].name, 'Ajani Goldmane'
      eq cards[0].versions['Lorwyn'], 'Rare'
      eq cards[0].versions['Magic 2010'], 'Mythic Rare'
      eq cards[0].versions['Magic 2011'], 'Mythic Rare'

  it 'includes all versions of each basic land', #66
    set 'Lorwyn', (err, cards) ->
      eq err, null
      eq cards.length, 301
      eq cards[281].name, 'Plains'
      eq cards[282].name, 'Plains'
      eq cards[283].name, 'Plains'
      eq cards[284].name, 'Plains'
      eq cards[281].gatherer_url, 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=143630'
      eq cards[282].gatherer_url, 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=143621'
      eq cards[283].gatherer_url, 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=143622'
      eq cards[284].gatherer_url, 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=143620'
      eq cards[281].image_url, 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=143630&type=card'
      eq cards[282].image_url, 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=143621&type=card'
      eq cards[283].image_url, 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=143622&type=card'
      eq cards[284].image_url, 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=143620&type=card'

  it 'handles split cards', #86
    set 'Apocalypse', (err, cards) ->
      eq err, null
      eq cards[127].name, 'Fire'
      eq cards[129].name, 'Ice'

  it 'handles flip cards', #86
    set 'Saviors of Kamigawa', (err, cards) ->
      eq err, null
      eq cards[35].name, 'Erayo, Soratami Ascendant'
      eq cards[36].name, "Erayo's Essence"


describe 'tutor.card', ->

  it 'extracts name',
    card 'Hill Giant', (err, card) ->
      eq err, null
      eq card.name, 'Hill Giant'

  it 'extracts mana cost',
    card 'Hill Giant', (err, card) ->
      eq err, null
      eq card.mana_cost, '{3}{R}'

  it 'extracts mana cost containing hybrid mana symbols',
    card 'Crackleburr', (err, card) ->
      eq err, null
      eq card.mana_cost, '{1}{U/R}{U/R}'

  it 'extracts mana cost containing Phyrexian mana symbols',
    card 'Vault Skirge', (err, card) ->
      eq err, null
      eq card.mana_cost, '{1}{B/P}'

  it 'extracts mana cost containing colorless mana symbols',
    card 'Kozilek, the Great Distortion', (err, card) ->
      eq err, null
      eq card.mana_cost, '{8}{C}{C}'

  it 'includes mana cost only if present',
    card 'Ancestral Vision', (err, card) ->
      eq err, null
      assert not _.has card, 'mana_cost'

  it 'extracts converted mana cost',
    card 'Hill Giant', (err, card) ->
      eq err, null
      eq card.converted_mana_cost, 4

  it 'extracts supertypes',
    card 'Diamond Faerie', (err, card) ->
      eq err, null
      assert.deepEqual card.supertypes, ['Snow']

  it 'extracts types',
    card 'Diamond Faerie', (err, card) ->
      eq err, null
      assert.deepEqual card.types, ['Creature']

  it 'extracts subtypes',
    card 'Diamond Faerie', (err, card) ->
      eq err, null
      assert.deepEqual card.subtypes, ['Faerie']

  it 'extracts rules text',
    card 'Braids, Cabal Minion', (err, card) ->
      eq err, null
      eq card.text, '''
        At the beginning of each player's upkeep, that player sacrifices \
        an artifact, creature, or land.
      '''

  it 'recognizes tap and untap symbols',
    card 'Crackleburr', (err, card) ->
      eq err, null
      eq card.text, '''
        {U/R}{U/R}, {T}, Tap two untapped red creatures you control: \
        Crackleburr deals 3 damage to target creature or player.

        {U/R}{U/R}, {Q}, Untap two tapped blue creatures you control: \
        Return target creature to its owner's hand. \
        ({Q} is the untap symbol.)
      '''

  it 'recognizes colorless mana symbols',
    card 'Sol Ring', (err, card) ->
      eq err, null
      eq card.text, '''
        {T}: Add {C}{C} to your mana pool.
      '''

  it 'extracts flavor text from card identified by id',
    card 2960, (err, card) ->
      eq err, null
      eq card.flavor_text, '''
        Joskun and the other Constables serve with passion, \
        if not with grace.
      '''
      eq card.flavor_text_attribution, 'Devin, Faerie Noble'

  it 'ignores flavor text of card identified by name',
    card 'Hill Giant', (err, card) ->
      eq err, null
      assert not _.has card, 'flavor_text'

  it 'extracts color indicator',
    card 'Ancestral Vision', (err, card) ->
      eq err, null
      eq card.color_indicator, 'Blue'
      assert not _.has card, 'mana_cost'

  it 'includes color indicator only if present',
    card 'Hill Giant', (err, card) ->
      eq err, null
      assert not _.has card, 'color_indicator'

  it 'extracts watermark',
    card 'Vault Skirge', (err, card) ->
      eq err, null
      eq card.watermark, 'Phyrexian'

  it 'extracts power',
    card 'Hill Giant', (err, card) ->
      eq err, null
      eq card.power, 3

  it 'extracts decimal power',
    card 'Cardpecker', (err, card) ->
      eq err, null
      eq card.power, 1.5

  it 'extracts toughness',
    card 'Hill Giant', (err, card) ->
      eq err, null
      eq card.toughness, 3

  it 'extracts decimal toughness',
    card 'Cheap Ass', (err, card) ->
      eq err, null
      eq card.toughness, 3.5

  it 'extracts dynamic toughness',
    card 2960, (err, card) ->
      eq err, null
      eq card.toughness, '1+*'

  it 'extracts loyalty',
    card 'Ajani Goldmane', (err, card) ->
      eq err, null
      eq card.loyalty, 4

  it 'includes loyalty only if present',
    card 'Hill Giant', (err, card) ->
      eq err, null
      assert not _.has card, 'loyalty'

  it 'extracts hand modifier',
    card 'Akroma, Angel of Wrath Avatar', (err, card) ->
      eq err, null
      eq card.hand_modifier, 1

  it 'extracts life modifier',
    card 'Akroma, Angel of Wrath Avatar', (err, card) ->
      eq err, null
      eq card.life_modifier, 7

  it 'extracts expansion from card identified by id',
    card 2960, (err, card) ->
      eq err, null
      eq card.expansion, 'Homelands'

  it 'extracts an image_url and gatherer_url for a card identified by name', #73
    card 'Braids, Cabal Minion', (err, card) ->
      eq err, null
      eq card.image_url, 'http://gatherer.wizards.com/Handlers/Image.ashx?type=card&name=Braids%2C%20Cabal%20Minion'
      eq card.gatherer_url, 'http://gatherer.wizards.com/Pages/Card/Details.aspx?name=Braids%2C%20Cabal%20Minion'

  it 'ignores expansion of card identified by name',
    card 'Hill Giant', (err, card) ->
      eq err, null
      assert not _.has card, 'expansion'

  it 'extracts rarity from card identified by id',
    card 2960, (err, card) ->
      eq err, null
      eq card.rarity, 'Rare'

  it 'extracts an image_url and gatherer_url from card identified by id', #73
    card 2960, (err, card) ->
      eq err, null
      eq card.image_url, 'http://gatherer.wizards.com/Handlers/Image.ashx?type=card&multiverseid=2960'
      eq card.gatherer_url, 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2960'

  it 'ignores rarity of card identified by name',
    card 'Hill Giant', (err, card) ->
      eq err, null
      assert not _.has card, 'rarity'

  it 'extracts number from card identified by id',
    card 262698, (err, card) ->
      eq err, null
      eq card.number, '81b'

  it 'ignores number of card identified by name',
    card 'Ancestral Vision', (err, card) ->
      eq err, null
      assert not _.has card, 'number'

  it 'extracts artist from card identified by id',
    card 2960, (err, card) ->
      eq err, null
      eq card.artist, 'Dan Frazier'

  it 'ignores artist of card identified by name',
    card 'Hill Giant', (err, card) ->
      eq err, null
      assert not _.has card, 'artist'

  it 'extracts versions',
    card 'Ajani Goldmane', (err, card) ->
      eq err, null
      assert.deepEqual card.versions,
        140233:
          expansion: 'Lorwyn'
          rarity: 'Rare'
        191239:
          expansion: 'Magic 2010'
          rarity: 'Mythic Rare'
        205957:
          expansion: 'Magic 2011'
          rarity: 'Mythic Rare'

  it 'extracts version from card with exactly one version', #51
    card 'Cheap Ass', (err, card) ->
      eq err, null
      assert.deepEqual card.versions,
        74220:
          expansion: 'Unhinged'
          rarity: 'Common'

  it 'extracts community rating',
    card 'Ajani Goldmane', (err, card) ->
      eq err, null
      {rating, votes} = card.community_rating
      assert typeof rating is 'number', 'rating must be a number'
      assert 0 <= rating <= 5,          'rating must be between 0 and 5'
      assert typeof votes is 'number',  'votes must be a number'
      assert 0 <= votes,                'votes must not be negative'
      assert votes % 1 is 0,            'votes must be an integer'

  it 'extracts rulings',
    card 'Ajani Goldmane', (err, card) ->
      eq err, null
      eq card.rulings[0].length, 2
      eq card.rulings[0][0], '2007-10-01'
      eq card.rulings[0][1], '''
        The vigilance granted to a creature by the second ability \
        remains until the end of the turn even if the +1/+1 counter \
        is removed.
      '''
      eq card.rulings[1].length, 2
      eq card.rulings[1][0], '2007-10-01'
      eq card.rulings[1][1], '''
        The power and toughness of the Avatar created by the third \
        ability will change as your life total changes.
      '''

  it 'extracts rulings for back face of double-faced card',
    card 'Werewolf Ransacker', (err, card) ->
      eq err, null
      assert card.rulings.length

  assert_languages_equal = (expected) -> (err, card) ->
    eq err, null
    codes = _.keys(expected).sort()
    assert.deepEqual _.keys(card.languages).sort(), codes
    _.each card.languages, (value, code) ->
      eq value.name, expected[code].name
      assert.deepEqual value.ids, expected[code].ids

  it 'extracts languages',
    card 262698, assert_languages_equal
      'de'    : ids: [337042], name: 'Werwolf-Einsacker'
      'es'    : ids: [337213], name: 'Saqueador licántropo'
      'fr'    : ids: [336700], name: 'Saccageur loup-garou'
      'it'    : ids: [337384], name: 'Predone Mannaro'
      'ja'    : ids: [337555], name: '\u72FC\u7537\u306E\u8352\u3089\u3057\u5C4B'
      'kr'    : ids: [336187], name: '\uB291\uB300\uC778\uAC04 \uC57D\uD0C8\uC790'
      'pt-BR' : ids: [336529], name: 'Lobisomem Saqueador'
      'ru'    : ids: [336871], name: '\u0412\u0435\u0440\u0432\u043E\u043B\u044C\u0444-\u041F\u043E\u0433\u0440\u043E\u043C\u0449\u0438\u043A'
      'zh-CN' : ids: [336358], name: '\u641C\u62EC\u72FC\u4EBA'
      'zh-TW' : ids: [336016], name: '\u641C\u62EC\u72FC\u4EBA'

  it 'extracts languages for card with multiple pages of languages', #37
    card {id: 289327, _pages: languages: 2}, assert_languages_equal
      'de'    : ids: [356006, 356007, 356008, 356009, 356010], name: 'Wald'
      'es'    : ids: [365728, 365729, 365730, 365731, 365732], name: 'Bosque'
      'fr'    : ids: [356280, 356281, 356282, 356283, 356284], name: 'Forêt'
      'it'    : ids: [356554, 356555, 356556, 356557, 356558], name: 'Foresta'
      'ja'    : ids: [356828, 356829, 356830, 356831, 356832], name: '\u68ee'
      'kr'    : ids: [357650, 357651, 357652, 357653, 357654], name: '\uc232'
      'pt-BR' : ids: [357102, 357103, 357104, 357105, 357106], name: 'Floresta'
      'ru'    : ids: [355458, 355459, 355460, 355461, 355462], name: '\u041b\u0435\u0441'
      'zh-CN' : ids: [355732, 355733, 355734, 355735, 355736], name: '\u6a39\u6797'
      'zh-TW' : ids: [357376, 357377, 357378, 357379, 357380], name: '\u6811\u6797'

  it 'extracts legality info',
    card 'Braids, Cabal Minion', (err, card) ->
      eq err, null
      eq card.legality['Commander'], 'Banned'
      eq card.legality['Prismatic'], 'Legal'

  it 'parses left side of split card specified by name',
    card 'Fire', (err, card) ->
      eq err, null
      eq card.name, 'Fire'

  it 'parses right side of split card specified by name',
    card 'Ice', (err, card) ->
      eq err, null
      eq card.name, 'Ice'

  it 'parses left side of split card specified by id',
    card id: 27165, name: 'Fire', (err, card) ->
      eq err, null
      eq card.name, 'Fire'

  it 'parses right side of split card specified by id',
    card id: 27165, name: 'Ice', (err, card) ->
      eq err, null
      eq card.name, 'Ice'

  it 'parses top half of flip card specified by name',
    card 'Jushi Apprentice', (err, card) ->
      eq err, null
      eq card.name, 'Jushi Apprentice'

  it 'parses bottom half of flip card specified by name',
    card 'Tomoya the Revealer', (err, card) ->
      eq err, null
      eq card.name, 'Tomoya the Revealer'

  it 'parses top half of flip card specified by id',
    card 247175, (err, card) ->
      eq err, null
      eq card.name, 'Nezumi Graverobber'

  it 'parses bottom half of flip card specified by id',
    card id: 247175, which: 'b', (err, card) ->
      eq err, null
      eq card.name, 'Nighteyes the Desecrator'

  it 'parses front face of double-faced card specified by name',
    card 'Afflicted Deserter', (err, card) ->
      eq err, null
      eq card.name, 'Afflicted Deserter'

  it 'parses back face of double-faced card specified by name',
    card 'Werewolf Ransacker', (err, card) ->
      eq err, null
      eq card.name, 'Werewolf Ransacker'

  it 'parses back face of double-faced card specified by lower-case name', #57
    card 'werewolf ransacker', (err, card) ->
      eq err, null
      eq card.name, 'Werewolf Ransacker'

  it 'parses front face of double-faced card specified by id',
    card 262675, (err, card) ->
      eq err, null
      eq card.name, 'Afflicted Deserter'

  it 'parses back face of double-faced card specified by id',
    card 262698, (err, card) ->
      eq err, null
      eq card.name, 'Werewolf Ransacker'

  it 'allows accents to be omitted', (done) -> #52
    # tutor.card("Juzam Djinn")
    #
    #                 1           2                        3
    #                   languages
    #                  /         \
    #                 /           \
    #                /             \
    #     tutor.card --- details --- search (Juzam Djinn) ==> details (159132)
    #                \             /
    #                 \           /
    #                  \         /
    #                   printings
    #
    #  1. tutor.card("Juzam Djinn") produces three HTTP requests:
    #
    #     - GET /Pages/Card/Details.aspx?name=Juzam%20Djinn
    #     - GET /Pages/Card/Languages.aspx?name=Juzam%20Djinn
    #     - GET /Pages/Card/Printings.aspx?name=Juzam%20Djinn
    #
    #  2. Each of these requests is redirected to
    #     /Pages/Search/Default.aspx?name=+[Juzam%20Djinn]
    #
    #  3. In turn, each of *these* requests is redirected to
    #     /Pages/Card/Details.aspx?multiverseid=159132
    #
    scope = nock gatherer.origin
    for resource in ['details', 'languages', 'printings']
      scope
        .get card_url "#{capitalize resource}.aspx", name: 'Juzam Djinn'
        .reply 302, '', 'Location': '/Pages/Search/Default.aspx?name=+[Juzam Djinn]'
        .get '/Pages/Search/Default.aspx?name=+[Juzam%20Djinn]'
        .reply 302, '', 'Location': '/Pages/Card/Details.aspx?multiverseid=159132'
        .get card_url 'Details.aspx', id: 159132
        .replyWithFile 200, "#{__dirname}/fixtures/cards/159132~details.html"
        .get card_url "#{capitalize resource}.aspx", name: 'Juzám Djinn'
        .replyWithFile 200, "#{__dirname}/fixtures/cards/juzam-djinn~#{resource}.html"

    tutor.card 'Juzam Djinn', (err, card) ->
      eq err, null
      eq card.name, 'Juzám Djinn'
      scope.done()
      done()

  it 'responds with "no results" given non-existent card name', #90
    card 'fizzbuzzldspla', (err, card) ->
      eq err.constructor, Error
      eq err.message, 'no results'
      eq card, undefined


$ = (command, test) -> (done) ->
  exec "bin/#{command}", (err, stdout, stderr) ->
    test err, stdout, stderr
    done()


describe '$ tutor formats', ->

  it 'prints formats',
    $ 'tutor formats', (err, stdout) ->
      eq err, null
      assert 'Tempest Block' in stdout.split('\n')

  it 'prints JSON representation of formats',
    $ 'tutor formats --format json', (err, stdout) ->
      eq err, null
      assert 'Tempest Block' in JSON.parse stdout


describe '$ tutor sets', ->

  it 'prints sets',
    $ 'tutor sets', (err, stdout) ->
      eq err, null
      assert 'Stronghold' in stdout.split('\n')

  it 'prints JSON representation of sets',
    $ 'tutor sets --format json', (err, stdout) ->
      eq err, null
      assert 'Stronghold' in JSON.parse stdout


describe '$ tutor types', ->

  it 'prints types',
    $ 'tutor types', (err, stdout) ->
      eq err, null
      assert 'Enchantment' in stdout.split('\n')

  it 'prints JSON representation of types',
    $ 'tutor types --format json', (err, stdout) ->
      eq err, null
      assert 'Enchantment' in JSON.parse stdout


describe '$ tutor set', ->

  it 'prints summary of cards in set',
    $ 'tutor set Alliances | head -n 3', (err, stdout) ->
      eq err, null
      eq stdout, '''
        Aesthir Glider {3} 2/1 Flying Aesthir Glider can't block.
        Aesthir Glider {3} 2/1 Flying Aesthir Glider can't block.
        Agent of Stromgald {R} 1/1 {R}: Add {B} to your mana pool.

      '''

  it 'prints JSON representation of cards in set',
    $ 'tutor set Alliances --format json', (err, stdout) ->
      eq err, null
      cards = JSON.parse stdout
      eq cards[0].name, 'Aesthir Glider'
      eq cards[1].name, 'Aesthir Glider'
      eq cards[2].name, 'Agent of Stromgald'

  it 'handles sets with (one version of) exactly one basic land', #69
    $ 'tutor set "Arabian Nights" --format json', (err, stdout) ->
      eq err, null
      cards = JSON.parse stdout
      eq cards.length, 92
      eq cards[62].name, 'Mountain'

  it 'handles sets with (multiple versions of) exactly one basic land', #69
    $ 'tutor set "Premium Deck Series: Fire and Lightning" --format json', (err, stdout) ->
      eq err, null
      cards = JSON.parse stdout
      eq cards.length, 34
      eq cards[30].name, 'Mountain'
      eq cards[31].name, 'Mountain'
      eq cards[32].name, 'Mountain'
      eq cards[33].name, 'Mountain'


describe '$ tutor card', ->

  it 'prints summary of card',
    $ 'tutor card Braingeyser', (err, stdout) ->
      eq err, null
      eq stdout, 'Braingeyser {X}{U}{U} Target player draws X cards.\n'

  it 'prints JSON representation of card specified by name',
    $ 'tutor card Fireball --format json', (err, stdout) ->
      eq err, null
      eq JSON.parse(stdout).name, 'Fireball'

  it 'prints JSON representation of card specified by id',
    $ 'tutor card 987 --format json', (err, stdout) ->
      eq err, null
      eq JSON.parse(stdout).artist, 'Brian Snoddy'
