{compile} = require 'coffee-script'
{diff}    = require 'jsondiffpatch'
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
    name = fixture.name or fixture.params?.name or fixture.response?.name
    html = web_fixture name
    test = (err, obj) ->
      # Show a diff like output when explicitly told
      # It's slower than the deep equality test performed by should, but more
      # developer friendly and very easy to read.
      if process.env.TUTOR_SHOW_DELTA
        delta = diff(obj, fixture.response) or []
        patch = JSON.stringify delta, null, 4
        info  = "\n\nUnexpected difference while parsing: #{name}:\n#{patch}"
        delta.should.eql [], info
      else
        obj.should.eql fixture.response, message
      done()
    action html, test, (fixture.options || {})

exports.card_fixture     = card_fixture
exports.language_fixture = language_fixture
exports.web_fixture      = web_fixture
exports.matches_fixture  = matches_fixture

