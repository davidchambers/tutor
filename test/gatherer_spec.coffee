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

fake_page = 'totally html, i swear'
fake_card = {name: 'Forest', id: 5, part: 'Trees', cost: 'Free', expansion: 'all of them'}
fake_set = {page:'1', cards: {}}
fake_language_set = {}
fake_list = [1,2,3]

site = nock('http://gatherer.wizards.com')
card_route = '/Pages/Card/Details.aspx'
set_route = '/Pages/Search/Default.aspx'
language_route = '/Pages/Card/Languages.aspx'

mock_route = (route) ->
  site.get(route).reply(200, fake_page)
mock_card_route = (query_string) ->
  mock_route card_route + query_string
mock_id_route = () -> mock_card_route '?multiverseid=' + fake_card.id
mock_name_route = () -> mock_card_route '?name=' + fake_card.name


describe '.card', ->
  beforeEach ->
    # helpers
    @should_work = (done) ->
      (error, card) ->
        site.done()
        card.should.eql fake_card
        done()
    @parser_stub = sinon.stub parser, 'card', (body, callback) ->
      body.should.equal fake_page
      callback(null, fake_card)

  afterEach ->
    @parser_stub.restore()

  it 'recognizes redirects as a not-found error', (done) ->
    site.get(card_route + '?multiverseid=' + fake_card.id)
      .reply(302, fake_page)
    
    gatherer.card fake_card.id, (error, card) ->
      error.message.should.eql 'Card Not Found'
      site.done()
      done()

  describe 'success', ->
    
    afterEach ->
      @parser_stub.withArgs(fake_page).calledOnce.should.be.true

    it 'fetches cards based on id', (done) ->
      mock_id_route()

      gatherer.card {id: fake_card.id}, @should_work(done)

    it 'fetches cards based on name', (done) ->
      mock_name_route()

      gatherer.card {name: fake_card.name}, @should_work(done)

    it 'prioritizes id when both name and id are given', (done) ->
      mock_id_route()

      gatherer.card {name: fake_card.name, id: fake_card.id}, @should_work(done)

    it 'fetches cards with an id and a part', (done) ->
      mock_card_route "?multiverseid=#{fake_card.id}&part=#{fake_card.part}"

      gatherer.card {id: fake_card.id, part: fake_card.part}, @should_work(done)

    it 'treats a straight string argument as a name', (done) ->
      mock_name_route()

      gatherer.card fake_card.name, @should_work(done)

    it 'treats a straight integer argument as an id', (done) ->
      mock_id_route()

      gatherer.card fake_card.id, @should_work(done)

    describe 'with optional arguments', ->

      it 'can get the printed text of a card', (done) ->
        mock_card_route '?multiverseid=' + fake_card.id + '&printed=true'

        gatherer.card {id: fake_card.id, printed: true}, @should_work(done)

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
        callback(null, fake_card)
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
        @context = {params: {name: fake_card.name}, query: {}}

      it 'gets and parses the named gatherer page', (done) ->
        mock_name_route()

        @fetch_card_should_yield fake_card, done

      it 'passes back errors', (done) ->
        site.get(card_route + '?name=' + @context.params.name)
          .reply(404)

        @fetch_card_should_yield err_404, done

    describe 'in a context with a params property which is an array', ->

      describe 'whose first element is a number', ->

        before ->
          @context = {params: [fake_card.id], query: {}}

        it 'parses the gatherer page for that id', (done) ->
          mock_id_route()

          @fetch_card_should_yield fake_card, done

      describe 'whose first element is a number and whose second element is a string', ->

        before ->
          @context = {params: [1, 'apart'], query: {}}

        it 'parses the gatherer page for that id and part name', (done) ->
          mock_card_route "?multiverseid=#{@context.params[0]}&part=#{@context.params[1]}"

          @fetch_card_should_yield fake_card, done

  describe '.fetch_set', ->

    before ->
      # stub the parser
      @old_parse_function = parser.set
      parser.set = (body, callback) ->
        body.should.equal fake_page
        callback(null, fake_set)
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

        @fetch_set_should_yield fake_set, done

      describe 'and a page parameter', ->

        before ->
          @context = {params: {name: 'Homelands', page: 2}, query: {}}

        it 'requests the specified page of the set', (done)->
          # pages are zero-indexed, so 1 is the second page
          site.get(set_route + '?set=[%22Homelands%22]&page=1')
            .reply(200, fake_page)

          @fetch_set_should_yield fake_set, done

  describe '.fetch_language', ->
    before ->
      # stub the parser
      @old_parse_function = parser.language
      parser.language = (body, callback, options ={}) ->
        body.should.equal fake_page
        callback(null, fake_language_set)
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
        site.get(language_route + '?name=' + @context.params.name)
          .reply(200, fake_page)

          @fetch_language_should_yield fake_language_set, done

      it 'passes back errors', (done) ->
        site.get(language_route + '?name=' + @context.params.name)
          .reply(404)

        @fetch_language_should_yield err_404, done

    describe 'in a context with a params property which is an array', ->

      describe 'whose first element is a number', ->

        before ->
          @context = {params: [1], query: {}}

        it 'parses the gatherer page for that id', (done) ->
          site.get(language_route + '?multiverseid=' + @context.params[0])
            .reply(200, fake_page)

          @fetch_language_should_yield fake_language_set, done

      describe 'whose first element is a number and whose second element is a string', ->

        before ->
          @context = {params: [1, 'apart'], query: {}}

        it 'parses the gatherer page for that id and part name', (done) ->
          site.get(language_route + "?multiverseid=#{@context.params[0]}&part=#{@context.params[1]}")
            .reply(200, fake_page)

          @fetch_language_should_yield fake_language_set, done

  describe '.sets', ->
    before ->
      @real_parse_function = parser.sets
      parser.sets = (body, callback) ->
        body.should.eql fake_page
        callback null, fake_list

    after ->
      parser.sets = @real_parse_function

    it "parses the appropriate section of gatherer's main page", (done) ->
      site.get('/Pages/').reply(200, fake_page)

      gatherer.sets (err, data) ->
        data.should.eql fake_list
        site.isDone().should.be.true
        done()

  describe '.formats', ->
    before ->
      @real_parse_function = parser.formats
      parser.formats = (body, callback) ->
        body.should.eql fake_page
        callback null, fake_list

    after ->
      parser.formats = @real_parse_function

    it "parses the appropriate section of gatherer's main page", (done) ->
      site.get('/Pages/').reply(200, fake_page)

      gatherer.formats (err, data) ->
        data.should.eql fake_list
        site.isDone().should.be.true
        done()

  describe '.types', ->
    before ->
      @real_parse_function = parser.types
      parser.types = (body, callback) ->
        body.should.eql fake_page
        callback null, fake_list

    after ->
      parser.types = @real_parse_function

    it "parses the appropriate section of gatherer's main page", (done) ->
      site.get('/Pages/').reply(200, fake_page)

      gatherer.types (err, data) ->
        data.should.eql fake_list
        site.isDone().should.be.true
        done()
