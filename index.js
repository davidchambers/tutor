'use strict';

const entities = require ('entities');

const gatherer = require ('./lib/gatherer');
const U = require ('./lib/util');


const tutor = module.exports;

tutor.set = gatherer.set;

const collect_options = label => () =>
  gatherer.request (gatherer.origin + '/Pages/Default.aspx')
  .then (U.T ('#ctl00_ctl00_MainContent_Content_SearchControls_' +
              label +
              'AddText'))
  .then (U.children)
  .then (U.map (U.attr ('value')))
  .then (U.map (entities.decode));

//    formats :: () -> Promise ???
tutor.formats = collect_options ('format');

//    sets :: () -> Promise ???
tutor.sets = collect_options ('set');

//    types :: () -> Promise ???
tutor.types = collect_options ('type');

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
