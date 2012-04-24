{_} = require 'underscore'

__ = (text) -> text.replace(/([^\n])\n(?!\n)/g, '$1 ')

exports.recall =
  params: ['1496', null]
  response:
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
    rulings: [
      ['2009-10-01', __ """
        You don't discard cards until Recall resolves. If you don't have
        X cards in your hand at that time, you discard all the cards in
        your hand.
      """]
      ['2009-10-01', __ """
        You don't choose which cards in your graveyard you'll return to
        your hand until after you discard cards. You choose a card in
        your graveyard for each card you discarded, then you put all
        cards chosen this way into your hand at the same time. You may
        choose to return some or all of the cards you just discarded.
      """]
    ]

exports.constable =
  params: ['2960', null]
  response:
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
    rulings: []

exports.ice =
  params:  ['27166', 'Ice']
  response:
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
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?part=Ice&multiverseid=27166'
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
    rulings: []

exports.fire =
  params: ['27166', 'Fire']
  response:
    name: 'Fire'
    mana_cost: '[1][R]'
    converted_mana_cost: 2
    type: 'Instant'
    text: __ """
      Fire deals 2 damage divided as you choose among one or two target
      creatures and/or players.
    """
    versions:
      '27165':
        expansion: 'Apocalypse'
        rarity: 'Uncommon'
      '27166':
        expansion: 'Apocalypse'
        rarity: 'Uncommon'
      '247159':
        expansion: 'Magic: The Gathering-Commander'
        rarity: 'Uncommon'
    rulings: []
    expansion: 'Apocalypse'
    rarity: 'Uncommon'
    number: 128
    artist: 'Franz Vohwinkel'
    gatherer_url: 'http://gatherer.wizards.com/Pages/Card/Details.aspx?part=Fire&multiverseid=27166'

exports.ancestral_vision =
  params: ['113505', null]
  response:
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
    rulings: [
      ['2006-10-15', __ """
        This has no mana cost, which means it can't normally be cast as
        a spell. You could, however, cast it via some alternate means,
        like with Fist of Suns or Mind’s Desire.
      """]
      ['2006-10-15', __ """
        This has no mana cost, which means it can't be cast with the
        Replicate ability of Djinn Illuminatus or by somehow giving it
        Flashback.
      """]
    ]

exports.diamond_faerie =
  params: ['121138', null]
  response:
    name: 'Diamond Faerie'
    mana_cost: '[2][G][W][U]'
    converted_mana_cost: 5
    type: 'Snow Creature'
    subtype: 'Faerie'
    text: __ """
      Flying

      [1][S]: Snow creatures you control get +1/+1 until end of turn.
      ([S] can be paid with one mana from a snow permanent.)
    """
    flavor_text: __ """
      That such delicate creatures could become so powerful in the
      embrace of winter is yet more proof that I am right.
    """
    flavor_text_attribution: 'Heidar, Rimewind master'
    power: 3
    toughness: 3
    expansion: 'Coldsnap'
    rarity: 'Rare'
    number: 128
    artist: 'Heather Hudson'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=121138'
    versions:
      121138:
        expansion: 'Coldsnap'
        rarity: 'Rare'
    rulings: []

exports.ajani =
  params: ['140233', null]
  response:
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
    rulings: [
      ['2007-10-01', __ """
        The vigilance granted to a creature by the second ability
        remains until the end of the turn even if the +1/+1 counter
        is removed.
      """]
      ['2007-10-01', __ """
        The power and toughness of the Avatar created by the third
        ability will change as your life total changes.
      """]
    ]

exports.flame_javelin =
  params: ['146017', null]
  response:
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
    rulings: [
      ['2008-05-01', __ """
        If an effect reduces the cost to cast a spell by an
        amount of generic mana, it applies to a monocolored
        hybrid spell only if you've chosen a method of paying
        for it that includes generic mana.
      """]
      ['2008-05-01', __ """
        A card with a monocolored hybrid mana symbol in its mana
        cost is each of the colors that appears in its mana cost,
        regardless of what mana was spent to cast it. Thus, Flame
        Javelin is red even if you spend six green mana to cast it.
      """]
      ['2008-05-01', __ """
        A card with monocolored hybrid mana symbols in its
        mana cost has a converted mana cost equal to the highest
        possible cost it could be cast for. Its converted mana
        cost never changes. Thus, Flame Javelin has a converted
        mana cost of 6, even if you spend [R][R][R] to cast it.
      """]
      ['2008-05-01', __ """
        If a cost includes more than one monocolored hybrid
        mana symbol, you can choose a different way to pay for
        each symbol. For example, you can pay for Flame Javelin
        by spending [R][R][R], [2][R][R], [4][R], or [6].
      """]
    ]

exports.colossus =
  params: ['191312', null]
  response:
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
    rulings: [
      ['2009-10-01', __ """
        Lethal damage, damage from a source with deathtouch, and effects
        that say "destroy" won't cause an indestructible creature to be
        put into the graveyard. However, an indestructible creature can
        be put into the graveyard for a number of reasons. The most
        likely reasons are if it's sacrificed or if its toughness is 0
        or less. (In these cases, of course, Darksteel Colossus would
        be shuffled into its owner's library instead of being put into
        its owner's graveyard.)
      """]
    ]

