tutor = require './tutor'
formatters = require './formatters'

program = require 'commander'
assert = require 'assert'

program.version require('../package').version

program
  .command('card <name|id>')
  .description('prints the information for a card based on name or id (if provided an integer number, id is assumed)')
  .option('-f, --format [formatter]', 'Use this output format. Options are: summary (default), json', 'summary')
  .option('--id', 'if set, interpret argument as the gatherer id', false)
  .option('--name', 'if set, interpret argument as the card name', false)
  .action (name, options) ->
    formatMap =
      summary: formatters.cardSummary
      json: formatters.cardJson

    if options.id and options.name
      throw "don't specify that we should search by both name AND id"

    if options.id or (not options.name and /^\d+$/.test(name))
      id = name
      tutor.card {id}, formatMap[options.format]
    else
      tutor.card {name}, formatMap[options.format]

program
  .command("set <name>")
  .description("prints the information for the first page of the named set")
  .option("-p, --page [number]", "specify page of set", 1)
  .action (name, options) ->
    tutor.set {name, page: options.page}, formatters.set

module.exports = program
