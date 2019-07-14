'use strict';

const formatters = require ('./formatters');
const tutor = require ('..');


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

['formats', 'sets', 'types'].forEach (res => {
  program.command (res)
         .option ('-f, --format [formatter]', '"json" or "summary"', 'summary')
         .action (options => tutor[res] (formatters[res][options.format]));
});

program.command ('card <name|id>')
       .description ("output the given card's details")
       .option ('-f, --format [formatter]', '"json" or "summary"', 'summary')
       .action ((x, options) =>
                  tutor.card (Number.isNaN (Number (x)) ? x : Number (x))
                  .then (formatters.card[options.format]));

program.command ('set <name>')
       .description ('output one page of cards from the named set')
       .option ('-f, --format [formatter]', '"json" or "summary"', 'summary')
       .action ((name, options) =>
                  tutor.set (name, formatters.set[options.format]));

module.exports = program;
