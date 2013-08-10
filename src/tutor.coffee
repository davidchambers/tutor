Q         = require 'q'

gatherer  = require './gatherer'


tutor = module.exports

tutor[name] = gatherer[name] for name in [
  'formats'
  'set'
  'sets'
  'types'
]

tutor.card = (details, callback) ->
  switch Object::toString.call details
    when '[object Number]' then details = id: details
    when '[object String]' then details = name: details

  d1 = Q.defer()
  gatherer.card details, d1.makeNodeResolver()

  d2 = Q.defer()
  gatherer.languages details, d2.makeNodeResolver()

  d3 = Q.defer()
  gatherer.printings details, d3.makeNodeResolver()

  Q.all([d1.promise, d2.promise, d3.promise])
  .then(([card, languages, {legality, versions}]) ->
    card.languages = languages
    card.legality = legality
    card.versions = versions
    callback null, card
  )
  .catch(callback)
