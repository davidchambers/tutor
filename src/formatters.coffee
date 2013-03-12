withCaution = (view) -> (err, res) ->
  if err is null
    view res
  else if err.errno is 'ENOTFOUND'
    console.error 'cannot connect to gatherer'
  else
    console.error "unknown error: #{err}"

printCard = (card) ->
  output  = "#{card.name}"
  output += " #{card.mana_cost}" if 'mana_cost' of card
  output += " #{card.power}/#{card.toughness}" if 'power' of card
  output += " #{card.text.replace(/[\n\r]+/g, ' ')}" if 'text' of card
  console.log output

printFullCard = (card) ->
  console.log JSON.stringify card

printSet = (set) ->
  printCard card for card in set.cards

exports.card     = withCaution printCard
exports.set      = withCaution printSet
exports.fullCard = withCaution printFullCard
