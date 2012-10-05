cheerio   = require 'cheerio'
entities  = require 'entities'


supertypes = ['Basic', 'Legendary', 'Ongoing', 'Snow', 'World']
gatherer_base_card_url = 'http://gatherer.wizards.com/Pages/Card/Details.aspx'
gatherer_image_handler = 'http://gatherer.wizards.com/Handlers/Image.ashx'

prefix = '#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent'

symbols =
  White: 'W', 'Phyrexian White':    'W/P'
  Blue:  'U', 'Phyrexian Blue':     'U/P'
  Black: 'B', 'Phyrexian Black':    'B/P'
  Red:   'R', 'Phyrexian Red':      'R/P'
  Green: 'G', 'Phyrexian Green':    'G/P'
  Two:   '2', 'Variable Colorless': 'X'
  Snow:  'S'
  Tap:   'T'
  Untap: 'Q'

languages =
  'Chinese Simplified':  'zh-TW'
  'Chinese Traditional': 'zh-CN'
  'German':              'de'
  'English':             'en'
  'French':              'fr'
  'Italian':             'it'
  'Japanese':            'ja'
  'Korean':              'kr'
  'Portuguese':          'pt-BR' # there is a typo in older cards
  'Portuguese (Brazil)': 'pt-BR'
  'Russian':             'ru'
  'Spanish':             'es'

meaningful = (value) ->
  not (value is undefined or Number.isNaN value)

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
    $(this).replaceWith "{#{to_symbol $(this).attr('alt')}}"
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
  return unless el = @get(identifier)
  paragraphs = (@text el for el in el.children())
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
  stat_as_number = +stat_as_string?.replace('{1/2}', '.5')
  if Number.isNaN stat_as_number then stat_as_string else stat_as_number


common_attrs =

  name: get_name 'Card Name'

  mana_cost: get_mana_cost 'Mana Cost'

  converted_mana_cost: get_converted_mana_cost 'Converted Mana Cost'

  types: (data) ->
    return unless text = @text 'Types'
    [types, subtypes] = /^(.+?)(?:\s+\u2014\s+(.+))?$/.exec(text)[1..]
    data.supertypes = []
    data.types = []
    for type in types.split(/\s+/)
      data[if type in supertypes then 'supertypes' else 'types'].push type
    data.subtypes = subtypes?.split(/\s+/) or []
    return

  text: get_text 'Card Text'

  color_indicator: ->
    @text 'Color Indicator'

  watermark: ->
    @text 'Watermark'

  stats: (data) ->
    return unless text = @text 'P/T'
    [power, toughness] = ///^(.+?)\s+/\s+(.+)$///.exec(text)[1..]
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

  community_rating: ->
    text = @$('.textRating').text().replace(/\s+/g, '')
    pattern = ///^Rating:(\d(?:[.]\d+)?)/5[(](\d+)votes?[)]$///
    [rating, votes] = pattern.exec(text)[1..]
    rating: +rating, votes: +votes

  rulings: ->
    rulings = []
    for el in @$('.cardDetails').find('tr.post')
      [date, ruling] = @$(el).children()
      [m, d, y] = @text(date).split('/')
      m = '0' + m if m.length is 1
      d = '0' + d if d.length is 1
      rulings.push [
        "#{y}-#{m}-#{d}"
        @text(ruling).replace(/[ ]{2,}/g, ' ')
      ]
    rulings


gid_specific_attrs =

  flavor_text: (data) ->
    return unless flavor = @get('Flavor Text')

    el = flavor.children().last()
    if match = /^(\u2014|\u2015\u2015|\uFF5E)\s*(.+)$/.exec @text el
      data.flavor_text_attribution = match[2]
      el.remove()

    pattern = /^["\u00AB\u201E\u300C]\s*(.+?)\s*["\u00BB\u300D]([.]?)$/
    text = (@text el for el in flavor.children()).join '\n'
    text = match[1] + match[2] if match and match = pattern.exec text
    text

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
    data.supertypes = []
    data.types = []
    for type in types.split(/\s+/)
      data[if type in supertypes then 'supertypes' else 'types'].push type
    data.subtypes = subtypes?.split(/\s+/) or []
    data.power = to_stat power
    data.toughness = to_stat toughness
    data.loyalty = +loyalty
    return

  text: get_text '.rulesText'

  versions: get_versions '.setVersions'

exports.language = (body, callback, options = {}) ->
  $ = cheerio.load body

  data = {}
  $('tr.cardItem').each ->
    [trans_card_name, language, trans_language] = $(this).children()
    $name = $(trans_card_name)
    $lang = $(language)
    data[languages[$lang.text().trim()]] =
      id: +$name.find('a').attr('href').match(/multiverseid=(\d+)/)[1]
      name: $name.text().trim()

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
    value = fn.call ctx, data
    data[key] = value if meaningful value

  action = entities.decode $('#aspnetForm').attr('action')
  params = action.substr action.indexOf '?'
  data.gatherer_url = gatherer_base_card_url + params
  data.image_url = gatherer_image_handler +
    '?' + /(multiverseid|name)=[^&]+/.exec(params)[0] + '&type=card'

  if /multiverseid/.test data.gatherer_url
    for own key, fn of gid_specific_attrs
      value = fn.call ctx, data
      data[key] = value if meaningful value

  if options.printed
    data.type = [data.supertypes..., data.types..., data.subtypes...].join ' '
    delete data.supertypes
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
        params = '?' + param
        card.gatherer_url = gatherer_base_card_url + params
        card.image_url = gatherer_image_handler + params + '&type=card'

        {expansion, rarity} = get_versions('.setVersions').call(ctx)[id]
        card.expansion = expansion
        card.rarity = rarity

        value = fn.call ctx, card
        card[key] = value if meaningful value
      delete card[key] for own key, value of card when not meaningful value
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
