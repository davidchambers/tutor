express = require 'express'
fetch   = require './fetch'


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

app = express.createServer()
app.get /// ^/card/(\d+)(?:/(\w+))?/?$ ///,     responder fetch.card
app.get '/card/:name',                          responder fetch.card
app.get /// ^/language/(\d+)(?:/(\w+))?/?$ ///, responder fetch.language
app.get '/language/:name',                      responder fetch.language
app.get '/set/:name/:page?',                    responder fetch.set
app.get '/sets',                                responder fetch.sets
app.get '/formats',                             responder fetch.formats
app.get '/types',                               responder fetch.types

port = process.env.PORT ? 3000
app.listen port, -> console.log "Listening on #{port}"
