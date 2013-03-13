(function() {
  var assert, formatters, program, tutor;

  tutor = require('./tutor');

  formatters = require('./formatters');

  program = require('commander');

  assert = require('assert');

  program.version(require('../package').version);

  program.command('card <name|id>').description('prints the information for a card based on name or id (if provided an integer number, id is assumed)').option('-f, --format [formatter]', 'Use this output format. Options are: summary (default), json', 'summary').option('--id', 'if set, interpret argument as the gatherer id', false).option('--name', 'if set, interpret argument as the card name', false).action(function(name, options) {
    var formatMap, id;
    formatMap = {
      summary: formatters.cardSummary,
      json: formatters.cardJson
    };
    if (options.id && options.name) {
      throw "don't specify that we should search by both name AND id";
    }
    if (options.id || (!options.name && /^\d+$/.test(name))) {
      id = name;
      return tutor.card({
        id: id
      }, formatMap[options.format]);
    } else {
      return tutor.card({
        name: name
      }, formatMap[options.format]);
    }
  });

  program.command("set <name>").description("prints the information for the first page of the named set").option("-p, --page [number]", "specify page of set", 1).action(function(name, options) {
    return tutor.set({
      name: name,
      page: options.page
    }, formatters.set);
  });

  module.exports = program;

}).call(this);
