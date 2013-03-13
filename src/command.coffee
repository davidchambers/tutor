formatters = require './formatters'
tutor      = require './tutor'


# pipe handling, stolen with permission from 'epipebomb'
# by michael.hart.au@gmail.com
epipeFilter = (err) ->
  process.exit() if err.code is 'EPIPE'

  # If there's more than one error handler (ie, us),
  # then the error won't be bubbled up anyway
  if process.stdout.listeners('error').length <= 1
    process.stdout.removeAllListeners()    # Pretend we were never here
    process.stdout.emit 'error', err       # Then emit as if we were never here
    process.stdout.on 'error', epipeFilter # Then reattach, ready for the next error!

process.stdout.on 'error', epipeFilter

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
  .command('set <name>')
  .description('output one page of cards from the named set')
  .option('-p, --page [number]', 'specify page number', 1)
  .action (name, options) ->
    tutor.set {name, page: options.page}, formatters.set

module.exports = program
