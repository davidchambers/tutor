fs        = require 'fs'
{compile} = require 'coffee-script'
{diff}    = require 'jsondiffpatch'


__ = (text) -> text.replace(/([^\n])\n(?!\n)/g, '$1 ')

load_fixture = (prefix, fixture, format) ->
  name = fixture.toLowerCase().replace(/[ ,-]/g, '')
  fs.readFileSync "#{__dirname}/fixtures/#{prefix}/#{name}.#{format}", 'utf8'

coffee_fixture_for = (prefix) ->
  (name) -> eval compile load_fixture(prefix, name, 'coffee'), bare: yes

web_fixture = (name) -> load_fixture 'web', name, 'html'

exports.card     = coffee_fixture_for 'cards'
exports.language = coffee_fixture_for 'languages'
exports.web      = web_fixture

exports.matcher = (action, fixture) ->
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
        obj.should.eql fixture.response
      done()
    action html, test, fixture.options or {}
