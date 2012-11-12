request = require 'request'
parser  = require './parser'


gatherer_url = 'http://gatherer.wizards.com/Pages/'

exports.fetch_language = (callback) ->
  url = gatherer_url + 'Card/Languages.aspx'

  if 'name' of @params
    url += '?name=' + encodeURIComponent @params.name
  else
    [id, part] = @params
    url += '?multiverseid=' + id
    url += '&part=' + encodeURIComponent part if part

  request {url, followRedirect: no}, (error, response, body) ->
    if error or (status = response.statusCode) isnt 200
      callback error, {error, status}
      return

    parser.language body, callback


exports.fetch_card = (callback) ->
  printed = @query.printed is 'true'
  url = gatherer_url + 'Card/Details.aspx'
  if 'name' of @params
    url += '?name=' + encodeURIComponent @params.name
  else
    [id, part] = @params
    url += '?multiverseid=' + id
    url += '&part=' + encodeURIComponent part if part
  if printed
    url += '&printed=true'

  request {url, followRedirect: no}, (error, response, body) ->
    if error or (status = response.statusCode) isnt 200
      # Gatherer does a 302 redirect if the requested id does not exist.
      # In such cases, we respond with the more appropriate status code.
      callback error, {error, status}
      return
    parser.card body, callback, {printed}

exports.fetch_set = (callback) ->
  page = +(@params.page ? 1)
  url = gatherer_url + 'Search/Default.aspx'
  url += "?set=[%22#{encodeURIComponent @params.name}%22]&page=#{page - 1}"

  request {url}, (error, response, body) ->
    parser.set body, callback

index = (name) ->
  (callback) ->
    request {url: gatherer_url}, (error, response, body) ->
      parser[name] body, callback

['formats', 'sets', 'types'].forEach (name) -> exports[name] = index name
