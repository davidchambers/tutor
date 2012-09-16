fs = require 'fs'


task 'lint', 'detect formatting inconsistencies', ->
  # Ensure that card attributes are consistently ordered.
  names = []
  found = no
  for line in fs.readFileSync('./README.markdown', 'utf8').split('\n')
    found or= line is '## Attributes'
    continue unless found
    if match = /- `(.+)`$/.exec line then names.push match[1]
    else break if names.length

  attrs = {}
  attrs[name] = idx for name, idx in names

  p = './test/fixtures/cards'
  for path in ("#{p}/#{n}" for n in fs.readdirSync p when /[.]coffee$/.test n)
    idx = -1
    text = fs.readFileSync(path, 'utf8').replace(/[\s\S]*^response:/m, '')
    for line in text.split('\n') when match = /^[ ]{0,4}(\w+):/.exec line
      if (name = match[1]) of attrs
        unless idx < idx = attrs[name]
          console.warn "#{path} - attribute out of order (#{name})"
