tutor      = require './tutor'
formatters = require './formatters'

# pipe handling, stolen with permission from 'epipebomb'
# by michael.hart.au@gmail.com
epipeFilter = (err) ->
  process.exit() if err.code == 'EPIPE'

  # If there's more than one error handler (ie, us),
  # then the error won't be bubbled up anyway
  if process.stdout.listeners('error').length <= 1
    process.stdout.removeAllListeners()    # Pretend we were never here
    process.stdout.emit 'error', err       # Then emit as if we were never here
    process.stdout.on 'error', epipeFilter # Then reattach, ready for the next error!

process.stdout.on('error', epipeFilter)

program = require 'commander'

program.version require('../package').version

program
  .command('card <name>')
  .description('prints the information for a named card')
  .action (name) ->
    tutor.card {name}, formatters.card

program
  .command("set <name>")
  .description("prints the information for the first page of the named set")
  .option("-p, --page [number]", "specify page of set", 1)
  .action (name, options) ->
    tutor.set {name, page: options.page}, formatters.set

module.exports = program
