{exec}  = require 'child_process'

request = require 'request'
{_}     = require 'underscore'


__ = (text) -> text.replace(/([^\n])\n(?!\n)/g, '$1 ')

task 'build', 'generate mtg-api.js', ->
  exec __ """
    echo "require('http-proxy').createServer(3000, 'localhost').listen(80)"
    | cat - mtg-api.coffee | coffee --compile --stdio > mtg-api.js"""

option null, '--url [URL]', 'select the URL against which to run the tests'

task 'test', 'run the mtg-api test suite', ({url}) ->
  url = (url or 'http://localhost:3000/').replace /// /?$ ///, '/card/'

  count = remaining = Object.keys(tests).length
  failures = []
  fail = (reason, key, attr) ->
    failures.push key
    message = "\033[0;31m[fail]\033[0m tests['#{key}']"
    message += "['#{attr}']" if attr
    message += ": #{reason}"
    console.log message

  run = (key, expected) ->
    components = (encodeURIComponent comp for comp in key.split '/')
    request url + components.join('/'), (error, response, body) ->
      errors = []
      d = _.keys data = JSON.parse body
      e = _.keys expected

      if (e_only = _.difference e, d).length
        errors.push """expected "#{e_only.join('", "')}" amongst keys"""

      if (d_only = _.difference d, e).length
        errors.push """didn't expect "#{d_only.join('", "')}" amongst keys"""

      if errors.length
        fail errors.join('; '), key
      else
        for attr, value of data
          unless _.isEqual value, expected[attr]
            fail "expected (#{expected[attr]}) not (#{value})", key, attr
            break

      unless remaining -= 1
        if failures.length
          console.log "\n#{count - failures.length}/#{count} tests passed"
        else
          console.log "\n\033[0;32m#{count}/#{count} tests passed\033[0m"

  run key, test for key, test of tests

