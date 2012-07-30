CoffeeScript = require 'coffee-script'
fs           = require 'fs'
__           = (text) -> text.replace(/([^\n])\n(?!\n)/g, '$1 ')

fixture = (prefix, filename) ->
  source = fs.readFileSync("#{__dirname}/fixtures/#{prefix}/#{filename}.coffee").toString()
  eval CoffeeScript.compile(source, bare: on)

exports.card_fixture = (filename) ->
  fixture 'cards', filename

exports.language_fixture = (filename) ->
  fixture 'languages', filename

