cheerio   = require 'cheerio'

gatherer  = require './gatherer'
url       = require './url'


module.exports = ($container) ->
  $links = $container.children('a')
  $selected = $links.filter('[style="text-decoration:underline;"]')
  numbers = $links.toArray().map(cheerio).map ($link) ->
    +url.parse($link.attr('href'), yes).query.page + 1

  min: Math.min 1, numbers...
  max: Math.max 1, numbers...
  selected: if $selected.length then +gatherer._get_text($selected) else 1
