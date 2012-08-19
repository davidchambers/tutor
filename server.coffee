express = require 'express'
api     = require './gatherer'

processResponse = (req, res) ->
  (err, data) ->
    if 'error' of data or err?
      console.log "Response error #{data.error}, status #{data.status}"
      res.json data, if data.status in [301, 302] then 404 else data.status
    else if callback = req.param 'callback'
      text = "#{callback}(#{JSON.stringify data})"
      res.send text, 'Content-Type': 'text/plain'
    else
      res.setHeader('Cache-Control', 'public, max-age=86400');
      res.json data

responder = (fn) ->
  (req, res) ->
    console.log req.method, req.url
    [id, part] = req.params
    {name, page} = req.params
    printed = req.query.printed is 'true'
    fn({id, part, name, page, printed}, processResponse(req, res))

app = express()

app.get /// ^/card/(\d+)(?:/(\w+))?/?$ ///,     responder api.fetch_card
app.get '/card/:name',                          responder api.fetch_card
app.get /// ^/language/(\d+)(?:/(\w+))?/?$ ///, responder api.fetch_language
app.get '/language/:name',                      responder api.fetch_language
app.get '/set/:name/:page?',                    responder api.fetch_set

# routes with no parameters
app.get '/sets',    (req, res) -> api.sets processResponse(req, res)
app.get '/formats', (req, res) -> api.formats processResponse(req, res)
app.get '/types',   (req, res) -> api.types processResponse(req, res)

port = process.env.PORT ? 3000
app.listen port, -> console.log "Listening on #{port}"
