(function() {
  var formatters, program, tutor;

  tutor = require('./tutor');

  formatters = require('./formatters');

  program = require('commander');

  program.version(require('../package').version);

  program.command('card <name>').description('prints the information for a named card').action(function(name) {
    return tutor.card({
      name: name
    }, formatters.card);
  });

  program.command("set <name>").description("prints the information for the first page of the named set").option("-p, --page [number]", "specify page of set", 1).action(function(name, options) {
    return tutor.set({
      name: name,
      page: options.page
    }, formatters.set);
  });

  module.exports = program;

}).call(this);
