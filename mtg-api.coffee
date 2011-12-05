http    = require 'http'

express = require 'express'
jsdom   = require 'jsdom'
request = require 'request'


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
  if match and [match, a, b] = match then "#{to_symbol a}/#{to_symbol b}"
  else symbols[alt] or alt

{HTMLElement} = jsdom.dom.level3.html
Object.defineProperty HTMLElement.prototype, 'text', get: ->
  return '[' + to_symbol(@alt) + ']' if @nodeName is 'IMG'
  text = ''
  for node in @childNodes
    switch node.nodeType
      when 1 then text += node.text
      when 3 then text += node.nodeValue.trim()
  # Due to our aggressive trimming, mana symbols can end up touching
  # adjacent words: "[2/R]can be paid with any two mana or with[R]."
  text.replace(/[\w.](?=[[(])/g, '$& ').replace(/\](?=[(\w])/g, '] ')

common_attrs =

  name: ($) ->
    el.text if el = $('Card Name')[0]

  mana_cost: ($) ->
    return unless (images = $('Mana Cost').children().get()).length
    ('[' + to_symbol(alt) + ']' for {alt} in images).join ''

  converted_mana_cost: ($) ->
    if el = $('Converted Mana Cost')[0] then +el.text else 0

  type: ($, data) ->
    return unless el = $('Types')[0]
    match = /^([^\u2014]+?)(?:\s+\u2014\s+([^\u2014]+))?$/.exec el.text
    data.subtype = subtype if subtype = match[2]
    match[1]

  text: ($) ->
    return unless (elements = $('Card Text').children().get()).length
    # Ignore empty paragraphs.
    (el.text for el in elements).filter((paragraph) -> paragraph).join '\n\n'

  color_indicator: ($) ->
    el.text if el = $('Color Indicator')[0]

  watermark: ($) ->
    el.text if el = $('Watermark')[0]

  stats: ($, data) ->
    return unless el = $('P/T')[0]
    [match, p, t] = ///^([^/]+?)\s*/\s*([^/]+)$///.exec el.text
    # Use string representation if coercing to a number gives `NaN`.
    data.power     = if +p is +p then +p else p
    data.toughness = if +t is +t then +t else t
    return

  loyalty: ($) ->
    +el.text if el = $('Loyalty')[0]

  versions: ($, {expansion, rarity}) ->
    versions = {}

    {length} = $('All Sets').find('img').each ->
      [match, expansion, rarity] = /^(.*\S)\s+[(](.+)[)]$/.exec @alt
      versions[/\d+$/.exec @parentNode.href] = {expansion, rarity}

    if length is 0 and img = $('Expansion').find('img')[0]
      {expansion, rarity} = gid_specific_attrs
      if (expansion = expansion $) and (rarity = rarity $)
        versions[/\d+$/.exec img.parentNode.href] = {expansion, rarity}

    versions

  rulings: ($, data, jQuery) ->
    rulings = []
    jQuery('.cardDetails').find('tr.post').each ->
      return unless ($td = jQuery(this).children()).length is 2
      [match, month, date, year] = /(\d+)\/(\d+)\/(\d+)/.exec $td.get(0).text
      month = "0#{month}" if month.length is 1
      date = "0#{date}" if date.length is 1
      text = $td.get(1).textContent.trim().replace(/[{](.+?)[}]/g, '[$1]')
      rulings.push ["#{year}-#{month}-#{date}", text]
    rulings

gid_specific_attrs =

  flavor_text: ($, data) ->
    return unless ($flavor = $('Flavor Text')).length
    $children = $flavor.children()
    if match = /^\u2014(.+)$/.exec $children.get(-1).text
      data.flavor_text_attribution = match[1]
      $children.last().remove()
    (/^"(.+)"$/.exec(text = $flavor[0].text) or [])[1] or text

  expansion: ($) ->
    el.text if el = $('Expansion').find('a:last-child')[0]

  rarity: ($) ->
    el.text if el = $('Rarity')[0]

  number: ($) ->
    +el.text if el = $('Card #')[0]

  artist: ($) ->
    el.text if el = $('Artist')[0]


handler = (req, res) ->
  {params} = req
  url = 'http://gatherer.wizards.com/Pages/Card/Details.aspx'
  if gid_provided = 'name' not of params
    [id, part] = params
    url += '?multiverseid=' + id
    url += '&part=' + encodeURIComponent part if part
  else
    url += '?name=' + encodeURIComponent params.name

  request {url, followRedirect: no}, (error, response, body) ->
    if error or (status = response.statusCode) isnt 200
      # Gatherer does a 302 redirect if the requested id does not exist.
      # In such cases, we respond with the more appropriate status code.
      res.json {error, status}, if status in [301, 302] then 404 else status
      return

    jquery_url = 'http://code.jquery.com/jquery-latest.js'
    jsdom.env body, [jquery_url], (errors, {jQuery}) ->
      $ = (label) -> jQuery('.label').filter(-> @text is label + ':').next()
      attach_attrs = (attrs, data) ->
        for own key, fn of attrs
          result = fn($, data, jQuery)
          data[key] = result unless result is undefined
        data
      data = attach_attrs common_attrs, {}
      if gid_provided
        attach_attrs gid_specific_attrs, data
        data.gatherer_url = url

      if callback = req.param 'callback'
        text = "#{callback}(#{JSON.stringify data})"
        res.send text, 'Content-Type': 'text/plain'
      else
        res.json data

app = express.createServer()
app.get /// ^/card/(\d+)(?:/(\w+))?/?$ ///, handler
app.get '/card/:name', handler
app.listen 3000
