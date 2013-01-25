withCaution = (view) ->
  (error, response) ->
    if error
      if error.errno is "ENOTFOUND"
        console.log "cannot connect to gatherer"
      else
        console.log "unknown error: #{error}"
    else
      view response

printCard = (card) ->
  output = "#{card.name}"
  
  output += " #{card.mana_cost}" if 'mana_cost' of card
  output += " #{card.power}/#{card.toughness}" if 'power' of card
  output += " #{card.text.replace(/[\n\r]/g, " ")}" if 'text' of card

  console.log output
  return

printSet = (set) ->
  printCard card for card in set.cards

exports.card = withCaution(printCard)
exports.set  = withCaution(printSet)
