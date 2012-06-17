express = require 'express'
coffee  = require 'coffee-script'
api     = require './gatherer'


responder = (fn, req_hook = -> []) ->
  (req, res) ->
    args = req_hook req
    args.push (err, data) ->
      if 'error' of data or err?
        console.log "Response error #{data.error}, status #{data.status}"
        res.json data, if data.status in [301, 302] then 404 else data.status
      else if callback = req.param 'callback'
        text = "#{callback}(#{JSON.stringify data})"
        res.send text, 'Content-Type': 'text/plain'
      else
        res.json data
    fn args...

params = (req) -> [req.params]
card_handler = responder api.fetch_card, params

app = express.createServer()
app.get /// ^/card/(\d+)(?:/(\w+))?/?$ ///, card_handler
app.get '/card/:name',                      card_handler
app.get '/set/:name/:page?',                responder api.fetch_set, params
app.get '/sets',                            responder api.sets
app.get '/formats',                         responder api.formats
app.get '/types',                           responder api.types

port = process.env.PORT ? 3000
app.listen port, -> console.log "Listening on #{port}"
