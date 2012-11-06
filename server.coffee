express = require 'express'
api     = require './gatherer'


responder = (fn) ->
  (req, res) ->
    fn.call req, (err, data) ->
      if 'error' of data or err?
        console.log "Response error #{data.error}, status #{data.status}"
        res.json data, if data.status in [301, 302] then 404 else data.status
      else if callback = req.param 'callback'
        text = "#{callback}(#{JSON.stringify data})"
        res.send text, 'Content-Type': 'text/plain'
      else
        res.setHeader('Cache-Control', 'public, max-age=86400');
        res.json data

app = express()
app.get /// ^/v1/card/(\d+)(?:/(\w+))?/?$ ///,     responder api.fetch_card
app.get '/v1/card/:name',                          responder api.fetch_card
app.get /// ^/v1/language/(\d+)(?:/(\w+))?/?$ ///, responder api.fetch_language
app.get '/v1/language/:name',                      responder api.fetch_language
app.get '/v1/set/:name/:page?',                    responder api.fetch_set
app.get '/v1/sets',                                responder api.sets
app.get '/v1/formats',                             responder api.formats
app.get '/v1/types',                               responder api.types

port = process.env.PORT ? 3000
app.listen port, -> console.log "Listening on #{port}"
