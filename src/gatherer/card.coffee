cheerio     = require 'cheerio'
_           = require 'underscore'

gatherer    = require '../gatherer'
supertypes  = require '../supertypes'


module.exports = (details, callback) ->
  if 'which' of details and details.which not in ['a', 'b']
    callback new Error 'invalid which property (valid values are "a" and "b")'

  gatherer.request gatherer.card.url('Details.aspx', details), (err, res, body) ->
    if err?
      callback err
    else
      $ = cheerio.load body
      if $('title').text().trim().indexOf('Card Search - Search:') is 0
        callback new Error 'no results'
      else
        callback null, extract $, details
    return
  return

extract = ($, details) ->
  verbose = 'id' of details

  t = (el) -> gatherer._get_text $(el)
  t1 = (el) -> gatherer._get_text $(el).next()

  card =
    converted_mana_cost: 0
    supertypes: []
    types: []
    subtypes: []
    rulings: _.map $('.discussion').find('tr.post'), (el) ->
      [date, ruling] = $(el).children()
      [m, d, y] = $(date).text().trim().split('/')
      pad = (s) -> "0#{s}".substr(-2)
      ["#{y}-#{pad m}-#{pad d}", $(ruling).text().trim().replace(/[ ]{2,}/g, ' ')]

  set = gatherer._set.bind null, card

  get_versions = _.compose gatherer._get_versions, (el) ->
    $(el)
    .find '.label'
    .filter (idx, el) -> $(el).text().trim() is 'Expansion:'
    .next()
    .find 'img'

  # Delete the irrelevant column.
  $(do ->
    [left, right] = $('.cardComponentContainer')
    if details.which is 'b'
      left
    # Double-faced cards.
    else if verbose and (details.id of get_versions(right) and
                         details.id not of get_versions(left))
      left
    else if details.name?.toLowerCase() is $(right)
        .find '.label'
        .filter (idx, el) -> $(el).text().trim() is 'Card Name:'
        .next()
        .text()
        .trim()
        .toLowerCase()
      left
    else
      right
  ).remove()

  $('.label').each ->
    $el = $ this

    switch $el.text().trim()

      when 'Card Name:'
        set 'name', $el.next().text().trim()

      when 'Mana Cost:'
        set 'mana_cost', gatherer._get_text $el.next()

      when 'Converted Mana Cost:'
        set 'converted_mana_cost', +t1 $el

      when 'Types:'
        [..., types, subtypes] = /^(.+?)(?:\s+\u2014\s+(.+))?$/.exec t1 $el
        for type in types.split(/\s+/)
          card[if type in supertypes then 'supertypes' else 'types'].push type
        set 'subtypes', subtypes?.split(/\s+/)

      when 'Card Text:'
        set 'text', gatherer._get_rules_text $el.next(), t

      when 'Flavor Text:'
        break unless verbose
        $flavor = $el.next()
        $el = $flavor.children().last()
        match = /^(\u2014|\u2015\u2015|\uFF5E)\s*(.+)$/.exec $el.text().trim()
        if match?
          set 'flavor_text_attribution', match[2]
          $el.remove()

        pattern = /^["\u00AB\u201E\u300C]\s*(.+?)\s*["\u00BB\u300D]([.]?)$/
        text = _.map($flavor.children(), t).join('\n')
        text = match[1] + match[2] if match and match = pattern.exec text
        set 'flavor_text', text

      when 'Color Indicator:'
        set 'color_indicator', t1 $el

      when 'Watermark:'
        set 'watermark', t1 $el

      when 'P/T:'
        [..., power, toughness] = ///^(.+?)\s+/\s+(.+)$///.exec t1 $el
        set 'power', gatherer._to_stat power
        set 'toughness', gatherer._to_stat toughness

      when 'Loyalty:'
        set 'loyalty', +t1 $el

      when 'Hand/Life:'
        text = t1 $el
        set 'hand_modifier', +text.match(/Hand Modifier: ([+-]\d+)/)[1]
        set 'life_modifier', +text.match(/Life Modifier: ([+-]\d+)/)[1]

      when 'Expansion:'
        set 'expansion', $el.next().find('a:last-child').text().trim() if verbose

      when 'Rarity:'
        set 'rarity', t1 $el if verbose

      when 'Card Number:'
        set 'number', gatherer._to_stat t1 $el if verbose

      when 'Artist:'
        set 'artist', t1 $el if verbose

      when 'All Sets:'
        set 'versions', gatherer._get_versions $el.next().find('img')

  [..., rating, votes] =
    ///^Community Rating:(\d(?:[.]\d+)?)/5[(](\d+)votes?[)]$///
    .exec $('.textRating').text().replace(/\s+/g, '')
  set 'community_rating', rating: +rating, votes: +votes

  if verbose
    set 'image_url', "#{gatherer.origin}/Handlers/Image.ashx?type=card&multiverseid=#{details.id}"
    set 'gatherer_url', "#{gatherer.origin}/Pages/Card/Details.aspx?multiverseid=#{details.id}"
  else
    # encodeURIComponent notably misses single quote, which messes up cards like "Gideon's Lawkeeper"
    encodedName = encodeURIComponent(details.name).replace(/'/g, '%27')
    set 'image_url', "#{gatherer.origin}/Handlers/Image.ashx?type=card&name=#{encodedName}"
    set 'gatherer_url', "#{gatherer.origin}/Pages/Card/Details.aspx?name=#{encodedName}"
  card

module.exports.url = (path, rest...) ->
  params = {}
  params[k] = v for k, v of o for o in rest
  {id, name, page} = params
  query = {}
  if id?
    query.multiverseid = id
  else
    query.name = name
  if page > 1
    query.page = page - 1
  gatherer.url "/Pages/Card/#{path}", query
