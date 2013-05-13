assert    = require 'assert'
{exec}    = require 'child_process'
fs        = require 'fs'

nock      = require 'nock'
gatherer  = require '../src/gatherer'
tutor     = require '../src/tutor'


wizards = nock gatherer.origin
card_url = (args...) ->
  gatherer.card.url(args...).substr(gatherer.origin.length)

lower = (text) -> text.toLowerCase()
upper = (text) -> text.toUpperCase()

toSlug = (value) ->
  "#{value}".toLowerCase().replace(/[ ]/g, '-').replace(/[^\w-]/g, '')

__ = (text) -> text.replace(/([^\n])\n(?!\n)/g, '$1 ')

eq = (expected, actual) ->
  assert.strictEqual expected, actual

nonexistent = {}
assert_equal = (expected) -> (err, actual) ->
  for own prop, value of expected
    if value isnt nonexistent
      assert.deepEqual actual[prop], value
    else if Object::hasOwnProperty.call actual, prop
      throw new Error "unexpected \"#{prop}\" property"

index = (fn, test) -> (done) ->
  wizards.get('/Pages/Default.aspx')
         .replyWithFile(200, __dirname + '/fixtures/index.html')
  fn (err, data) ->
    test err, data
    done()

set = (name, test) -> (done) ->
  path = "#{__dirname}/fixtures/sets/#{toSlug name}.html"
  if fs.existsSync path
    wizards.get('/Pages/Search/Default.aspx?output=spoiler' +
                "&set=%5B%22#{encodeURIComponent name}%22%5D&special=true")
           .replyWithFile(200, path)
  tutor.set name, (err, cards) ->
    test err, cards
    done()

card = (details, test) -> (done) ->
  switch typeof details
    when 'number' then details = id: details
    when 'string' then details = name: details

  for resource in ['details', 'languages', 'printings']
    parts = [toSlug details.id ? details.name]
    parts.push toSlug details.name if 'id' of details and 'name' of details
    parts.push resource
    wizards
      .get(card_url resource.replace(/./, upper) + '.aspx', details)
      .replyWithFile(200, "#{__dirname}/fixtures/cards/#{parts.join('~')}.html")
    if (pages = details._pages?[resource]) > 1
      for page in [2..pages]
        wizards
          .get(card_url resource.replace(/./, upper) + '.aspx', details, {page})
          .replyWithFile(200, "#{__dirname}/fixtures/cards/#{parts.join('~')}~#{page}.html")

  tutor.card details, (err, card) ->
    (if typeof test is 'function' then test else assert_equal test) err, card
    done()


describe 'tutor.formats', ->

  it 'provides an array of format names',
    index tutor.formats, (err, formatNames) ->
      assert formatNames instanceof Array
      assert 'Invasion Block' in formatNames


describe 'tutor.sets', ->

  it 'provides an array of set names',
    index tutor.sets, (err, setNames) ->
      assert setNames instanceof Array
      assert 'Arabian Nights' in setNames


describe 'tutor.types', ->

  it 'provides an array of types',
    index tutor.types, (err, types) ->
      assert types instanceof Array
      assert 'Land' in types


