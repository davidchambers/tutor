'use strict';

const gatherer = require ('./lib/gatherer');
const U = require ('./lib/util');


const tutor = module.exports;

tutor.formats = gatherer.formats;
tutor.set = gatherer.set;
tutor.sets = gatherer.sets;
tutor.types = gatherer.types;

tutor.card = function recur(spec) {
  const details = typeof spec === 'number' ? {id: spec} :
                  typeof spec === 'string' ? {name: spec} :
                                             spec;
  return Promise.all ([
    gatherer.card (details),
    gatherer.languages (details),
    gatherer.printings (details),
  ])
  .then (([card, languages, {legality, versions}]) =>
    // If card.name and details.name differ, requests were redirected
    // (e.g. "Juzam Djinn" => "Juzám Djinn"). Resend requests with the
    // correct name to get languages, legality, and versions.
    'name' in details && card.name !== details.name ?
    recur (Object.assign ({}, details, {name: card.name})) :
    Promise.resolve (Object.assign ({languages, legality, versions}, card))
  )
};
