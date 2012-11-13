nock     = require 'nock'
should   = require 'should'
sinon    = require 'sinon'

gatherer = require '../gatherer'
parser   = require '../parser'

err_404 =
  error: null
  status: 404

err_302 =
  error: null
  status: 302

# response fixtures
fake_page = 'totally html, i swear'
fake_object = {source: 'parser', contents: 'arbitrary'}

# parameter fixtures
id_only = {id: 10}
name_only = {name: 'a name'}
name_and_id = {name: name_only.name, id: id_only.id}
id_and_part = {id: id_only.id, part: 'the name of a part'}
id_printed = {id: id_only.id, printed: true}

# Nock
site = nock('http://gatherer.wizards.com')

card_route = (params) ->
  '/Pages/Card/Details.aspx' + card_query_string(params)
language_route = (params) ->
  '/Pages/Card/Languages.aspx' + card_query_string(params)
set_route = '/Pages/Search/Default.aspx'

card_query_string = (params) ->
  string = ''
  return string unless params?
  switch typeof params
    when 'number' then params = {id: params}
    when 'string' then params = {name:params}

  if 'id' of params
    string += '?multiverseid=' + params.id
    string += '&part=' + encodeURIComponent params.part if params.part
  else
    string += '?name='  + encodeURIComponent params.name

  string += '&printed=true' if params.printed
  string

mock_route = (route) ->
  site.get(route).reply(200, fake_page)
mock_card_route = (params) ->
  mock_route card_route(params)
mock_language_route = (params) ->
  mock_route language_route(params)

# Gatherer frequently redirects rather than 404ing
mock_redirect = (route) ->
  site.get(route).reply(302)

stub_parser = (func_name) ->
  sinon.stub parser, func_name, (body, callback) ->
    callback null, fake_object

should_parse_using = (parser_function, done) ->
  (error, data) ->
    data.should.eql fake_object
    parser_function.withArgs(fake_page).calledOnce.should.be.true
    site.done()
    done()

it_requests_and_parses = (func, params, request_route, parse_func) ->
  it 'can request and parse properly given the argument ' + JSON.stringify(params), (done) ->
    mock_route request_route
    if parse_func?
      parse_with = parser[parse_func]
    else
      parse_with = parser[func]
    gatherer[func] params, should_parse_using(parse_with, done)

it_can_request_and_parse_a_card_using = (params) ->
  it_requests_and_parses 'card', params, card_route(params)

it_can_request_and_parse_a_cards_languages_using = (params) ->
  it_requests_and_parses 'languages', params, language_route(params), 'language'

describe '.card', ->

  beforeEach ->
    @parser_stub = stub_parser 'card'

  afterEach ->
    @parser_stub.restore()

  it_can_request_and_parse_a_card_using id_only
  it_can_request_and_parse_a_card_using name_only
  it_can_request_and_parse_a_card_using name_and_id
  it_can_request_and_parse_a_card_using 'a name'
  it_can_request_and_parse_a_card_using 10
  it_can_request_and_parse_a_card_using id_printed

  it 'recognizes redirects as a not-found error', (done) ->
    mock_redirect card_route(id_only)

    gatherer.card id_only, (error, data) ->
      error.message.should.eql 'Card Not Found'
      parser.card.called.should.be.false
      site.done()
      done()


describe '.set', ->
  beforeEach ->
    @parser_stub = sinon.stub parser, 'set', (body, callback) ->
      callback(null, fake_object)

  afterEach ->
    @parser_stub.restore()

  it 'fetches sets by name', (done) ->
    site.get(set_route + '?set=[%22Homelands%22]&page=0')
      .reply(200, fake_page)

    gatherer.set 'Homelands', should_parse_using(parser.set, done)

  it 'fetches a page when specified', (done) ->
    site.get(set_route + '?set=[%22Homelands%22]&page=3')
      .reply(200, fake_page)

    gatherer.set {name: 'Homelands', page: 4}, should_parse_using(parser.set, done)

  it 'errors without requesting or parsing if you ask for a too-low page', (done) ->
    # note that only the parser can know if a page is too high
    gatherer.set {name: 'Whatever', page: 0}, (err, set) ->
      err.message.should.eql 'Page must be a positive number'
      parser.set.called.should.be.false
      site.done()
      done()

describe '.languages', ->
  beforeEach ->
    @parser_stub = sinon.stub parser, 'language', (body, callback) ->
      callback(null, fake_object)

  afterEach ->
    @parser_stub.restore()

  it_can_request_and_parse_a_cards_languages_using id_only
  it_can_request_and_parse_a_cards_languages_using name_only
  it_can_request_and_parse_a_cards_languages_using name_and_id
  it_can_request_and_parse_a_cards_languages_using 'a name'
  it_can_request_and_parse_a_cards_languages_using 10

  it 'recognizes redirects as a not-found error', (done) ->
    mock_redirect language_route(id_only)

    gatherer.languages id_only, (error, data) ->
      error.message.should.eql 'Card Not Found'
      parser.language.called.should.be.false
      site.done()
      done()

describe '.index', ->
  beforeEach ->
    sets_stub = sinon.stub parser, 'sets', (body, callback) ->
      callback null, 'a list of sets'
    formats_stub = sinon.stub parser, 'formats', (body, callback) ->
      callback null, 'a list of formats'
    types_stub = sinon.stub parser, 'types', (body, callback) ->
      callback null, 'a list of types'
    @stubs = [sets_stub, formats_stub, types_stub]

  afterEach ->
    for stub in @stubs
      stub.calledOnce.should.be.true
      stub.restore()

  it 'builds an object using parset.sets, .formats, and .types', (done) ->
    mock_route '/Pages/'

    gatherer.index (err, lists) ->
      lists.sets.should.eql 'a list of sets'
      lists.formats.should.eql 'a list of formats'
      lists.types.should.eql 'a list of types'
      site.done()
      done()