describe 'tutor.set', ->

  it 'extracts names',
    set 'Lorwyn', (err, cards) ->
      eq cards[2].name, 'Ajani Goldmane'

  it 'extracts mana costs',
    set 'Lorwyn', (err, cards) ->
      eq cards[2].name, 'Ajani Goldmane'
      eq cards[2].mana_cost, '{2}{W}{W}'

  it 'extracts mana costs containing hybrid mana symbols',
    set 'Eventide', (err, cards) ->
      eq cards[25].name, 'Crackleburr'
      eq cards[25].mana_cost, '{1}{U/R}{U/R}'

  it 'extracts mana costs containing Phyrexian mana symbols',
    set 'New Phyrexia', (err, cards) ->
      eq cards[156].name, 'Vault Skirge'
      eq cards[156].mana_cost, '{1}{B/P}'

  it 'includes mana costs discerningly',
    set 'Future Sight', (err, cards) ->
      eq cards[64].name, 'Horizon Canopy'
      eq cards[64].hasOwnProperty('mana_cost'), no
      eq cards[111].name, 'Pact of Negation'
      eq cards[111].hasOwnProperty('mana_cost'), yes

  it 'calculates converted mana costs',
    set 'Shadowmoor', (err, cards) ->
      eq cards[72].name, 'Flame Javelin'
      eq cards[72].mana_cost, '{2/R}{2/R}{2/R}'
      eq cards[72].converted_mana_cost, 6

  it 'extracts supertypes',
    set 'Lorwyn', (err, cards) ->
      eq cards[56].name, 'Doran, the Siege Tower'
      eq cards[56].supertypes.length, 1
      eq cards[56].supertypes[0], 'Legendary'

  it 'extracts types',
    set 'Lorwyn', (err, cards) ->
      eq cards[56].name, 'Doran, the Siege Tower'
      eq cards[56].types.length, 1
      eq cards[56].types[0], 'Creature'

  it 'extracts subtypes',
    set 'Lorwyn', (err, cards) ->
      eq cards[56].name, 'Doran, the Siege Tower'
      eq cards[56].subtypes.length, 2
      eq cards[56].subtypes[0], 'Treefolk'
      eq cards[56].subtypes[1], 'Shaman'

  it 'extracts rules text',
    set 'Lorwyn', (err, cards) ->
      eq cards[175].text, __ '''
        Flying

        When Mulldrifter enters the battlefield, draw two cards.

        Evoke {2}{U} (You may cast this spell for its evoke cost.
        If you do, it's sacrificed when it enters the battlefield.)
      '''

  it 'handles consecutive hybrid mana symbols',
    set 'Eventide', (err, cards) ->
      eq cards[54].text, __ '''
        {R/W}: Figure of Destiny becomes a 2/2 Kithkin Spirit.

        {R/W}{R/W}{R/W}: If Figure of Destiny is a Spirit, it becomes
        a 4/4 Kithkin Spirit Warrior.

        {R/W}{R/W}{R/W}{R/W}{R/W}{R/W}: If Figure of Destiny is a
        Warrior, it becomes an 8/8 Kithkin Spirit Warrior Avatar
        with flying and first strike.
      '''

  it 'extracts color indicators',
    set 'Future Sight', (err, cards) ->
      eq cards[34].name, 'Dryad Arbor'
      eq cards[34].color_indicator, 'Green'

  it 'includes color indicators discerningly',
    set 'Lorwyn', (err, cards) ->
      eq card.hasOwnProperty('color_indicator'), no for card in cards

  it 'extracts stats',
    set 'Lorwyn', (err, cards) ->
      eq cards[192].name, 'Pestermite'
      eq cards[192].power, 2
      eq cards[192].toughness, 1

  it 'handles fractional stats', #39
    set 'Unhinged', (err, cards) ->
      eq cards[10].name, 'Bad Ass'
      eq cards[10].power, 3.5
      eq cards[10].toughness, 1
      eq cards[20].name, 'Cheap Ass'
      eq cards[20].power, 1
      eq cards[20].toughness, 3.5
      eq cards[67].name, 'Little Girl'
      eq cards[67].power, 0.5
      eq cards[67].toughness, 0.5

  it 'handles dynamic stats',
    set 'Future Sight', (err, cards) ->
      eq cards[161].name, 'Tarmogoyf'
      eq cards[161].power, '*'
      eq cards[161].toughness, '1+*'

  it 'extracts loyalties',
    set 'Lorwyn', (err, cards) ->
      eq cards[2].name, 'Ajani Goldmane'
      eq cards[2].loyalty, 4

  it 'includes loyalties discerningly',
    set 'Lorwyn', (err, cards) ->
      eq cards[192].name, 'Pestermite'
      eq cards[192].hasOwnProperty('loyalty'), no

  it 'extracts hand modifiers',
    set 'Vanguard', (err, cards) ->
      eq cards[16].name, 'Eladamri'
      eq cards[16].hand_modifier, -1

  it 'extracts life modifiers',
    set 'Vanguard', (err, cards) ->
      eq cards[16].name, 'Eladamri'
      eq cards[16].life_modifier, 15

  it 'includes expansion',
    set 'Lorwyn', (err, cards) ->
      eq card.expansion, 'Lorwyn' for card in cards

  it 'extracts rarities',
    set 'New Phyrexia', (err, cards) ->
      eq cards[7].name, 'Batterskull'
      eq cards[7].rarity, 'Mythic Rare'
      eq cards[9].name, 'Birthing Pod'
      eq cards[9].rarity, 'Rare'
      eq cards[34].name, 'Dismember'
      eq cards[34].rarity, 'Uncommon'
      eq cards[51].name, 'Gitaxian Probe'
      eq cards[51].rarity, 'Common'
      eq cards[67].name, 'Island'
      eq cards[67].rarity, 'Land'

  it 'extracts versions',
    set 'Lorwyn', (err, cards) ->
      eq cards[2].name, 'Ajani Goldmane'
      eq cards[2].versions['Lorwyn'], 'Rare'
      eq cards[2].versions['Magic 2010'], 'Mythic Rare'
      eq cards[2].versions['Magic 2011'], 'Mythic Rare'


