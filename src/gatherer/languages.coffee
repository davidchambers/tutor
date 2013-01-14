gatherer  = require '../gatherer'
languages = require '../languages'
load      = require '../load'
request   = require '../request'


module.exports = (details, callback) ->
  url = gatherer.card.url 'Languages.aspx', details
  request {url, followRedirect: no}, (err, res, body) ->
    err ?= new Error 'unexpected status code' unless res.statusCode is 200
    if err then callback err else callback null, extract body
  return

extract = (html) ->
  $ = load html
  data = {}
  $('tr.cardItem').each ->
    [trans_card_name, language] = @children()
    $name = $(trans_card_name)
    data[languages[$(language).text().trim()]] =
      id: +$name.find('a').attr('href').match(/multiverseid=(\d+)/)[1]
      name: $name.text().trim()
  data
