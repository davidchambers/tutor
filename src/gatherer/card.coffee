gatherer    = require '../gatherer'
load        = require '../load'
supertypes  = require '../supertypes'


module.exports = (details, callback) ->
  if 'which' of details and details.which not in ['a', 'b']
    callback new Error 'invalid which property (valid values are "a" and "b")'

  gatherer.request gatherer.card.url('Details.aspx', details), (err, body) ->
    if err then callback err else callback null, extract body, details
  return

extract = (html, details) ->
  verbose = 'id' of details

  $ = load html
  t = (el) -> gatherer._get_text $(el)
  t1 = (el) -> gatherer._get_text $(el).next()

  card =
    converted_mana_cost: 0
    supertypes: []
    types: []
    subtypes: []
    rulings: []

  set = gatherer._set.bind null, card

  for el in $('.cardDetails').find('tr.post')
    [date, ruling] = $(el).children()
    [m, d, y] = t(date).split('/')
    m = '0' + m if m.length is 1
    d = '0' + d if d.length is 1
    card.rulings.push ["#{y}-#{m}-#{d}", t(ruling).replace(/[ ]{2,}/g, ' ')]

  get_versions = (el) ->
    expansion = $(el).find('.label').filter(-> t(this) is 'Expansion:').next()
    gatherer._get_versions expansion.find('img')

  # Delete the irrelevant column.
  $(do ->
    [left, right] = $('.cardComponentContainer')
    if (details.which is 'b' or
        # Double-faced cards.
        verbose and (details.id of get_versions(right) and
                     details.id not of get_versions(left)) or
        not verbose and details.name is t $(right).find('.value').first())
      left
    else
      right
  ).remove()

  $('.label').each ->

    switch t this

      when 'Card Name:'
        set 'name', t1 this

      when 'Mana Cost:'
        set 'mana_cost', t1 this

      when 'Converted Mana Cost:'
        set 'converted_mana_cost', +t1 this

      when 'Types:'
        [types, subtypes] = /^(.+?)(?:\s+\u2014\s+(.+))?$/.exec(t1 this)[1..]
        for type in types.split(/\s+/)
          card[if type in supertypes then 'supertypes' else 'types'].push type
        set 'subtypes', subtypes?.split(/\s+/)

      when 'Card Text:'
        set 'text', gatherer._get_rules_text @next(), t

      when 'Flavor Text:'
        break unless verbose
        $flavor = $(this).next()
        $el = $flavor.children().last()
        if match = /^(\u2014|\u2015\u2015|\uFF5E)\s*(.+)$/.exec t $el
          set 'flavor_text_attribution', match[2]
          $el.remove()

        pattern = /^["\u00AB\u201E\u300C]\s*(.+?)\s*["\u00BB\u300D]([.]?)$/
        text = $flavor.children().map(-> t this).join('\n')
        text = match[1] + match[2] if match and match = pattern.exec text
        set 'flavor_text', text

      when 'Color Indicator:'
        set 'color_indicator', t1 this

      when 'Watermark:'
        set 'watermark', t1 this

      when 'P/T:'
        [power, toughness] = ///^(.+?)\s+/\s+(.+)$///.exec(t1 this)[1..]
        set 'power', gatherer._to_stat power
        set 'toughness', gatherer._to_stat toughness

      when 'Loyalty:'
        set 'loyalty', +t1 this

      when 'Hand/Life:'
        text = t1 this
        set 'hand_modifier', +text.match(/Hand Modifier: ([+-]\d+)/)[1]
        set 'life_modifier', +text.match(/Life Modifier: ([+-]\d+)/)[1]

      when 'Expansion:'
        set 'expansion', t $(this).next().find('a:last-child') if verbose

      when 'Rarity:'
        set 'rarity', t1 this if verbose

      when 'Card Number:'
        set 'number', gatherer._to_stat t1 this if verbose

      when 'Artist:'
        set 'artist', t1 this if verbose

      when 'All Sets:'
        set 'versions', gatherer._get_versions @next().find('img')

  [rating, votes] =
    ///^Community Rating:(\d(?:[.]\d+)?)/5[(](\d+)votes?[)]$///
    .exec($('.textRating').text().replace(/\s+/g, ''))[1..]
  set 'community_rating', rating: +rating, votes: +votes

  card

module.exports.url = (path, rest...) ->
  params = {}
  params[k] = v for k, v of o for o in rest
  {id, name, page} = params
  query = {}
  if id? and name?
    query.multiverseid = id
    query.part = name
  else if id?
    query.multiverseid = id
  else
    query.name = name
  if page > 1
    query.page = page - 1
  gatherer.url "/Pages/Card/#{path}", query