describe 'Deprecated API', ->
  describe '.fetch_card', ->
    before ->
      # stub the parser
      @old_parse_function = parser.card
      parser.card = (body, callback, options ={}) ->
        body.should.equal fake_page
        callback(null, fake_object)
      # make a helper
      @fetch_card_should_yield = (expectedValue, done) ->
        gatherer.fetch_card.call @context, (err, data) ->
          data.should.eql expectedValue
          site.isDone().should.be.true
          done()

    after ->
      # restore the parser
      parser.card = @old_parse_function

    describe 'in a context that has a params property which has a name property', ->
      before ->
        @context = {params: name_only, query: {}}

      it 'gets and parses the named gatherer page', (done) ->
        mock_card_route @context.params

        @fetch_card_should_yield fake_object, done

      it 'passes back errors', (done) ->
        site.get(card_route(@context.params))
          .reply(404)

        @fetch_card_should_yield err_404, done

    describe 'in a context with a params property which is an array', ->

      describe 'whose first element is a number', ->

        before ->
          @context = {params: [id_only.id], query: {}}

        it 'parses the gatherer page for that id', (done) ->
          mock_card_route id_only.id

          @fetch_card_should_yield fake_object, done

      describe 'whose first element is a number and whose second element is a string', ->

        before ->
          @context = {params: [1, 'apart'], query: {}}

        it 'parses the gatherer page for that id and part name', (done) ->
          mock_route "/Pages/Card/Details.aspx?multiverseid=#{@context.params[0]}&part=#{@context.params[1]}"

          @fetch_card_should_yield fake_object, done

  describe '.fetch_set', ->

    before ->
      # stub the parser
      @old_parse_function = parser.set
      parser.set = (body, callback) ->
        body.should.equal fake_page
        callback(null, fake_object)
      # make a helper
      @fetch_set_should_yield = (expectedValue, done) ->
        gatherer.fetch_set.call @context, (err, data) ->
          data.should.eql expectedValue
          site.isDone().should.be.true
          done()
    after ->
      # restore the parser
      parser.set = @old_parse_function

    describe 'when called in a context with a name parameter', ->

      before ->
        @context = {params: {name: 'Homelands'}, query: {}}

      it 'requests the first page of the set', (done)->
        site.get(set_route + '?set=[%22Homelands%22]&page=0')
          .reply(200, fake_page)

        @fetch_set_should_yield fake_object, done

      describe 'and a page parameter', ->

        before ->
          @context = {params: {name: 'Homelands', page: 2}, query: {}}

        it 'requests the specified page of the set', (done)->
          # pages are zero-indexed, so 1 is the second page
          site.get(set_route + '?set=[%22Homelands%22]&page=1')
            .reply(200, fake_page)

          @fetch_set_should_yield fake_object, done

  describe '.fetch_language', ->
    before ->
      # stub the parser
      @old_parse_function = parser.language
      parser.language = (body, callback, options ={}) ->
        body.should.equal fake_page
        callback(null, fake_object)
      # make a helper
      @fetch_language_should_yield = (expectedValue, done) ->
        gatherer.fetch_language.call @context, (err, data) ->
          data.should.eql expectedValue
          site.isDone().should.be.true
          done()

    after ->
      # restore the parser
      parser.language = @old_parse_function

    describe 'in a context that has a params property which has a name property', ->
      before ->
        @context = {params: {name: 'Forest'}, query: {}}

      it 'gets and parses the named gatherer page', (done) ->
        mock_language_route @context.params

        @fetch_language_should_yield fake_object, done

      it 'passes back errors', (done) ->
        site.get(language_route(@context.params))
          .reply(404)

        @fetch_language_should_yield err_404, done

    describe 'in a context with a params property which is an array', ->

      describe 'whose first element is a number', ->

        before ->
          @context = {params: [1], query: {}}

        it 'parses the gatherer page for that id', (done) ->
          mock_language_route @context.params[0]

          @fetch_language_should_yield fake_object, done

      describe 'whose first element is a number and whose second element is a string', ->

        before ->
          @context = {params: [1, 'apart'], query: {}}

        it 'parses the gatherer page for that id and part name', (done) ->
          mock_language_route {id: @context.params[0], part: @context.params[1]}

          @fetch_language_should_yield fake_object, done

  describe '.sets', ->
    before ->
      @real_parse_function = parser.sets
      parser.sets = (body, callback) ->
        body.should.eql fake_page
        callback null, fake_object

    after ->
      parser.sets = @real_parse_function

    it "parses the appropriate section of gatherer's main page", (done) ->
      site.get('/Pages/').reply(200, fake_page)

      gatherer.sets (err, data) ->
        data.should.eql fake_object
        site.isDone().should.be.true
        done()

  describe '.formats', ->
    before ->
      @real_parse_function = parser.formats
      parser.formats = (body, callback) ->
        body.should.eql fake_page
        callback null, fake_object

    after ->
      parser.formats = @real_parse_function

    it "parses the appropriate section of gatherer's main page", (done) ->
      site.get('/Pages/').reply(200, fake_page)

      gatherer.formats (err, data) ->
        data.should.eql fake_object
        site.isDone().should.be.true
        done()

  describe '.types', ->
    before ->
      @real_parse_function = parser.types
      parser.types = (body, callback) ->
        body.should.eql fake_page
        callback null, fake_object

    after ->
      parser.types = @real_parse_function

    it "parses the appropriate section of gatherer's main page", (done) ->
      site.get('/Pages/').reply(200, fake_page)

      gatherer.types (err, data) ->
        data.should.eql fake_object
        site.isDone().should.be.true
        done()