describe 'tutor.card', ->

  it 'extracts name',
    card 'Hill Giant', name: 'Hill Giant'

  it 'extracts mana cost',
    card 'Hill Giant', mana_cost: '{3}{R}'

  it 'extracts mana cost containing hybrid mana symbols',
    card 'Crackleburr', mana_cost: '{1}{U/R}{U/R}'

  it 'extracts mana cost containing Phyrexian mana symbols',
    card 'Vault Skirge', mana_cost: '{1}{B/P}'

  it 'includes mana cost only if present',
    card 'Ancestral Vision', mana_cost: nonexistent

  it 'extracts converted mana cost',
    card 'Hill Giant', converted_mana_cost: 4

  it 'extracts supertypes',
    card 'Diamond Faerie', supertypes: ['Snow']

  it 'extracts types',
    card 'Diamond Faerie', types: ['Creature']

  it 'extracts subtypes',
    card 'Diamond Faerie', subtypes: ['Faerie']

  it 'extracts rules text',
    card 'Braids, Cabal Minion', text: __ '''
      At the beginning of each player's upkeep, that player sacrifices
      an artifact, creature, or land.
    '''

  it 'recognizes tap and untap symbols',
    card 'Crackleburr', text: __ '''
      {U/R}{U/R}, {T}, Tap two untapped red creatures you control:
      Crackleburr deals 3 damage to target creature or player.

      {U/R}{U/R}, {Q}, Untap two tapped blue creatures you control:
      Return target creature to its owner's hand.
      ({Q} is the untap symbol.)
    '''

  it 'extracts flavor text from card identified by id',
    card 2960,
      flavor_text: __ '''
        Joskun and the other Constables serve with passion,
        if not with grace.
      '''
      flavor_text_attribution: 'Devin, Faerie Noble'

  it 'ignores flavor text of card identified by name',
    card 'Hill Giant', flavor_text: nonexistent

  it 'extracts color indicator',
    card 'Ancestral Vision', mana_cost: nonexistent, color_indicator: 'Blue'

  it 'includes color indicator only if present',
    card 'Hill Giant', color_indicator: nonexistent

  it 'extracts watermark',
    card 'Vault Skirge', watermark: 'Phyrexian'

  it 'extracts power',
    card 'Hill Giant', power: 3

  it 'extracts decimal power',
    card 'Cardpecker', power: 1.5

  it 'extracts toughness',
    card 'Hill Giant', toughness: 3

  it 'extracts decimal toughness',
    card 'Cheap Ass', toughness: 3.5

  it 'extracts dynamic toughness',
    card 2960, toughness: '1+*'

  it 'extracts loyalty',
    card 'Ajani Goldmane', loyalty: 4

  it 'includes loyalty only if present',
    card 'Hill Giant', loyalty: nonexistent

  it 'extracts hand modifier',
    card 'Akroma, Angel of Wrath Avatar', hand_modifier: 1

  it 'extracts life modifier',
    card 'Akroma, Angel of Wrath Avatar', life_modifier: 7

  it 'extracts expansion from card identified by id',
    card 2960, expansion: 'Homelands'

  it 'ignores expansion of card identified by name',
    card 'Hill Giant', expansion: nonexistent

  it 'extracts rarity from card identified by id',
    card 2960, rarity: 'Rare'

  it 'ignores rarity of card identified by name',
    card 'Hill Giant', rarity: nonexistent

  it 'extracts number from card identified by id',
    card 262698, number: '81b'

  it 'ignores number of card identified by name',
    card 'Ancestral Vision', number: nonexistent

  it 'extracts artist from card identified by id',
    card 2960, artist: 'Dan Frazier'

  it 'ignores artist of card identified by name',
    card 'Hill Giant', artist: nonexistent

  it 'extracts versions',
    card 'Ajani Goldmane', versions:
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
    card 'Cheap Ass', versions:
      74220:
        expansion: 'Unhinged'
        rarity: 'Common'

  it 'extracts community rating',
    card 'Ajani Goldmane', (err, card) ->
      {rating, votes} = card.community_rating
      assert typeof rating is 'number', 'rating must be a number'
      assert 0 <= rating <= 5,          'rating must be between 0 and 5'
      assert typeof votes is 'number',  'votes must be a number'
      assert 0 <= votes,                'votes must not be negative'
      assert votes % 1 is 0,            'votes must be an integer'

  it 'extracts rulings',
    card 'Ajani Goldmane', rulings: [
      ['2007-10-01', __ '''
        The vigilance granted to a creature by the second ability
        remains until the end of the turn even if the +1/+1 counter
        is removed.
      ''']
      ['2007-10-01', __ '''
        The power and toughness of the Avatar created by the third
        ability will change as your life total changes.
      ''']
    ]

  it 'extracts rulings for back face of double-faced card',
    card 'Werewolf Ransacker', (err, card) ->
      assert card.rulings.length

  assert_languages_equal = (expected) ->
    (err, card) ->
      codes = Object.keys(expected).sort()
      assert.deepEqual Object.keys(card.languages).sort(), codes
      for code in codes
        assert.strictEqual card.languages[code].name, expected[code].name
        assert.deepEqual   card.languages[code].ids,  expected[code].ids

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
      assert.strictEqual card.legality['Commander'], 'Special: Banned as Commander'
      assert.strictEqual card.legality['Prismatic'], 'Legal'

  it 'parses left side of split card specified by name',
    card 'Fire', name: 'Fire'

  it 'parses right side of split card specified by name',
    card 'Ice', name: 'Ice'

  it 'parses left side of split card specified by id',
    card id: 27165, name: 'Fire', {name: 'Fire'}

  it 'parses right side of split card specified by id',
    card id: 27165, name: 'Ice', {name: 'Ice'}

  it 'parses top half of flip card specified by name',
    card 'Jushi Apprentice', name: 'Jushi Apprentice'

  it 'parses bottom half of flip card specified by name',
    card 'Tomoya the Revealer', name: 'Tomoya the Revealer'

  it 'parses top half of flip card specified by id',
    card 247175, name: 'Nezumi Graverobber'

  it 'parses bottom half of flip card specified by id',
    card id: 247175, which: 'b', {name: 'Nighteyes the Desecrator'}

  it 'parses front face of double-faced card specified by name',
    card 'Afflicted Deserter', name: 'Afflicted Deserter'

  it 'parses back face of double-faced card specified by name',
    card 'Werewolf Ransacker', name: 'Werewolf Ransacker'

  it 'parses front face of double-faced card specified by id',
    card 262675, name: 'Afflicted Deserter'

  it 'parses back face of double-faced card specified by id',
    card 262698, name: 'Werewolf Ransacker'


