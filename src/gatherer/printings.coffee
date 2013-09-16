gatherer  = require '../gatherer'
load      = require '../load'


module.exports = (details, callback) ->
  gatherer.request gatherer.card.url('Printings.aspx', details), (err, res, body) ->
    if err then callback err else callback null, extract body
  return

iter = (row, fn) ->
  while row.hasClass 'cardItem'
    fn row, row.children().map -> gatherer._get_text this
    break if row.next() is row
    row = row.next()

extract = (html) ->
  $ = load html
  data =
    legality: {}
    versions: {}

  prefix = '#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent'

  iter $("#{prefix}_PrintingsList_listRepeater_ctl00_cardTitle").parent().parent(),
    (row, [name, symbol, expansion, block]) ->
      [id] = /\d+$/.exec row.find('a').attr('href')
      [match, rarity] = /[(](.+)[)]/.exec row.find('img').attr('alt')
      data.versions[id] = {expansion, rarity}

  iter $("#{prefix}_LegalityList_listRepeater_ctl00_ConditionTableData").parent(),
    (row, [format, legality, conditions]) ->
      data.legality[format] =
        if legality is 'Special' then "#{legality}: #{conditions}" else legality

  data
