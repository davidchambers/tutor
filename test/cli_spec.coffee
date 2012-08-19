should   = require 'should'
sinon = require 'sinon'

cli = require '../cli'

describe 'Tutor CLI', ->
  describe '.run', ->

    before ->
      this.callback = sinon.spy()
      this.fake_api = {fetch_card: this.callback}

    describe 'when given a number', ->
      it 'passes the first parameter gatherer as a card id', ->
        cli.run(['1', 'ignored'], this.fake_api)

        this.callback.calledWith({id: '1'}).should.eql true

    describe 'when given a non-number', ->
      it 'passes all parameters to gatherer as a card name', ->
        cli.run(['param1', 'param2'], this.fake_api)

        this.callback.calledWith({name: 'param1 param2'}).should.eql true