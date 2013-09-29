withCaution = (view) -> (err, res) ->
  if err is null
    console.log view res
    process.exit 0
  else if err.errno is 'ENOTFOUND'
    console.error 'cannot connect to gatherer'
    process.exit 1
  else
    console.error "#{err}"
    process.exit 1

join = (array) -> array.join('\n')

formatCard = (card) ->
  output  = "#{card.name}"
  output += " #{card.mana_cost}" if 'mana_cost' of card
  output += " #{card.power}/#{card.toughness}" if 'power' of card
  output += " #{card.text.replace(/[\n\r]+/g, ' ')}" if card.text
  output

exportFormatter = (name, formatter) ->
  module.exports[name] =
    json: withCaution JSON.stringify
    summary: withCaution formatter

exportFormatter 'formats', join
exportFormatter 'sets', join
exportFormatter 'types', join
exportFormatter 'card', formatCard
exportFormatter 'set', (cards) -> join cards.map formatCard
