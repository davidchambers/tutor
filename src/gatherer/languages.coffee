gatherer    = require '../gatherer'
languages   = require '../languages'
load        = require '../load'
pagination  = require '../pagination'
request     = require '../request'


module.exports = (details, callback) ->
  $$ = (fn) ->
    (err, rest...) ->
      if err then callback err else fn rest...

  fetch 1, details, $$ (html) ->
    {max} = pagination load(html) \
      '#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_languageList_pagingControls'
    if max is 1
      callback null, merge extract html
      return
    results = [extract html]
    for page in [2..max]
      fetch page, details, $$ (html) ->
        results.push extract html
        callback null, merge [].concat results... if results.length is max
  return

fetch = (page, details, callback) ->
  url = gatherer.card.url 'Languages.aspx', details, {page}
  request {url, followRedirect: no}, (err, res, body) ->
    err ?= new Error 'unexpected status code' unless res.statusCode is 200
    if err then callback err else callback null, body

extract = (html) ->
  $ = load html
  $('tr.cardItem').map ->
    [trans_card_name, language] = @children()
    $name = $(trans_card_name)
    code = languages[$(language).text().trim()]
    name = $name.text().trim()
    id = +$name.find('a').attr('href').match(/multiverseid=(\d+)/)[1]
    [code, name, id]

merge = (results) ->
  o = {}
  for [code, name, id] in results
    o[code] ?= name: name, ids: []
    o[code].ids.push id
  for code of o
    o[code].ids.sort()
  o
