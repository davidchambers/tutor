request = require 'request'
parser  = require './parser'


gatherer_url = 'http://gatherer.wizards.com/Pages/'

build_card_url = (params) ->
  url = gatherer_url + 'Card/Details.aspx'
  if 'name' of params
    url += '?name=' + encodeURIComponent params.name
  else
    [id, part] = params
    url += '?multiverseid=' + id
    url += '&part=' + encodeURIComponent part if part
  url

build_set_url = (name, page) ->
  url = gatherer_url + 'Search/Default.aspx'
  url + "?set=[%22#{encodeURIComponent name}%22]&page=#{page - 1}"

exports.fetch_card = (params, callback) ->
  url = build_card_url params
  request {url, followRedirect: no}, (error, response, body) ->
    if error or (status = response.statusCode) isnt 200
      # Gatherer does a 302 redirect if the requested id does not exist.
      # In such cases, we respond with the more appropriate status code.
      callback error, {error, status}
      return
    parser.card body, callback

exports.fetch_set = (params, callback) ->
  page = +(params.page ? 1)
  url = build_set_url params.name, page
  request {url}, (error, response, body) ->
    parser.set body, callback

index = (parse_function) ->
  (callback) ->
    request {url: gatherer_url}, (error, response, body) ->
      parse_function body, callback

exports.sets = index parser.sets

exports.formats = index parser.formats

exports.types = index parser.types
