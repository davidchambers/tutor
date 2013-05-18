gatherer  = require './gatherer'


tutor = module.exports

tutor[name] = gatherer[name] for name in [
  'formats'
  'set'
  'sets'
  'types'
]

tutor.card = (details, callback) ->
  switch typeof details
    when 'number' then details = id: details
    when 'string' then details = name: details

  card = languages = legality = versions = null
  get = (success) -> (err, data) ->
    if err
      callback err
      callback = ->
      return
    success data
    if card? and languages? and legality? and versions?
      card.languages = languages
      card.legality = legality
      card.versions = versions
      callback null, card

  gatherer.card details, get (data) -> card = data
  gatherer.languages details, get (data) -> languages = data
  gatherer.printings details, get (data) -> {legality, versions} = data
