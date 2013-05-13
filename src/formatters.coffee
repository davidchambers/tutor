withCaution = (view) -> (err, res) ->
  if err is null
    view res
  else if err.errno is 'ENOTFOUND'
    console.error 'cannot connect to gatherer'
  else
    console.error "#{err}"

printCard = (card) ->
  output  = "#{card.name}"
  output += " #{card.mana_cost}" if 'mana_cost' of card
  output += " #{card.power}/#{card.toughness}" if 'power' of card
  output += " #{card.text.replace(/[\n\r]+/g, ' ')}" if card.text
  console.log output

printSet = (cards) ->
  printCard card for card in cards

module.exports =
  card:
    json: withCaution (card) -> console.log JSON.stringify card
    summary: withCaution printCard
  set:
    json: withCaution (cards) -> console.log JSON.stringify cards
    summary: withCaution printSet
