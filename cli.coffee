gatherer = require './gatherer'
mustache = require 'mustache'

template = """{{name}}\t\t{{mana_cost}}
{{typeline}}\t\t{{#power}}({{power}}/{{toughness}}){{/power}}
{{{text}}}{{#expansion}}
{{expansion}} {{rarity}}{{/expansion}}"""

build_typeline = ->
  base = @types.join(' ')
  if @subtypes.length > 0
    base += ' - ' + @subtypes.join(' ')
  base

exports.run = (params, api = gatherer) -> 
  if /^\d+$/.test params[0]
    fetch_params = {id: params[0]}
  else
    fetch_params = {name: params.join ' '}

  api.fetch_card fetch_params, (err, data) ->
    data.typeline = -> build_typeline  
    console.log mustache.render(template, data)