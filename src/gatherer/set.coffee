url         = require 'url'

Q           = require 'q'

gatherer    = require '../gatherer'
load        = require '../load'
supertypes  = require '../supertypes'


module.exports = (name, callback) ->

  d1 = Q.defer()
  gatherer.request gatherer.url('/Pages/Search/Default.aspx',
    action: 'advanced'
    output: 'spoiler'
    special: true
    set: "[\"#{name}\"]"
  ), d1.makeNodeResolver()

  d2 = Q.defer()
  gatherer.request gatherer.url('/Pages/Search/Default.aspx',
    set: "[\"#{name}\"]"
    type: '+["Basic"]+["Land"]'
  ), d2.makeNodeResolver()

  Q.all([d1.promise, d2.promise])
  .then(([body1, body2]) ->
    basics = {}

    # > pattern.exec "Arabian Nights (Common)"
    # ["Arabian Nights", "Arabian Nights"]
    # > pattern.exec "Premium Deck Series: Fire and Lightning (Land)"
    # ["Premium Deck Series: Fire and Lightning", "Fire and Lightning"]
    pattern = /^(?:[^:]+: )?(.+)(?= [(]\w+[)]$)/
    ids = ($container) ->
      set = {}
      $container.find('img').each ->
        if (match = pattern.exec @attr('alt'))? and name in match
          set[url.parse(@parent().attr('href'), yes).query.multiverseid] = 1
      (+id for id of set)

    # For sets with exactly one basic land, the "basic lands" search
    # request is redirected. This is explained in more detail in #69.
    $ = load body2
    if ($items = $('.cardItem')).length then $items.each ->
      basics[@find('.cardTitle').text().trim()] = ids @find('.setVersions')
    else
      basics[$('.contentTitle').text().trim()] = ids $('.cardDetails')

    # Loop through the set's cards in reverse order. Each time a basic
    # land is encountered, remove it from the array and insert all the
    # set's versions of the card, sorted by Gatherer id, in its place.
    set = extract body1, name
    idx = set.length
    while idx--
      card = set[idx]
      if card.name of basics
        match = /multiverseid=(\d+)/.exec card.gatherer_url
        clones = for id in basics[card.name]
          clone = {}
          clone[key] = value for key, value of card
          clone.gatherer_url = card.gatherer_url.replace match[1], id
          clone.image_url = card.image_url.replace match[1], id
          clone
        clones.sort (a, b) ->
          if a.gatherer_url < b.gatherer_url then -1 else 1
        set[idx..idx] = clones
    callback null, set
  )
  .catch(callback)

  return

extract = (html, name) ->

  $ = load html
  t = (el) -> gatherer._get_text $ el

  cards = []
  card = null

  $('.textspoiler').find('tr').each ->
    [first, second] = @children()
    key = t first
    val = t second
    return unless val
    switch key
      when 'Name'
        cards.push card unless card is null
        [param] = /multiverseid=\d+/.exec $(second).find('a').attr('href')
        card =
          name: val
          converted_mana_cost: 0
          supertypes: []
          types: []
          subtypes: []
          expansion: name
          gatherer_url: "#{gatherer.origin}/Pages/Card/Details.aspx?#{param}"
          image_url: "#{gatherer.origin}/Handlers/Image.ashx?#{param}&type=card"
      when 'Cost:'
        # 1(G/W)(G/W) -> {1}{G/W}{G/W} | 11 -> {11}
        card.mana_cost = "{#{val.match(/// ./. | \d+ | [^()] ///g).join('}{')}}"
        card.converted_mana_cost = to_converted_mana_cost card.mana_cost
      when 'Type:'
        [types, subtypes] = /^([^\u2014]+?)(?:\s+\u2014\s+(.+))?$/.exec(val)[1..]
        for type in types.split(/\s+/)
          card[if type in supertypes then 'supertypes' else 'types'].push type
        if subtypes
          card.subtypes = subtypes.split(/\s+/)
      when 'Rules Text:'
        # Though "{" precedes each of consecutive hybrid mana symbols
        # in rules text, only the last is followed by "}". For example:
        #
        #   {(r/w){(r/w){(r/w)}
        card.text = val
          .replace(/\n/g, '\n\n')
          .replace(/(?:[{][(][2WUBRG][/][WUBRG][)])+[}]/gi, (match) -> match
            .replace(/[{][(]/g, '{')
            .replace(/[)][}]?/g, '}')
            .toUpperCase())
      when 'Color:'
        card.color_indicator = val
      when 'Pow/Tgh:'
        pattern = ///^
          [(]
          ([^/]*(?:[{][^}]+[}])?) # power
          /
          ([^/]*(?:[{][^}]+[}])?) # toughness
          [)]
        $///
        [power, toughness] = pattern.exec(val)[1..]
        card.power = gatherer._to_stat power
        card.toughness = gatherer._to_stat toughness
      when 'Loyalty:'
        card.loyalty = +/\d+/.exec(val)[0]
      when 'Hand/Life:'
        card.hand_modifier = +/Hand Modifier: ([-+]\d+)/.exec(val)[1]
        card.life_modifier = +/Life Modifier: ([-+]\d+)/.exec(val)[1]
      when 'Set/Rarity:'
        card.versions = {}
        for version in val.split(/,\s*/)
          words = version.split(/\s+/)
          rarity = words.pop()
          if rarity is 'Rare' and words[words.length - 1] is 'Mythic'
            rarity = 'Mythic Rare'
            words.pop()
          card.versions[words.join(' ')] = rarity
        card.rarity = card.versions[name]

  cards.push card
  cards


converted_mana_costs =
  '{X}': 0, '{4}': 4, '{10}': 10, '{16}': 16, '{2/W}': 2,
  '{Y}': 0, '{5}': 5, '{11}': 11, '{17}': 17, '{2/U}': 2,
  '{Z}': 0, '{6}': 6, '{12}': 12, '{18}': 18, '{2/B}': 2,
  '{0}': 0, '{7}': 7, '{13}': 13, '{19}': 19, '{2/R}': 2,
  '{2}': 2, '{8}': 8, '{14}': 14, '{20}': 20, '{2/G}': 2,
  '{3}': 3, '{9}': 9, '{15}': 15,

to_converted_mana_cost = (mana_cost) ->
  cmc = 0
  for symbol in mana_cost.split(/(?=[{])/)
    cmc += converted_mana_costs[symbol] ? 1
  cmc
