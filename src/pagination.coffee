cheerio   = require 'cheerio'
_         = require 'underscore'
url       = require 'url'

gatherer  = require './gatherer'


module.exports = ($container) ->
  $links = $container.children('a')
  $selected = $links.filter('[style="text-decoration:underline;"]')
  numbers = _.map $links, (el) ->
    +url.parse(cheerio(el).attr('href'), yes).query.page + 1

  min: _.min [1, numbers...]
  max: _.max [1, numbers...]
  selected: if $selected.length then +gatherer._get_text($selected) else 1
