{_} = require 'underscore'

__ = (text) -> text.replace(/([^\n])\n(?!\n)/g, '$1 ')

exports.homelands_pg1 =
  params:
    name: 'Homelands'
    page: undefined
  response:
    page: 1
    pages: 5
    cards: [
      name: 'Abbey Gargoyles'
      mana_cost: '[2][W][W][W]'
      converted_mana_cost: 5
      types: ['Creature']
      subtypes: ['Gargoyle']
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
      types: ['Creature']
      subtypes: ['Human', 'Cleric']
      power: 1
      toughness: 3
      text: '[W], [Tap]: Abbey Matron gets +0/+3 until end of turn.'
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
      types: ['Enchantment']
      subtypes: []
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
      types: ['Instant']
      subtypes: []
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
      types: ['Instant']
      subtypes: []
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
      types: ['Creature']
      subtypes: ['Human', 'Rogue']
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
      types: ['Creature']
      subtypes: ['Minotaur', 'Spirit']
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
      types: ['Creature']
      subtypes: ['Minotaur']
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
      types: ['Creature']
      subtypes: ['Minotaur', 'Shaman']
      power: 2
      toughness: 2
      text: __ """
        [R], [Tap]: Anaba Shaman deals 1 damage to target creature
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
      types: ['Creature']
      subtypes: ['Minotaur', 'Shaman']
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
      types: ['Creature']
      subtypes: ['Human']
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
      types: ['Sorcery']
      subtypes: []
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
      types: ['Land']
      subtypes: []
      text: __ """
        [Tap]: Add [1] to your mana pool.

        [1], [Tap]: Add [G] to your mana pool.

        [2], [Tap]: Add [R] or [W] to your mana pool.
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
      types: ['Enchantment']
      subtypes: []
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
      types: ['Artifact']
      subtypes: []
      text: __ """
        [2], [Tap], Sacrifice Apocalypse Chime: Destroy all
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
      types: ['Legendary', 'Creature']
      subtypes: ['Avatar']
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
      types: ['Land']
      subtypes: []
      text: __ """
        [Tap]: Add [1] to your mana pool.

        [1], [Tap]: Add [W] to your mana pool.

        [2], [Tap]: Add [G] or [U] to your mana pool.
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
      types: ['Creature']
      subtypes: ['Human', 'Advisor']
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
      types: ['Creature']
      subtypes: ['Human', 'Knight']
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
      types: ['Enchantment']
      subtypes: []
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
      types: ['Sorcery']
      subtypes: []
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
      types: ['Legendary', 'Creature']
      subtypes: ['Vampire']
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
      types: ['Creature']
      subtypes: ['Human', 'Beast', 'Soldier']
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
      types: ['Creature']
      subtypes: ['Horse']
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
      types: ['Instant']
      subtypes: []
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
