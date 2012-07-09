cheerio   = require 'cheerio'
entities  = require 'entities'


gatherer_root = 'http://gatherer.wizards.com/Pages/'

prefix = '#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent'

symbols =
  White: 'W', 'Phyrexian White':  'W/P'
  Blue:  'U', 'Phyrexian Blue':   'U/P'
  Black: 'B', 'Phyrexian Black':  'B/P'
  Red:   'R', 'Phyrexian Red':    'R/P'
  Green: 'G', 'Phyrexian Green':  'G/P'
  Two:   '2', 'Variable Colorless': 'X'
  Snow:  'S'

to_symbol = (alt) ->
  match = /^(\S+) or (\S+)$/.exec alt
  if match and [a, b] = match[1..] then "#{to_symbol a}/#{to_symbol b}"
  else symbols[alt] or alt

text_content = (obj) ->
  return unless obj
  {$} = this
  obj = if typeof obj is 'string' then @get(obj) else $(obj)
  return unless obj

  obj.find('img').each ->
    $(this).replaceWith "[#{to_symbol $(this).attr('alt')}]"
  obj.text().trim()

get_name = (identifier) -> ->
  return unless name = @text identifier
  # Extract, for example, "Altar's Reap" from "Altar’s Reap (Altar's Reap)".
  if match = /^(.+)’(.+) [(](\1'\2)[)]$/.exec name then match[3] else name

get_mana_cost = (identifier) -> ->
  text if text = @text identifier

get_converted_mana_cost = (identifier) -> ->
  +@text(identifier) or 0

get_text = (identifier) -> ->
  paragraphs = (@text el for el in @get(identifier).children())
  paragraphs = (p for p in paragraphs when p) # exclude empty paragraphs
  paragraphs.join '\n\n' if paragraphs.length

get_versions = (identifier) -> ->
  versions = {}
  {$} = this
  @get(identifier)?.find('img').each ->
    img = $(this)
    [expansion, rarity] = /^(.*\S)\s+[(](.+)[)]$/.exec(img.attr('alt'))[1..]
    expansion = entities.decode expansion
    versions[/\d+$/.exec img.parent().attr('href')] = {expansion, rarity}
  versions

vanguard_modifier = (pattern) -> ->
  +pattern.exec(@text 'Hand/Life')?[1]

to_stat = (stat_as_string) ->
  stat_as_number = +stat_as_string
  # Use string representation if coercing to a number gives `NaN`.
  if stat_as_number is stat_as_number then stat_as_number else stat_as_string


common_attrs =

  name: get_name 'Card Name'

  mana_cost: get_mana_cost 'Mana Cost'

  converted_mana_cost: get_converted_mana_cost 'Converted Mana Cost'

  types: (data) ->
    return unless text = @text 'Types'
    [types, subtypes] = /^(.+?)(?:\s+\u2014\s+(.+))?$/.exec(text)[1..]
    data.subtypes = subtypes?.split(/\s+/) or []
    types.split(/\s+/)

  text: get_text 'Card Text'

  color_indicator: ->
    @text 'Color Indicator'

  watermark: ->
    @text 'Watermark'

  stats: (data) ->
    return unless text = @text 'P/T'
    [power, toughness] = ///^([^/]+?)\s*/\s*([^/]+)$///.exec(text)[1..]
    data.power = to_stat power
    data.toughness = to_stat toughness
    return

  loyalty: ->
    +@text 'Loyalty'

  versions: ->
    versions = get_versions('All Sets').call this
    return versions unless Object.keys(versions).length is 0

    {expansion, rarity} = gid_specific_attrs
    if (expansion = expansion.call this) and (rarity = rarity.call this)
      el = @$(prefix + 'Anchors_DetailsAnchors_Printings').find('a')
      id = el.attr('href').match(/multiverseid=(\d+)/)[1]
      versions[id] = {expansion, rarity}
    versions

  rulings: ->
    rulings = []
    for el in @$('.cardDetails').find('tr.post')
      [date, ruling] = @$(el).children()
      [m, d, y] = @text(date).split('/')
      m = '0' + m if m.length is 1
      d = '0' + d if d.length is 1
      rulings.push [
        "#{y}-#{m}-#{d}"
        @text(ruling).replace(/[{](.+?)[}]/g, '[$1]').replace(/[ ]{2,}/g, ' ')
      ]
    rulings


gid_specific_attrs =

  flavor_text: (data) ->
    return unless flavor = @get('Flavor Text')
    el = flavor.children().last()
    if match = /^\u2014(.+)$/.exec @text el
      data.flavor_text_attribution = match[1]
      el.remove()
    /^"(.+)"$/.exec(text = @text flavor)?[1] or text

  hand_modifier: vanguard_modifier /Hand Modifier: ([+-]\d+)/

  life_modifier: vanguard_modifier /Life Modifier: ([+-]\d+)/

  expansion: ->
    @text @get('Expansion').find('a:last-child')

  rarity: ->
    @text 'Rarity'

  number: ->
    to_stat @text 'Card #'

  artist: ->
    @text 'Artist'


list_view_attrs =

  name: get_name '.cardTitle'

  mana_cost: get_mana_cost '.manaCost'

  converted_mana_cost: get_converted_mana_cost '.convertedManaCost'

  types: (data) ->
    return unless text = @text '.typeLine'
    regex = ///^
      ([^\u2014]+?)             # types
      (?:\s+\u2014\s+(.+?))?    # subtypes
      (?:\s+[(](?:              # "("
        ([^/]+?)\s*/\s*([^/]+)  # power and toughness
        |                       # or...
        (\d+)                   # loyalty
      )[)])?                    # ")"
    $///
    [types, subtypes, power, toughness, loyalty] = regex.exec(text)[1..]
    data.power = to_stat power
    data.toughness = to_stat toughness
    data.loyalty = +loyalty
    data.subtypes = subtypes?.split(/\s+/) or []
    types.split(/\s+/)

  text: get_text '.rulesText'

  versions: get_versions '.setVersions'

exports.language = (body, callback) ->
  $ = cheerio.load body
  data = []

  $('tr.cardItem').each (index, element) ->
    columns = $(this).children('td')

    data.push
      card_name: $(columns[0]).text().trim()
      language: $(columns[1]).text().trim()
      id: parseInt($(columns[0]).find('a').first().attr('href').match(/multiverseid=(\d+)/)[1])

  process.nextTick ->
    callback null, data

exports.card = (body, callback, options = {}) ->
  $ = cheerio.load body
  ctx = $: $, text: text_content, get: (label) ->
    for el in $('.label')
      return $(el).next() if @text(el).replace(/:$/, '') is label

  # Accommodate transforming cards.
  title1 = ctx.text $(prefix + 'Header_subtitleDisplay')
  title2 = ctx.text $(prefix + '_ctl06_nameRow').children('.value')
  $("#{prefix}_cardComponent#{+(title1 isnt title2)}").remove()

  data = {}
  for own key, fn of common_attrs
    data[key] = fn.call ctx, data

  action = $('#aspnetForm').attr('action')
  data.gatherer_url = "#{gatherer_root}Card/#{entities.decode action}"
  if /multiverseid/.test data.gatherer_url
    for own key, fn of gid_specific_attrs
      data[key] = fn.call ctx, data

  for own key, value of data
    delete data[key] if value is undefined or value isnt value # NaN

  if options.printed
    data.type = data.types.join ' '
    delete data.types
    delete data.subtypes

  process.nextTick ->
    callback null, data


exports.set = (body, callback) ->
  $ = cheerio.load body
  ctx = {$, text: text_content}

  pages = do ->
    for link in $('.paging').find('a').get().reverse()
      return number if (number = +ctx.text link) > 0
    1

  id = '#ctl00_ctl00_ctl00_MainContent_SubContent_topPagingControlsContainer'
  page = +ctx.text $(id).children('a[style="text-decoration:underline;"]')

  if +$('#aspnetForm').attr('action').match(/page=(\d+)/)?[1] + 1 is page
    cards = []
    for el in $('.cardItem')
      el = $(el)
      card = {}
      for own key, fn of list_view_attrs
        ctx.get = (selector) -> el.find(selector)

        href = el.find('.cardTitle').find('a').attr('href')
        [param, id] = /multiverseid=(\d+)/.exec href
        card.gatherer_url = "#{gatherer_root}Card/Details.aspx?#{param}"

        {expansion, rarity} = get_versions('.setVersions').call(ctx)[id]
        card.expansion = expansion
        card.rarity = rarity

        card[key] = fn.call ctx, card
      for own key, value of card
        delete card[key] if value is undefined or value isnt value # NaN
      cards.push card
    [error, data] = [null, {page, pages, cards}]
  else
    # Gatherer returns the last page of results for a specified page
    # parameter beyond the upper bound. This is undesirable behaviour;
    # 404 is the appropriate response in such cases.
    error = 'Not Found'
    data = {error, status: 404}

  process.nextTick ->
    callback error, data


collect_options = (label) ->
  (body, callback) ->
    $ = cheerio.load body
    id = "#ctl00_ctl00_MainContent_Content_SearchControls_#{label}AddText"
    values = ($(o).attr('value') for o in $(id).children())
    values = (entities.decode v for v in values when v)

    process.nextTick ->
      callback null, values

exports.sets    = collect_options 'set'
exports.formats = collect_options 'format'
exports.types   = collect_options 'type'
