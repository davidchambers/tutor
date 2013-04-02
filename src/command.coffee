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

program.version require('../package').version

program
  .command('card <name|id>')
  .description("output the given card's details")
  .option('-f, --format [formatter]', 'Use this output format. Options are: summary (default), json', 'summary')
  .action (name, options) ->

    if /^\d+$/.test(name)
      id = name
      tutor.card {id}, formatters.card[options.format]
    else
      tutor.card {name}, formatters.card[options.format]

program
  .command('set <name>')
  .description('output one page of cards from the named set')
  .option('-p, --page [number]', 'specify page number', 1)
  .action (name, options) ->
    tutor.set {name, page: options.page}, formatters.set

module.exports = program
