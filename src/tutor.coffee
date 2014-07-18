Q         = require 'q'
_         = require 'underscore'

gatherer  = require './gatherer'


tutor = module.exports

tutor[name] = gatherer[name] for name in [
  'formats'
  'set'
  'sets'
  'types'
]

pending = {}

tutor.card = (details, callback) ->
  switch
    when _.isNumber details then details = id: details
    when _.isString details then details = name: details

  Q.all _.map [gatherer.card, gatherer.languages, gatherer.printings], (fn) ->
    deferred = Q.defer()
    fn details, deferred.makeNodeResolver()
    deferred.promise
  .then ([card, languages, {legality, versions}]) ->
    # If card.name and details.name differ, requests were redirected
    # (e.g. "Juzam Djinn" => "Juzám Djinn"). Resend requests with the
    # correct name to get languages, legality, and versions.
    if 'name' of details and card.name isnt details.name
      tutor.card _.extend(_.omit(details, 'name'),
                          _.pick(card, 'name')), callback
      # Prevent double callback invocation.
      pending
    else
      _.extend {languages, legality, versions}, card
  .done(
    (value) -> callback null, value unless value is pending
    callback
  )
