gatherer  = require '../gatherer'
load      = require '../load'
request   = require '../request'


module.exports = (details, callback) ->
  url = gatherer.card.url 'Printings.aspx', details
  request {url, followRedirect: no}, (err, res, body) ->
    err ?= new Error 'unexpected status code' unless res.statusCode is 200
    if err then callback err else callback null, extract body
  return

extract = (html) ->
  $ = load html
  row = $('#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent' +
          '_LegalityList_listRepeater_ctl00_ConditionTableData').parent()
  data = legality: {}
  while row.length
    [format, legality, conditions] = row.children().map -> gatherer._get_text this
    if legality is 'Special'
      legality += ": #{conditions}"
    data.legality[format] = legality
    break if row.next() is row
    row = row.next()
  data
