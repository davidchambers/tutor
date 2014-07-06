url         = require 'url'

cheerio     = require 'cheerio'
Q           = require 'q'
_           = require 'underscore'

gatherer    = require '../gatherer'
rarities    = require '../rarities'
supertypes  = require '../supertypes'


module.exports = (name, callback) ->
  common_params =
    advanced: 'true'
    set: """["#{name}"]"""
    special: 'true'

  gatherer.request gatherer.url(
    '/Pages/Search/Default.aspx'
    _.extend output: 'checklist', common_params
  ), (err, res) ->
    if err?
      callback err
      return

    $ = cheerio.load res.body
    cards$ = _.map $('.cardItem'), (el) ->
      get = (selector) -> $(el).find(selector).text()

      color_indicator: get '.color'
      name: get '.name'
      rarity: rarities[get '.rarity']

    Q.all _.map _.range(Math.ceil cards$.length / 25), (page) ->
      deferred = Q.defer()
      gatherer.request gatherer.url(
        '/Pages/Search/Default.aspx'
        _.extend output: 'standard', page: "#{page}", common_params
      ), deferred.makeNodeResolver()
      deferred.promise
    .then (xs) ->
      for [res] in xs
        for card_name, versions of extract cheerio.load(res.body), name
          for card, idx in versions
            card$ = (c$ for c$ in cards$ when c$.name is card_name)[idx]
            _.extend card$, card
            card$.expansion = name
            color = card$.color_indicator
            delete card$.color_indicator unless (
              color is 'White' and not /W/.test(card$.mana_cost) or
              color is 'Blue'  and not /U/.test(card$.mana_cost) or
              color is 'Black' and not /B/.test(card$.mana_cost) or
              color is 'Red'   and not /R/.test(card$.mana_cost) or
              color is 'Green' and not /G/.test(card$.mana_cost)
            )
      cards$
    .done _.partial(callback, null), callback
  return

extract_card = ($el, set_name) ->
  $card = $el.closest('.cardItem')
  [param] = /multiverseid=\d+/.exec $el.attr('href')

  card$ =
    text: _.map($card.find('.rulesText').find('p'),
                _.compose gatherer._get_text, cheerio).join('\n\n')
    gatherer_url: "#{gatherer.origin}/Pages/Card/Details.aspx?#{param}"
    image_url: "#{gatherer.origin}/Handlers/Image.ashx?#{param}&type=card"
    versions: _.object _.map $card.find('.setVersions').find('img'), (el) ->
      _.rest /^(.*) [(](.*?)[)]$/.exec cheerio(el).attr('alt')

  name = $card.find('.cardTitle').text().trim()
  name_match = /[(](.*)[)]$/.exec name
  card$.name = if name_match? and set_name not in ['Unglued', 'Unhinged']
    name_match[1]
  else
    name

  mana_cost = gatherer._get_text $card.find('.manaCost')
  card$.mana_cost = mana_cost unless mana_cost is ''
  card$.converted_mana_cost = to_converted_mana_cost mana_cost

  lines = $card.find('.typeLine').text().match(/^.*$/gm).map (s) -> s.trim()
  stats = lines[4].slice(1, -1)  # strip "(" and ")"

  if lines[2] is 'Vanguard'
    [card$.hand_modifier, card$.life_modifier] =
      stats.split('/').map(gatherer._to_stat)
  else
    if /^\d+$/.test stats
      card$.loyalty = +stats
    else if match = /^((?:\{[^}]*\}|[^/])*)[/](.*)$/.exec stats
      [card$.power, card$.toughness] = _.map match[1..2], gatherer._to_stat

    [types, subtypes] = lines[2].split('\u2014').map (s) -> s.trim()
    [card$.supertypes, card$.types] =
      _.partition types.split(' '), _.partial(_.contains, supertypes)
    card$.subtypes = if subtypes? then subtypes.split(' ') else []

  card$

extract = ($, set_name) ->
  _.chain $('.cardItem').find('.setVersions').find('img')
  .map cheerio
  .filter ($el) -> $el.attr('alt').indexOf("#{set_name} (") is 0
  .invoke 'parent'
  .map _.partial extract_card, _, set_name
  .sortBy 'gatherer_url'
  .groupBy 'name'
  .value()

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