exports.skirge =
  params: ['217984', null]
  response:
    name: 'Vault Skirge'
    mana_cost: '[1][B/P]'
    converted_mana_cost: 2
    type: 'Artifact Creature'
    subtype: 'Imp'
    text: __ """
      ([B/P] can be paid with either [B] or 2 life.)

      Flying

      Lifelink (Damage dealt by this creature also causes you to gain
      that much life.)
    """
    flavor_text: __ """
      From the remnants of the dead, Geth forged a swarm to safeguard
      his throne.
    """
    watermark: 'Phyrexian'
    power: 1
    toughness: 1
    expansion: 'New Phyrexia'
    rarity: 'Common'
    number: 76
    artist: 'Brad Rigney'
    gatherer_url:
      'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=217984'
    versions:
      217984:
        expansion: 'New Phyrexia'
        rarity: 'Common'
    rulings: [
      ['2011-06-01', __ """
        A card with Phyrexian mana symbols in its mana cost is each
        color that appears in that mana cost, regardless of how that
        cost may have been paid.
      """]
      ['2011-06-01', __ """
        To calculate the converted mana cost of a card with Phyrexian
        mana symbols in its cost, count each Phyrexian mana symbol as 1.
      """]
      ['2011-06-01', __ """
        As you cast a spell or activate an activated ability with one
        or more Phyrexian mana symbols in its cost, you choose how to
        pay for each Phyrexian mana symbol at the same time you would
        choose modes or choose a value for X.
      """]
      ['2011-06-01', __ """
        If you're at 1 life or less, you can't pay 2 life.
      """]
      ['2011-06-01', __ """
        Phyrexian mana is not a new color. Players can't add Phyrexian
        mana to their mana pools.
      """]
    ]

exports.storm =
  params: {name: 'Æther Storm'}
  response:
    name: 'Æther Storm'
    mana_cost: '[3][U]'
    converted_mana_cost: 4
    type: 'Enchantment'
    text: __ """
      Creature spells can't be cast.

      Pay 4 life: Destroy Æther Storm. It can't be regenerated. Any
      player may activate this ability.
    """
    gatherer_url: 'http://gatherer.wizards.com/Pages/Card/Details.aspx?name=%u00c6ther+Storm'
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
    rulings: [
      ['2004-10-04', __ """
        This does not stop a creature card from being put directly onto
        the battlefield by a spell or ability.
      """]
      ['2008-08-01', __ """
        Affects any spell with the type creature, including those with
        other types such as artifact or enchantment. This includes older
        cards with "summon" on their type line.
      """]
    ]

exports.sphere =
  params: {name: 'Phantasmal Sphere'}
  response:
      name: 'Phantasmal Sphere'
      mana_cost: '[1][U]'
      converted_mana_cost: 2
      type: 'Creature'
      subtype: 'Illusion'
      text: __ """
        Flying

        At the beginning of your upkeep, put a +1/+1 counter on
        Phantasmal Sphere, then sacrifice Phantasmal Sphere unless
        you pay [1] for each +1/+1 counter on it.

        When Phantasmal Sphere leaves the battlefield, put a blue Orb
        creature token with flying onto the battlefield under target
        opponent's control. That creature's power and toughness are each
        equal to the number of +1/+1 counters on Phantasmal Sphere.
      """
      power: 0
      toughness: 1
      gatherer_url: 'http://gatherer.wizards.com/Pages/Card/Details.aspx?name=Phantasmal+Sphere'
      versions:
        3113:
          expansion: 'Alliances'
          rarity: 'Rare'
      rulings: []

exports.arrows =
  params: {name: 'Serrated Arrows'}
  response:
    name: 'Serrated Arrows'
    mana_cost: '[4]'
    converted_mana_cost: 4
    type: 'Artifact'
    text: __ """
      Serrated Arrows enters the battlefield with three arrowhead
      counters on it.

      At the beginning of your upkeep, if there are no arrowhead
      counters on Serrated Arrows, sacrifice it.

      [Tap], Remove an arrowhead counter from Serrated Arrows:
      Put a -1/-1 counter on target creature.
    """
    gatherer_url: 'http://gatherer.wizards.com/Pages/Card/Details.aspx?name=Serrated+Arrows'
    versions:
      2909:
        expansion: 'Homelands'
        rarity: 'Common'
      109730:
        expansion: 'Time Spiral "Timeshifted"'
        rarity: 'Special'
      202280:
        expansion: 'Duel Decks: Garruk vs. Liliana'
        rarity: 'Common'
    rulings: [
      ['2008-08-01', __ """
        The upkeep trigger checks the number of counters at the start
        of upkeep, and only goes on the stack if there are no arrowhead
        counters at that time. It will check again on resolution, and
        will do nothing if you've somehow manage to get a new arrowhead
        counter on the Arrows.
      """]
    ]

exports.akroma =
  response:
    name: "Akroma, Angel of Wrath Avatar"
    converted_mana_cost:0
    type: "Vanguard"
    text: __ """
      Whenever a creature enters the battlefield under your control, it
      gains two abilities chosen at random from flying, first strike, trample,
      haste, protection from black, protection from red, and vigilance.
    """
    hand_modifier: 1
    life_modifier: 7
    versions:
      182290:
        expansion: "Vanguard"
        rarity: "Special"
    rulings: []
    gatherer_url: "http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=182290"
    flavor_text: """"Chuck's Virtual Party" avatar (2003)"""
    expansion: "Vanguard"
    rarity: "Special"
    number: 33
    artist: "UDON"
