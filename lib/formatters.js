'use strict';

const U = require ('./util');


const withCaution = view => (err, res) => {
  if (err == null) {
    console.log (view (res));
  } else if (err.errno === 'ENOTFOUND') {
    console.error ('cannot connect to gatherer');
    process.exit (1);
  } else {
    console.error (String (err));
    process.exit (1);
  }
};

const json = withCaution (JSON.stringify);

const formatCard = card => {
  let output = card.name;
  if ('mana_cost' in card) {
    output += ' ' + card.mana_cost;
  }
  if ('power' in card) {
    output += ' ' + card.power + '/' + card.toughness;
  }
  if (card.text) {
    output += ' ' + (card.text.replace (/[\n\r]+/g, ' '));
  }
  return output;
};

exports.formats = {
  json,
  summary: withCaution (U.joinWith ('\n')),
};

exports.sets = {
  json,
  summary: withCaution (U.joinWith ('\n')),
};

exports.types = {
  json,
  summary: withCaution (U.joinWith ('\n')),
};

exports.card = {
  json,
  summary: formatCard,
};

exports.set = {
  json,
  summary: withCaution (U.pipe ([U.map (formatCard), U.joinWith ('\n')])),
};
