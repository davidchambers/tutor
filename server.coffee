express = require 'express'
coffee  = require 'coffee-script'
api     = require './gatherer'

build_responder = (req, res) ->
  (err, data) ->
    if 'error' of data or err?
      console.log "Response error #{data.error}, status #{data.status}"
      res.json data, if data.status in [301, 302] then 404 else data.status
    else if callback = req.param 'callback'
      text = "#{callback}(#{JSON.stringify data})"
      res.send text, 'Content-Type': 'text/plain'
    else
      res.json data

card_handler = (req, res) ->
  api.fetch_card req.params, build_responder req, res

set_handler = (req, res) ->
  api.fetch_set req.params, build_responder req, res

app = express.createServer()
app.get /// ^/card/(\d+)(?:/(\w+))?/?$ ///, card_handler
app.get '/card/:name', card_handler
app.get '/set/:name/:page?', set_handler
app.get '/sets', (req, res) -> api.sets build_responder req, res
app.get '/formats', (req, res) -> api.formats build_responder req, res
app.get '/types', (req, res) -> api.types build_responder req, res

port = process.env.PORT ? 3000
app.listen port, -> console.log "Listening on #{port}"