$ = (command, test) -> (done) ->
  exec "bin/#{command}", (err, stdout, stderr) ->
    if typeof test is 'string'
      assert.strictEqual stdout, "#{test}\n"
    else
      test err, stdout, stderr
    done()


describe '$ tutor set', ->

  it 'prints summary of cards in set',
    $ 'tutor set Alliances | head -n 2', '''
      Aesthir Glider {3} 2/1 Flying Aesthir Glider can't block.
      Agent of Stromgald {R} 1/1 {R}: Add {B} to your mana pool.
    '''

  it 'prints JSON representation of cards in set',
    $ 'tutor set Alliances --format json', (err, stdout) ->
      cards = JSON.parse stdout
      eq cards[0].name, 'Aesthir Glider'
      eq cards[1].name, 'Agent of Stromgald'


describe '$ tutor card', ->

  it 'prints summary of card',
    $ 'tutor card Braingeyser',
      'Braingeyser {X}{U}{U} Target player draws X cards.'

  it 'prints JSON representation of card specified by name',
    $ 'tutor card Fireball --format json', (err, stdout) ->
      assert.strictEqual JSON.parse(stdout).name, 'Fireball'

  it 'prints JSON representation of card specified by id',
    $ 'tutor card 987 --format json', (err, stdout) ->
      assert.strictEqual JSON.parse(stdout).artist, 'Brian Snoddy'
