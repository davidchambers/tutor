gatherer    = require '../gatherer'
load        = require '../load'
request     = require '../request'
supertypes  = require '../supertypes'
urlmod      = require '../url'


module.exports = ({name, page}, callback) ->
  page ?= 1
  unless page > 0
    callback new Error 'invalid page number'
    return
  url = 'http://gatherer.wizards.com/Pages/Search/Default.aspx'
  url += "?set=[%22#{encodeURIComponent name}%22]&page=#{page - 1}"
  request {url}, (err, res, body) ->
    return callback err if err?
    return callback new Error 'unexpected status code' unless res.statusCode is 200
    try set = extract body catch err then return callback err
    callback null, set
  return

extract = (html) ->

  $ = load html
  t = (el) -> gatherer._get_text $ el

  underlined = $(
    '#ctl00_ctl00_ctl00_MainContent_SubContent_topPagingControlsContainer'
  ).children('a[style="text-decoration:underline;"]')

  set =
    page: if underlined.length then +t underlined else 1
    pages: Math.max 1, $('.paging').find('a').map(->
      +urlmod.parse(@attr('href'), yes).query.page + 1)...
    cards: []

  # Gatherer returns the last page of results for a specified page
  # parameter beyond the upper bound.
  match = $('#aspnetForm').attr('action').match(/page=(\d+)/)
  unless match and ++match[1] is set.page
    throw new Error 'page not found'

  $('.cardItem').each ->
    set.cards.push card =
      converted_mana_cost: 0
      supertypes: []
      types: []
      subtypes: []
    @find('div, span').each ->
      switch @attr 'class'
        when 'cardTitle'
          gatherer._set card, 'name', t this
        when 'manaCost'
          gatherer._set card, 'mana_cost', t this
        when 'convertedManaCost'
          gatherer._set card, 'converted_mana_cost', +t this
        when 'typeLine'
          regex = ///^
            ([^\u2014]+?)             # types
            (?:\s+\u2014\s+(.+?))?    # subtypes
            (?:\s+[(](?:              # "("
              ([^/]+(?:[{][^}]+[}])?) # power
              \s*/\s*                 # "/"
              ([^/]+(?:[{][^}]+[}])?) # toughness
              |                       # or...
              (\d+)                   # loyalty
            )[)])?                    # ")"
          $///
          [types, subtypes, power, toughness, loyalty] = regex.exec(t this)[1..]
          for type in types.split(/\s+/)
            card[if type in supertypes then 'supertypes' else 'types'].push type
          gatherer._set card, 'subtypes', subtypes?.split(/\s+/) or []
          gatherer._set card, 'power', gatherer._to_stat power
          gatherer._set card, 'toughness', gatherer._to_stat toughness
          gatherer._set card, 'loyalty', +loyalty

    gatherer._set card, 'text', gatherer._get_rules_text @find('.rulesText'), t

    href = @find('.cardTitle').find('a').attr('href')
    [param, id] = /multiverseid=(\d+)/.exec href
    card.gatherer_url =
      "http://gatherer.wizards.com/Pages/Card/Details.aspx?#{param}"
    card.image_url =
      "http://gatherer.wizards.com/Handlers/Image.ashx?#{param}&type=card"

    card.versions = gatherer._get_versions @find('.setVersions').find('img')
    {expansion, rarity} = card.versions[id]
    card.expansion = expansion
    card.rarity = rarity

  set
