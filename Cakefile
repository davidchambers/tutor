{exec}  = require 'child_process'

request = require 'request'


_ = (text) -> text.replace(/([^\n])\n(?!\n)/g, '$1 ')

task 'build', 'generate mtg-api.js', ->
  exec _ """
    echo "require('http-proxy').createServer(3000, 'localhost').listen(80)"
    | cat - mtg-api.coffee | coffee --compile --stdio > mtg-api.js"""

option null, '--url [URL]', 'select the URL against which to run the tests'

task 'test', 'run the mtg-api test suite', ({url}) ->
  url = (url or 'http://localhost:3000/').replace /// /?$ ///, '/card/'

  count = remaining = Object.keys(tests).length
  failures = []

  run = (id, expected) ->
    request url + id, (error, response, body) ->
      data = JSON.parse body
      for prop in properties
        if data[prop] isnt expected[prop]
          console.log _ """
            \033[0;31m[fail]\033[0m tests[#{id}].#{prop}:
            expected (#{expected[prop]}) not (#{data[prop]})"""
          failures.push id
          break
      unless remaining -= 1
        if failures.length
          console.log "\n#{count - failures.length}/#{count} tests passed"
        else
          console.log "\n\033[0;32m#{count}/#{count} tests passed\033[0m"

  run id, test for id, test of tests

properties = [
  'name'
  'mana_cost'
  'converted_mana_cost'
  'type'
  'subtype'
  'text'
  'flavor_text'
  'flavor_text_attribution'
  'color_indicator'
  'power'
  'toughness'
  'loyalty'
  'expansion'
  'rarity'
  'number'
  'artist'
  'gatherer_url'
]

tests =

  3:
    name: 'Black Lotus'
    mana_cost: '[0]'
    converted_mana_cost: 0
    type: 'Artifact'
    text: _ """
      [Tap], Sacrifice Black Lotus: Add three mana of any one color to
      your mana pool."""
    expansion: 'Limited Edition Alpha'
    rarity: 'Rare'
    artist: 'Christopher Rush'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3'

  1783:
    name: 'Ball Lightning'
    mana_cost: '[R][R][R]'
    converted_mana_cost: 3
    type: 'Creature'
    subtype: 'Elemental'
    text: _ """
      Trample (If this creature would assign enough damage to its
      blockers to destroy them, you may have it assign the rest of
      its damage to defending player or planeswalker.)
      
      Haste (This creature can attack and [Tap] as soon as it comes
      under your control.)
      
      At the beginning of the end step, sacrifice Ball Lightning.
      """
    power: 6
    toughness: 1
    expansion: 'The Dark'
    rarity: 'Rare'
    artist: 'Quinton Hoover'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=1783'

  2960:
    name: 'An-Havva Constable'
    mana_cost: '[1][G][G]'
    converted_mana_cost: 3
    type: 'Creature'
    subtype: 'Human'
    text: _ """
      An-Havva Constable's toughness is equal to 1 plus the number of
      green creatures on the battlefield."""
    flavor_text: _ """
      Joskun and the other Constables serve with passion, if not with
      grace."""
    flavor_text_attribution: 'Devin, Faerie Noble'
    power: 2
    toughness: '1+*'
    expansion: 'Homelands'
    rarity: 'Rare'
    artist: 'Dan Frazier'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2960'

  113505:
    name: 'Ancestral Vision'
    converted_mana_cost: 0
    type: 'Sorcery'
    text: _ """
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

  140233:
    name: 'Ajani Goldmane'
    mana_cost: '[2][W][W]'
    converted_mana_cost: 4
    type: 'Planeswalker'
    subtype: 'Ajani'
    text: _ """
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

  146017:
    name: 'Flame Javelin'
    mana_cost: '[2/R][2/R][2/R]'
    converted_mana_cost: 6
    type: 'Instant'
    text: _ """
      ([2/R] can be paid with any two mana or with [R]. This card's
      converted mana cost is 6.)
      
      Flame Javelin deals 4 damage to target creature or player."""
    flavor_text: _ """
      Gyara Spearhurler would have been renowned for her deadly
      accuracy, if it weren't for her deadly accuracy."""
    expansion: 'Shadowmoor'
    rarity: 'Uncommon'
    number: 92
    artist: 'Trevor Hairsine'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=146017'

  191312:
    name: 'Darksteel Colossus'
    mana_cost: '[11]'
    converted_mana_cost: 11
    type: 'Artifact Creature'
    subtype: 'Golem'
    text: _ """
      Trample
      
      Darksteel Colossus is indestructible.
      
      If Darksteel Colossus would be put into a graveyard from anywhere,
      reveal Darksteel Colossus and shuffle it into its owner's library
      instead."""
    power: 11
    toughness: 11
    expansion: 'Magic 2010'
    rarity: 'Mythic Rare'
    number: 208
    artist: 'Carl Critchlow'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=191312'