tests =

  3:
    name: 'Black Lotus'
    mana_cost: '[0]'
    converted_mana_cost: 0
    type: 'Artifact'
    text: __ """
      [Tap], Sacrifice Black Lotus: Add three mana of any one color to
      your mana pool.
    """
    expansion: 'Limited Edition Alpha'
    rarity: 'Rare'
    artist: 'Christopher Rush'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3'
    versions:
      3:
        expansion: 'Limited Edition Alpha'
        rarity: 'Rare'
      298:
        expansion: 'Limited Edition Beta'
        rarity: 'Rare'
      600:
        expansion: 'Unlimited Edition'
        rarity: 'Rare'

  1496:
    name: 'Recall'
    mana_cost: '[X][X][U]'
    converted_mana_cost: 1
    type: 'Sorcery'
    text: __ """
      Discard X cards, then return a card from your graveyard to your
      hand for each card discarded this way. Exile Recall.
    """
    expansion: 'Legends'
    rarity: 'Rare'
    artist: 'Brian Snoddy'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=1496'
    versions:
      1496:
        expansion: 'Legends'
        rarity: 'Rare'
      2812:
        expansion: 'Chronicles'
        rarity: 'Uncommon'
      3936:
        expansion: 'Fifth Edition'
        rarity: 'Rare'
      11467:
        expansion: 'Classic Sixth Edition'
        rarity: 'Rare'
      201161:
        expansion: 'Masters Edition III'
        rarity: 'Uncommon'

  2960:
    name: 'An-Havva Constable'
    mana_cost: '[1][G][G]'
    converted_mana_cost: 3
    type: 'Creature'
    subtype: 'Human'
    text: __ """
      An-Havva Constable's toughness is equal to 1 plus the number of
      green creatures on the battlefield.
    """
    flavor_text: __ """
      Joskun and the other Constables serve with passion, if not with
      grace.
    """
    flavor_text_attribution: 'Devin, Faerie Noble'
    power: 2
    toughness: '1+*'
    expansion: 'Homelands'
    rarity: 'Rare'
    artist: 'Dan Frazier'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2960'
    versions:
      2960:
        expansion: 'Homelands'
        rarity: 'Rare'
      3960:
        expansion: 'Fifth Edition'
        rarity: 'Rare'

  '27166/Ice':
    name: 'Ice'
    mana_cost: '[1][U]'
    converted_mana_cost: 2
    type: 'Instant'
    text: __ """
      Tap target permanent.
      
      Draw a card.
    """
    expansion: 'Apocalypse'
    rarity: 'Uncommon'
    number: 128
    artist: 'Franz Vohwinkel'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=27166&part=Ice'
    versions:
      27165:
        expansion: 'Apocalypse'
        rarity: 'Uncommon'
      27166:
        expansion: 'Apocalypse'
        rarity: 'Uncommon'
      247159:
        expansion: 'Magic: The Gathering-Commander'
        rarity: 'Uncommon'

  113505:
    name: 'Ancestral Vision'
    converted_mana_cost: 0
    type: 'Sorcery'
    text: __ """
      Suspend 4\u2014[U] (Rather than cast this card from your hand,
      pay [U] and exile it with four time counters on it. At the
      beginning of your upkeep, remove a time counter. When the last
      is removed, cast it without paying its mana cost.)
      
      Target player draws three cards.
    """
    color_indicator: 'Blue'
    expansion: 'Time Spiral'
    rarity: 'Rare'
    number: 48
    artist: 'Mark Poole'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=113505'
    versions:
      113505:
        expansion: 'Time Spiral'
        rarity: 'Rare'
      189244:
        expansion: 'Duel Decks: Jace vs. Chandra'
        rarity: 'Rare'

  140233:
    name: 'Ajani Goldmane'
    mana_cost: '[2][W][W]'
    converted_mana_cost: 4
    type: 'Planeswalker'
    subtype: 'Ajani'
    text: __ """
      +1: You gain 2 life.
      
      -1: Put a +1/+1 counter on each creature you control. Those
      creatures gain vigilance until end of turn.
      
      -6: Put a white Avatar creature token onto the battlefield.
      It has "This creature's power and toughness are each equal
      to your life total."
    """
    loyalty: 4
    expansion: 'Lorwyn'
    rarity: 'Rare'
    number: 1
    artist: 'Aleksi Briclot'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=140233'
    versions:
      140233:
        expansion: 'Lorwyn'
        rarity: 'Rare'
      191239:
        expansion: 'Magic 2010'
        rarity: 'Mythic Rare'
      205957:
        expansion: 'Magic 2011'
        rarity: 'Mythic Rare'

  146017:
    name: 'Flame Javelin'
    mana_cost: '[2/R][2/R][2/R]'
    converted_mana_cost: 6
    type: 'Instant'
    text: __ """
      ([2/R] can be paid with any two mana or with [R]. This card's
      converted mana cost is 6.)
      
      Flame Javelin deals 4 damage to target creature or player.
    """
    flavor_text: __ """
      Gyara Spearhurler would have been renowned for her deadly
      accuracy, if it weren't for her deadly accuracy.
    """
    expansion: 'Shadowmoor'
    rarity: 'Uncommon'
    number: 92
    artist: 'Trevor Hairsine'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=146017'
    versions:
      146017:
        expansion: 'Shadowmoor'
        rarity: 'Uncommon'
      189220:
        expansion: 'Duel Decks: Jace vs. Chandra'
        rarity: 'Uncommon'

  191312:
    name: 'Darksteel Colossus'
    mana_cost: '[11]'
    converted_mana_cost: 11
    type: 'Artifact Creature'
    subtype: 'Golem'
    text: __ """
      Trample
      
      Darksteel Colossus is indestructible.
      
      If Darksteel Colossus would be put into a graveyard from anywhere,
      reveal Darksteel Colossus and shuffle it into its owner's library
      instead.
    """
    power: 11
    toughness: 11
    expansion: 'Magic 2010'
    rarity: 'Mythic Rare'
    number: 208
    artist: 'Carl Critchlow'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=191312'
    versions:
      48158:
        expansion: 'Darksteel'
        rarity: 'Rare'
      191312:
        expansion: 'Magic 2010'
        rarity: 'Mythic Rare'

  214064:
    name: 'Hero of Bladehold'
    mana_cost: '[2][W][W]'
    converted_mana_cost: 4
    type: 'Creature'
    subtype: 'Human Knight'
    text: __ """
      Battle cry (Whenever this creature attacks, each other attacking
      creature gets +1/+0 until end of turn.)
      
      Whenever Hero of Bladehold attacks, put two 1/1 white Soldier
      creature tokens onto the battlefield tapped and attacking.
    """
    watermark: 'Mirran'
    power: 3
    toughness: 4
    expansion: 'Mirrodin Besieged'
    rarity: 'Mythic Rare'
    number: 8
    artist: 'Austin Hsu'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=214064'
    versions:
      214064:
        expansion: 'Mirrodin Besieged'
        rarity: 'Mythic Rare'

  "Æther Storm":
    name: "Æther Storm"
    mana_cost: '[3][U]'
    converted_mana_cost: 4
    type: 'Enchantment'
    text: __ """
      Creature spells can't be cast.
      
      Pay 4 life: Destroy Æther Storm. It can't be regenerated. Any
      player may activate this ability.
    """
    versions:
      2935:
        expansion: 'Homelands'
        rarity: 'Uncommon'
      3891:
        expansion: 'Fifth Edition'
        rarity: 'Uncommon'
      184722:
        expansion: 'Masters Edition II'
        rarity: 'Uncommon'

  'Phantasmal Sphere':
    name: 'Phantasmal Sphere'
    mana_cost: '[1][U]'
    converted_mana_cost: 2
    type: 'Creature'
    subtype: 'Illusion'
    text: __ """
      Flying
      
      At the beginning of your upkeep, put a +1/+1 counter on Phantasmal
      Sphere, then sacrifice Phantasmal Sphere unless you pay [1] for
      each +1/+1 counter on it.
      
      When Phantasmal Sphere leaves the battlefield, put a blue Orb
      creature token with flying onto the battlefield under target
      opponent's control. That creature's power and toughness are each
      equal to the number of +1/+1 counters on Phantasmal Sphere.
    """
    power: 0
    toughness: 1
    versions:
      3113:
        expansion: 'Alliances'
        rarity: 'Rare'
