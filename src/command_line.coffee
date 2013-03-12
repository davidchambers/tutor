tutor = require './tutor'
formatters = require './formatters'

program = require 'commander'

program.version require('../package').version

program
  .command('card <name>')
  .description('prints the information for a named card')
  .action (name) ->
    tutor.card {name}, formatters.card

program
  .command('id <id>')
  .description('prints the information found for a card given an id')
  .action (id) ->
    tutor.card {id}, formatters.card

program
  .command('fullcard <name>')
  .description('prints the complete information found for a named card')
  .action (name) ->
    tutor.card {name}, formatters.fullCard

program
  .command('fullid <id>')
  .description('prints the complete information for a card given an id')
  .action (id) ->
    tutor.card {id}, formatters.fullCard

program
  .command("set <name>")
  .description("prints the information for the first page of the named set")
  .option("-p, --page [number]", "specify page of set", 1)
  .action (name, options) ->
    tutor.set {name, page: options.page}, formatters.set

module.exports = program
