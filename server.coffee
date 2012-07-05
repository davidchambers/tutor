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
        res.json data

app = express.createServer()
app.get /// ^/card/(\d+)(?:/(\w+))?/?$ ///, responder api.fetch_card
app.get '/card/:name',                      responder api.fetch_card
app.get /// ^/lang/(\d+)(?:/(\w+))?/?$ ///, responder api.fetch_lang
app.get '/lang/:name',                      responder api.fetch_lang
app.get '/set/:name/:page?',                responder api.fetch_set
app.get '/sets',                            responder api.sets
app.get '/formats',                         responder api.formats
app.get '/types',                           responder api.types

port = process.env.PORT ? 3000
app.listen port, -> console.log "Listening on #{port}"
