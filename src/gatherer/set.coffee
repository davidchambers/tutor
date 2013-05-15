gatherer    = require '../gatherer'
load        = require '../load'
supertypes  = require '../supertypes'


module.exports = (name, callback) ->
  url = gatherer.url('/Pages/Search/Default.aspx',
                     output: 'spoiler', special: true, set: "[\"#{name}\"]")
  gatherer.request url, (err, body) ->
    return callback err if err?
    try set = extract body, name catch err then return callback err
    callback null, set
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
        card.converted_mana_cost = to_converted_mana_cost card.mana_cost = val
          .replace(/[^(/)](?![/)])/g, '($&)') # 1(G/W)(G/W) -> (1)(G/W)(G/W)
          .replace(/[(]/g, '{')
          .replace(/[)]/g, '}')
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
