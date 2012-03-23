vows     = require 'vows'
should   = require 'should'
{_}      = require 'underscore'

gatherer = require '../gatherer'

__ = (text) -> text.replace(/([^\n])\n(?!\n)/g, '$1 ')

should_match = (object) ->
  (e, result) ->
    should.exist(result)
    for property, value of object
      result.should.have.property property # can't use have.property to check values, since it uses strict comparison
      if value?
        result[property].should.eql value
      else
        should.not.exist result[property]

gets = (fetch_function) ->
  (object) ->
    context =
      topic: ->
        # The strings need to be wrapped in parentheses before
        # being evaluated, otherwise object literals are
        # interpreted as block literals
        fetch_function(eval("(#{@context.name})"), @callback)
        return
    if object.error?
      context_name = 'should give an error response'
    else
      context_name = 'should give a correct response'
    context[context_name] = should_match(object)
    context

gets_card = gets gatherer.fetch_card

gets_set = gets gatherer.fetch_set

vows.describe('Gatherer API').addBatch(
  'fetch_card':
    '["1A7gaf", null]': gets_card # invalid gatherer id
      error: null
      status: 302
    '{name:"Not A Real Card"}': gets_card # invalid card name
      error: null
      status: 302
    '["1496", null]': gets_card
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
        """]]
    '["2960", null]': gets_card
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
    #### Multipart Cards ####
    #'["27166", null]': gets # Intriguingly, this returns Ice about 80% of the time.
    '["27166", "Ice"]': gets_card
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
      rulings: []
    '["27166", "Fire"]': gets_card
      name: 'Fire'
      mana_cost: '[1][R]'
      converted_mana_cost: 2
      type: 'Instant'
      text: 'Fire deals 2 damage divided as you choose among one or two target creatures and/or players.'
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
      gatherer_url: 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=27166&part=Fire'
    '["113505", null]': gets_card
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
          This has no mana cost, which means it can't normally
          be cast as a spell. You could, however, cast it via some
          alternate means, like with Fist of Suns or Mind’s Desire.
        """]
        ['2006-10-15', __ """
          This has no mana cost, which means it can't be cast with the
          Replicate ability of Djinn Illuminatus or by
          somehow giving it Flashback.
        """]
      ]
    '["121138", null]': gets_card
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
    '["140233", null]': gets_card # Planeswalker
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
    '["146017", null]': gets_card # mono-colored hybrid mana
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
    '["191312", null]': gets_card
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
    '["217984", null]': gets_card # Phryexian Mana
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
    '["220371", null]': gets_card # non-basic land
      name: 'Ghost Quarter'
      converted_mana_cost: 0
      type: 'Land'
      text: __ """
        [Tap]: Add [1] to your mana pool.

        [Tap], Sacrifice Ghost Quarter: Destroy target land. Its
        controller may search his or her library for a basic land card,
        put it onto the battlefield, then shuffle his or her library.
      """
      flavor_text: 'Deserted, but not uninhabited.'
      expansion: 'Innistrad'
      rarity: 'Uncommon'
      number: 240
      artist: 'Peter Mohrbacher'
      gatherer_url:
        'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=220371'
      versions:
        107504:
          expansion: 'Dissension'
          rarity: 'Uncommon'
        220371:
          expansion: 'Innistrad'
          rarity: 'Uncommon'
      rulings: [
        ['2006-05-01', __ """
          The target land's controller gets to search for a basic land
          card even if that land wasn't destroyed by Ghost Quarter's
          ability. This may happen because the land is indestructible
          or because it was regenerated.
        """]
        ['2006-05-01', __ """
          If you target Ghost Quarter with its own ability, the ability
          will be countered because its target is no longer on the
          battlefield. You won't get to search for a land card.
        """]
        ['2011-09-22', __ """
          If the targeted land is an illegal target by the time Ghost
          Quarter's ability resolves, it will be countered and none of
          its effects will happen. The land's controller won't get to
          search for a basic land card.
        """]
      ]
    "{name: 'Æther Storm'}": gets_card # by name
      name: 'Æther Storm'
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
    "{name: 'Phantasmal Sphere'}": gets_card
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
      rulings: []
    "{name: 'Serrated Arrows'}": gets_card
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
        """]]
).addBatch(
  'fetch_set':
    '{name: "Homelands", page: 0}': gets_set
      error: 'Not Found'
      status: 404
    '{name: "Homelands", page: 6}': gets_set # page out of bounds
      error: 'Not Found'
      status: 404
    '{name: "Foo", page: undefined}': gets_set # invalid name
      error: 'Not Found'
      status: 404
    '{name: "Homelands", page: undefined}': gets_set # no page specified
      page: 1
      pages: 5
      cards: [
        name: 'Abbey Gargoyles'
        mana_cost: '[2][W][W][W]'
        converted_mana_cost: 5
        type: 'Creature'
        subtype: 'Gargoyle'
        power: 3
        toughness: 4
        text: 'Flying, protection from red'
        expansion: 'Homelands'
        rarity: 'Uncommon'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3010'
        versions:
          3010:
            expansion: 'Homelands'
            rarity: 'Uncommon'
          4098:
            expansion: 'Fifth Edition'
            rarity: 'Uncommon'
          184585:
            expansion: 'Masters Edition II'
            rarity: 'Uncommon'
      ,
        name: 'Abbey Matron'
        mana_cost: '[2][W]'
        converted_mana_cost: 3
        type: 'Creature'
        subtype: 'Human Cleric'
        power: 1
        toughness: 3
        text: '[W],[Tap]: Abbey Matron gets +0/+3 until end of turn.'
        expansion: 'Homelands'
        rarity: 'Common'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3012'
        versions:
          3011:
            expansion: 'Homelands'
            rarity: 'Common'
          3012:
            expansion: 'Homelands'
            rarity: 'Common'
      ,
        name: 'Æther Storm'
        mana_cost: '[3][U]'
        converted_mana_cost: 4
        type: 'Enchantment'
        text: __ """
          Creature spells can't be cast.

          Pay 4 life: Destroy Æther Storm. It can't be regenerated.
          Any player may activate this ability.
        """
        expansion: 'Homelands'
        rarity: 'Uncommon'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2935'
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
      ,
        name: "Aliban's Tower"
        mana_cost: '[1][R]'
        converted_mana_cost: 2
        type: 'Instant'
        text: 'Target blocking creature gets +3/+1 until end of turn.'
        expansion: 'Homelands'
        rarity: 'Common'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2986'
        versions:
          2985:
            expansion: 'Homelands'
            rarity: 'Common'
          2986:
            expansion: 'Homelands'
            rarity: 'Common'
      ,
        name: 'Ambush'
        mana_cost: '[3][R]'
        converted_mana_cost: 4
        type: 'Instant'
        text: 'Blocking creatures gain first strike until end of turn.'
        expansion: 'Homelands'
        rarity: 'Common'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2987'
        versions:
          2987:
            expansion: 'Homelands'
            rarity: 'Common'
      ,
        name: 'Ambush Party'
        mana_cost: '[4][R]'
        converted_mana_cost: 5
        type: 'Creature'
        subtype: 'Human Rogue'
        power: 3
        toughness: 1
        text: 'First strike, haste'
        expansion: 'Homelands'
        rarity: 'Common'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2989'
        versions:
          2988:
            expansion: 'Homelands'
            rarity: 'Common'
          2989:
            expansion: 'Homelands'
            rarity: 'Common'
          4029:
            expansion: 'Fifth Edition'
            rarity: 'Common'
          184543:
            expansion: 'Masters Edition II'
            rarity: 'Common'
      ,
        name: 'Anaba Ancestor'
        mana_cost: '[1][R]'
        converted_mana_cost: 2
        type: 'Creature'
        subtype: 'Minotaur Spirit'
        power: 1
        toughness: 1
        text: __ """
          [Tap]: Another target Minotaur creature gets +1/+1 until
          end of turn.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2991'
        versions:
          2991:
            expansion: 'Homelands'
            rarity: 'Rare'
          201315:
            expansion: 'Masters Edition III'
            rarity: 'Common'
      ,
        name: 'Anaba Bodyguard'
        mana_cost: '[3][R]'
        converted_mana_cost: 4
        type: 'Creature'
        subtype: 'Minotaur'
        power: 2
        toughness: 3
        text: __ """
          First strike (This creature deals combat damage before
          creatures without first strike.)
        """
        expansion: 'Homelands'
        rarity: 'Common'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2993'
        versions:
          2992:
            expansion: 'Homelands'
            rarity: 'Common'
          2993:
            expansion: 'Homelands'
            rarity: 'Common'
          16444:
            expansion: 'Classic Sixth Edition'
            rarity: 'Common'
          134753:
            expansion: 'Tenth Edition'
            rarity: 'Common'
      ,
        name: 'Anaba Shaman'
        mana_cost: '[3][R]'
        converted_mana_cost: 4
        type: 'Creature'
        subtype: 'Minotaur Shaman'
        power: 2
        toughness: 2
        text: __ """
          [R],[Tap]: Anaba Shaman deals 1 damage to target creature
          or player.
        """
        expansion: 'Homelands'
        rarity: 'Common'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2995'
        versions:
          2994:
            expansion: 'Homelands'
            rarity: 'Common'
          2995:
            expansion: 'Homelands'
            rarity: 'Common'
          16441:
            expansion: 'Classic Sixth Edition'
            rarity: 'Common'
          45364:
            expansion: 'Eighth Edition'
            rarity: 'Common'
          82991:
            expansion: 'Ninth Edition'
            rarity: 'Common'
      ,
        name: 'Anaba Spirit Crafter'
        mana_cost: '[2][R][R]'
        converted_mana_cost: 4
        type: 'Creature'
        subtype: 'Minotaur Shaman'
        power: 1
        toughness: 3
        text: 'Minotaur creatures get +1/+0.'
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2996'
        versions:
          2996:
            expansion: 'Homelands'
            rarity: 'Rare'
          201316:
            expansion: 'Masters Edition III'
            rarity: 'Common'
      ,
        name: 'An-Havva Constable'
        mana_cost: '[1][G][G]'
        converted_mana_cost: 3
        type: 'Creature'
        subtype: 'Human'
        power: 2
        toughness: '1+*'
        text: __ """
          An-Havva Constable's toughness is equal to 1 plus the
          number of green creatures on the battlefield.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2960'
        versions:
          2960:
            expansion: 'Homelands'
            rarity: 'Rare'
          3960:
            expansion: 'Fifth Edition'
            rarity: 'Rare'
      ,
        name: 'An-Havva Inn'
        mana_cost: '[1][G][G]'
        converted_mana_cost: 3
        type: 'Sorcery'
        text: __ """
          You gain X plus 1 life, where X is the number of green
          creatures on the battlefield.
        """
        expansion: 'Homelands'
        rarity: 'Uncommon'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2961'
        versions:
          2961:
            expansion: 'Homelands'
            rarity: 'Uncommon'
      ,
        name: 'An-Havva Township'
        converted_mana_cost: 0
        type: 'Land'
        text: __ """
          [Tap]: Add [1] to your mana pool.

          [1],[Tap]: Add [G] to your mana pool.

          [2],[Tap]: Add [R] or [W] to your mana pool.
        """
        expansion: 'Homelands'
        rarity: 'Uncommon'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3035'
        versions:
          3035:
            expansion: 'Homelands'
            rarity: 'Uncommon'
      ,
        name: 'An-Zerrin Ruins'
        mana_cost: '[2][R][R]'
        converted_mana_cost: 4
        type: 'Enchantment'
        text: __ """
          As An-Zerrin Ruins enters the battlefield, choose a
          creature type.

          Creatures of the chosen type don't untap during their
          controllers' untap steps.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2990'
        versions:
          2990:
            expansion: 'Homelands'
            rarity: 'Rare'
          184586:
            expansion: 'Masters Edition II'
            rarity: 'Rare'
      ,
        name: 'Apocalypse Chime'
        mana_cost: '[2]'
        converted_mana_cost: 2
        type: 'Artifact'
        text: __ """
          [2],[Tap], Sacrifice Apocalypse Chime: Destroy all
          nontoken permanents from the Homelands expansion.
          They can't be regenerated.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2900'
        versions:
          2900:
            expansion: 'Homelands'
            rarity: 'Rare'
      ,
        name: 'Autumn Willow'
        mana_cost: '[4][G][G]'
        converted_mana_cost: 6
        type: 'Legendary Creature'
        subtype: 'Avatar'
        power: 4
        toughness: 4
        text: __ """
          Shroud

          [G]: Until end of turn, Autumn Willow can be the target
          of spells and abilities controlled by target player as
          though it didn't have shroud.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2962'
        versions:
          2962:
            expansion: 'Homelands'
            rarity: 'Rare'
          159205:
            expansion: 'Masters Edition'
            rarity: 'Rare'
      ,
        name: 'Aysen Abbey'
        converted_mana_cost: 0
        type: 'Land'
        text: __ """
          [Tap]: Add [1] to your mana pool.

          [1],[Tap]: Add [W] to your mana pool.

          [2],[Tap]: Add [G] or [U] to your mana pool.
        """
        expansion: 'Homelands'
        rarity: 'Uncommon'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3036'
        versions:
          3036:
            expansion: 'Homelands'
            rarity: 'Uncommon'
      ,
        name: 'Aysen Bureaucrats'
        mana_cost: '[1][W]'
        converted_mana_cost: 2
        type: 'Creature'
        subtype: 'Human Advisor'
        power: 1
        toughness: 1
        text: '[Tap]: Tap target creature with power 2 or less.'
        expansion: 'Homelands'
        rarity: 'Common'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3014'
        versions:
          3013:
            expansion: 'Homelands'
            rarity: 'Common'
          3014:
            expansion: 'Homelands'
            rarity: 'Common'
          4106:
            expansion: 'Fifth Edition'
            rarity: 'Common'
          184490:
            expansion: 'Masters Edition II'
            rarity: 'Common'
      ,
        name: 'Aysen Crusader'
        mana_cost: '[2][W][W]'
        converted_mana_cost: 4
        type: 'Creature'
        subtype: 'Human Knight'
        power: '2+*'
        toughness: '2+*'
        text: __ """
          Aysen Crusader's power and toughness are each equal to
          2 plus the number of Soldiers and Warriors you control.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3015'
        versions:
          3015:
            expansion: 'Homelands'
            rarity: 'Rare'
          184587:
            expansion: 'Masters Edition II'
            rarity: 'Uncommon'
      ,
        name: 'Aysen Highway'
        mana_cost: '[3][W][W][W]'
        converted_mana_cost: 6
        type: 'Enchantment'
        text: 'White creatures have plainswalk.'
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3016'
        versions:
          3016:
            expansion: 'Homelands'
            rarity: 'Rare'
      ,
        name: "Baki's Curse"
        mana_cost: '[2][U][U]'
        converted_mana_cost: 4
        type: 'Sorcery'
        text: __ """
          Baki's Curse deals 2 damage to each creature for each
          Aura attached to that creature.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2936'
        versions:
          2936:
            expansion: 'Homelands'
            rarity: 'Rare'
      ,
        name: 'Baron Sengir'
        mana_cost: '[5][B][B][B]'
        converted_mana_cost: 8
        type: 'Legendary Creature'
        subtype: 'Vampire'
        power: 5
        toughness: 5
        text: __ """
          Flying

          Whenever a creature dealt damage by Baron Sengir this
          turn dies, put a +2/+2 counter on Baron Sengir.

          [Tap]: Regenerate another target Vampire.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2910'
        versions:
          2910:
            expansion: 'Homelands'
            rarity: 'Rare'
          159208:
            expansion: 'Masters Edition'
            rarity: 'Rare'
      ,
        name: 'Beast Walkers'
        mana_cost: '[1][W][W]'
        converted_mana_cost: 3
        type: 'Creature'
        subtype: 'Human Beast Soldier'
        power: 2
        toughness: 2
        text: __ """
          [G]: Beast Walkers gains banding until end of turn.
          (Any creatures with banding, and up to one without,
          can attack in a band. Bands are blocked as a group.
          If any creatures with banding you control are
          blocking or being blocked by a creature, you divide
          that creature's combat damage, not its controller,
          among any of the creatures it's being blocked by or
          is blocking.)
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=3017'
        versions:
          3017:
            expansion: 'Homelands'
            rarity: 'Rare'
      ,
        name: 'Black Carriage'
        mana_cost: '[3][B][B]'
        converted_mana_cost: 5
        type: 'Creature'
        subtype: 'Horse'
        power: 4
        toughness: 4
        text: __ """
          Trample

          Black Carriage doesn't untap during your untap step.

          Sacrifice a creature: Untap Black Carriage. Activate
          this ability only during your upkeep.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2911'
        versions:
          2911:
            expansion: 'Homelands'
            rarity: 'Rare'
      ,
        name: 'Broken Visage'
        mana_cost: '[4][B]'
        converted_mana_cost: 5
        type: 'Instant'
        text: __ """
          Destroy target nonartifact attacking creature. It can't
          be regenerated. Put a black Spirit creature token with
          that creature's power and toughness onto the battlefield.
          Sacrifice the token at the beginning of the next end step.
        """
        expansion: 'Homelands'
        rarity: 'Rare'
        gatherer_url:
          'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2912'
        versions:
          2912:
            expansion: 'Homelands'
            rarity: 'Rare'
          3832:
            expansion: 'Fifth Edition'
            rarity: 'Rare'
          184589:
            expansion: 'Masters Edition II'
            rarity: 'Uncommon'
      ]
).export module