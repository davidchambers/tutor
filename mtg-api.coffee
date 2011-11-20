http    = require 'http'

express = require 'express'
jsdom   = require 'jsdom'


symbols = White: 'W', Blue: 'U', Black: 'B', Red: 'R', Green: 'G', Two: 2

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
  text.replace(/(\w)([[(])/g, '$1 $2').replace(/\](?=[(\w])/g, '] ')

gatherer_url = (id) ->
  'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=' + id

get =

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
    (el.text for el in elements).join '\n\n'

  flavor_text: ($, data) ->
    return unless ($flavor = $('Flavor Text')).length
    $children = $flavor.children()
    if match = /^\u2014(.+)$/.exec $children.get(-1).text
      data.flavor_text_attribution = match[1]
      $children.last().remove()
    (/^"(.+)"$/.exec(text = $flavor[0].text) or [])[1] or text

  color_indicator: ($) ->
    el.text if el = $('Color Indicator')[0]

  stats: ($, data) ->
    return unless el = $('P/T')[0]
    [match, p, t] = ///^([^/]+?)\s*/\s*([^/]+)$///.exec el.text
    # Use string representation if coercing to a number gives `NaN`.
    data.power     = if +p is +p then +p else p
    data.toughness = if +t is +t then +t else t
    return

  loyalty: ($) ->
    +el.text if el = $('Loyalty')[0]

  expansion: ($) ->
    el.text if el = $('Expansion').find('a:last-child')[0]

  rarity: ($) ->
    el.text if el = $('Rarity')[0]

  number: ($) ->
    +el.text if el = $('Card #')[0]

  artist: ($) ->
    el.text if el = $('Artist')[0]


app = express.createServer()

app.get '/card/:id', (req, res) ->
  url = gatherer_url req.params.id
  jsdom.env url, ['http://code.jquery.com/jquery-latest.js'], (err, window) ->
    {jQuery} = window
    $ = (label) -> jQuery('.label').filter(-> @text is label + ':').next()
    data = gatherer_url: url
    for own key, fn of get
      result = fn($, data)
      data[key] = result unless result is undefined
    res.json data

app.listen 3000
