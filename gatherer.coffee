request = require 'request'
parser  = require './parser'


gatherer_url = 'http://gatherer.wizards.com/Pages/'

exports.card = (params, callback) ->
  url = gatherer_url + 'Card/Details.aspx'
  
  switch typeof(params)
    when 'number' then params = {id: params}
    when 'string' then params = {name:params}
  
  if 'id' of params
    url += '?multiverseid=' + params.id
    url += '&part=' + encodeURIComponent params.part if params.part
  else
    url += '?name='  + encodeURIComponent params.name

  url += '&printed=true' if params.printed

  request {url, followRedirect: no}, (error, response, body) ->
    if response.statusCode is 200
      parser.card body, callback
    else
      callback new Error('Card Not Found')

exports.index = (callback) ->
  request {url: gatherer_url}, (error, response, body) ->
    count = 3
    results = {}
    parse_and_merge = (method_name) ->
      parser[method_name] body, (err, local_results) ->
        count--
        results[method_name] = local_results
        callback null, results if count is 0

    parse_and_merge 'sets'
    parse_and_merge 'formats'
    parse_and_merge 'types'

# old API

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

index = (parse_function) ->
  (callback) ->
    request {url: gatherer_url}, (error, response, body) ->
      parser[parse_function] body, callback

exports.sets = index 'sets'

exports.formats = index 'formats'

exports.types = index 'types'
