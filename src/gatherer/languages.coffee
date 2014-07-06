cheerio     = require 'cheerio'
_           = require 'underscore'

gatherer    = require '../gatherer'
languages   = require '../languages'
pagination  = require '../pagination'


module.exports = (details, callback) ->
  $$ = (fn) -> (err, res, body) -> if err then callback err else fn body

  fetch 1, details, $$ (html) ->
    $ = cheerio.load html
    {max} = pagination $ \
      '#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_languageList_pagingControls'
    if max is 1
      callback null, merge extract $
      return
    results = [extract $]
    for page in [2..max]
      fetch page, details, $$ (html) ->
        results.push extract cheerio.load html
        callback null, merge results if results.length is max
  return

fetch = (page, details, callback) ->
  url = gatherer.card.url 'Languages.aspx', details, {page}
  gatherer.request url, callback

extract = ($) ->
  _.chain $('tr.cardItem')
  .map cheerio
  .invoke 'children'
  .map ($children) ->
    code: languages[$children.eq(1).text().trim()]
    name: $children.eq(0).text().trim()
    id: +$children.eq(0).find('a').attr('href').match(/multiverseid=(\d+)/)[1]
  .value()

merge = (results) ->
  _.chain results
  .flatten yes
  .sortBy 'id'
  .groupBy 'code'
  .map (triplets, code) -> [
    code
    name: triplets[0].name, ids: _.pluck triplets, 'id'
  ]
  .object()
  .value()
