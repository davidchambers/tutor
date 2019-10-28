'use strict';

const tutor = require ('..');


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
  if (card.text !== '') {
    output += ' ' + card.text.replace (/[\n\r]+/g, ' ');
  }
  return output;
};

const formats = {
  json,
  summary: withCaution (lines => lines.join ('\n')),
};

const sets = {
  json,
  summary: withCaution (lines => lines.join ('\n')),
};

const types = {
  json,
  summary: withCaution (lines => lines.join ('\n')),
};

const card = {
  json,
  summary: formatCard,
};

const set = {
  json,
  summary: withCaution (lines => (lines.map (formatCard)).join ('\n')),
};

function epipeFilter(err) {
  if (err.code === 'EPIPE') process.exit ();

  if ((process.stdout.listeners ('error')).length <= 1) {
    process.stdout.removeAllListeners ();
    process.stdout.emit ('error', err);
    process.stdout.on ('error', epipeFilter);
  }
}

process.stdout.on ('error', epipeFilter);

const program = require ('commander');

program.version ((require ('../package.json')).version);

program.command ('formats')
       .option ('-f, --format [formatter]', '"json" or "summary"', 'summary')
       .action (options => tutor.formats (formats[options.format]));

program.command ('sets')
       .option ('-f, --format [formatter]', '"json" or "summary"', 'summary')
       .action (options => tutor.sets (sets[options.format]));

program.command ('types')
       .option ('-f, --format [formatter]', '"json" or "summary"', 'summary')
       .action (options => tutor.types (types[options.format]));

program.command ('card <name|id>')
       .description ("output the given card's details")
       .option ('-f, --format [formatter]', '"json" or "summary"', 'summary')
       .action ((x, options) =>
                  tutor.card (Number.isNaN (Number (x)) ? x : Number (x))
                  .then (card[options.format]));

program.command ('set <name>')
       .description ('output one page of cards from the named set')
       .option ('-f, --format [formatter]', '"json" or "summary"', 'summary')
       .action ((name, options) => tutor.set (name, set[options.format]));

module.exports = program;
