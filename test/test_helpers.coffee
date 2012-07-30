{compile} = require 'coffee-script'
fs        = require 'fs'
__        = (text) -> text.replace(/([^\n])\n(?!\n)/g, '$1 ')


load_fixture = (prefix, fixture, format) ->
  name = fixture.toLowerCase().replace(/[ ,-]/g, "")
  path = "#{__dirname}/fixtures/#{prefix}/#{name}.#{format}"
  fs.readFileSync(path).toString()

card_fixture = (name) ->
  eval compile(load_fixture('cards', name, 'coffee'), bare: on)

language_fixture = (name) ->
  eval compile(load_fixture('languages', name, 'coffee'), bare: on)

web_fixture = (name) ->
  load_fixture 'web', name, 'html'

matches_fixture = (action, fixture) ->
  (done) ->
    name = fixture.name || fixture.params?.name || fixture.response?.name
    html = web_fixture name
    test = (err, obj) ->
      obj.should.eql fixture.response
      done()
    action html, test, (fixture.options || {})

exports.card_fixture     = card_fixture
exports.language_fixture = language_fixture
exports.web_fixture      = web_fixture
exports.matches_fixture  = matches_fixture

