cheerio   = require 'cheerio'
entities  = require 'entities'
request   = require 'request'
_         = require 'underscore'

symbols   = require './symbols'


gatherer = module.exports
gatherer.origin = 'https://gatherer.wizards.com'
gatherer.url = (pathname, query = {}) ->
  url = "#{gatherer.origin}#{pathname}"
  keys = _.keys(query).sort()
  if keys.length
    url += "?#{("#{encodeURIComponent key}=#{encodeURIComponent query[key]}" \
                for key in keys).join('&')}"
  url

gatherer.request = (args...) ->
  if args.length >= 3
    [uri, options, callback] = args
    options = JSON.parse JSON.stringify options
    options.uri = uri
  else if _.isString args[0]
    [uri, callback] = args
    options = {uri}
  else
    [options, callback] = args

  request options, (err, res, body) ->
    if err?
      callback err
    else if res.statusCode isnt 200
      callback new Error 'unexpected status code'
    else
      callback null, res, body

gatherer[name] = require "./gatherer/#{name}" for name in [
  'card'
  'languages'
  'printings'
  'set'
]

collect_options = (label) -> (callback) ->
  gatherer.request gatherer.url('/Pages/Default.aspx'), (err, res, body) ->
    if err?
      callback err
    else
      callback null, extract cheerio.load(body), label
    return
  return

extract = ($, label) ->
  id = "#ctl00_ctl00_MainContent_Content_SearchControls_#{label}AddText"
  values = ($(o).attr('value') for o in $(id).children())
  values = (entities.decode v for v in values when v)

gatherer.formats  = collect_options 'format'
gatherer.sets     = collect_options 'set'
gatherer.types    = collect_options 'type'

to_symbol = (alt) ->
  m = /^(\S+) or (\S+)$/.exec alt
  m and "#{to_symbol m[1]}/#{to_symbol m[2]}" or symbols[alt] or alt

gatherer._get_text = (node) ->
  clone = node.clone()
  _.each clone.find('img'), (el) ->
    $el = cheerio el
    $el.replaceWith "{#{to_symbol $el.attr 'alt'}}"
  clone.text().trim()

gatherer._get_rules_text = (node, get_text) ->
  _.map(node.children(), get_text).filter(Boolean).join('\n\n')

gatherer._get_versions = (image_nodes) ->
  _.object _.map image_nodes, (el) ->
    $el = cheerio el
    key = /\d+$/.exec $el.parent().attr('href')
    match = /^(.*) [(](.*?)[)]$/.exec $el.attr('alt')
    value =
      expansion: entities.decode match[1]
      rarity: match[2]
    [key, value]

gatherer._set = (obj, key, value) ->
  obj[key] = value unless value is undefined or _.isNaN value

gatherer._to_stat = (str) ->
  num = +str?.replace('{1/2}', '.5').replace('½', '.5')
  if _.isNaN num then str else num
