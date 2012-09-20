request = require 'request'
parser  = require './parser'


gatherer_url = 'http://gatherer.wizards.com/Pages/'

card_query_string = (params) ->
  q = ''
  if params.name?
    q += '?name=' + encodeURIComponent params.name
  else
    q += '?multiverseid=' + params.id
    q += '&part=' + encodeURIComponent params.part if params.part
  q += '&printed=true' if params.printed 
  q

request_and_parse = (params, callback) -> 
  console.log "sending request to #{params.url}"
  request {url:params.url, followRedirect: no}, (error, response, body) ->
    if error or (status = response.statusCode) isnt 200
      # Gatherer does a 302 redirect if the requested id does not exist.
      # In such cases, we respond with the more appropriate status code.
      callback error, {error, status}
      return
    params.parser body, callback, params

exports.fetch_language = (params, callback) ->
  url = gatherer_url + 'Card/Languages.aspx' + card_query_string(params)
  request_and_parse {url, parser: parser.language}, callback

exports.fetch_card = (params, callback) ->
  url = gatherer_url + 'Card/Details.aspx' + card_query_string(params)   
  request_and_parse {url, parser: parser.card, printed: params.printed}, callback

exports.fetch_set = (params, callback) ->
  page = +(params.page ? 1)
  url = gatherer_url + 'Search/Default.aspx'
  url += "?set=[%22#{encodeURIComponent params.name}%22]&page=#{page - 1}"

  request {url}, (error, response, body) ->
    parser.set body, callback

index = (parse_function) ->
  (callback) ->
    request {url: gatherer_url}, (error, response, body) ->
      parse_function body, callback

exports.sets = index parser.sets

exports.formats = index parser.formats

exports.types = index parser.types
