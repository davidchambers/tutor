<img alt="Tutor" src="https://raw.github.com/davidchambers/tutor/master/logo@2x.png" width="852" height="215" />

[Gatherer][1] is the canonical source for _Magic: The Gathering_ card details.
While useful, it lacks an interface for retrieving this data programmatically.
The lack of an API makes creating _Magic_-related applications unnecessarily
difficult.

Tutor is a simple JavaScript interface for Gatherer.

### API

  - [tutor.card](#tutorcard)
  - [tutor.set](#tutorset)
  - [tutor.formats](#tutorformats)
  - [tutor.sets](#tutorsets)
  - [tutor.types](#tutortypes)

### tutor.card

    tutor.card(id, callback(err, card))
    tutor.card(name, callback(err, card))
    tutor.card(details, callback(err, card))

The first and second forms are shorthand for `tutor.card({id: id}, ...)` and
`tutor.card({name: name}, ...)` respectively. The callback is passed an object
representing the specified card. Version-specific metadata such as flavor text
and rarity are included for cards specified by id. Attributes not applicable
to the card type (e.g. lands have no mana cost) or not present (e.g. certain
creatures have no rules text) are omitted.

```coffeescript
tutor.card 'Demonic Tutor', (err, card) ->
  console.log card.name
  # => "Demonic Tutor"
  console.log card.mana_cost
  # => "{1}{B}"
  console.log card.text
  # => "Search your library for a card and put that card into your hand. Then shuffle your library."
```

#### Split cards

Because the two sides of a split card share a Gatherer id, it's necessary to
provide the name of the desired side:

```coffeescript
tutor.card id: 27165, name: 'Fire', (err, card) ->
  console.log card.name
  # => "Fire"

tutor.card id: 27165, name: 'Ice', (err, card) ->
  console.log card.name
  # => "Ice"
```

Retrieving either side of a split card by name is straightforward:

```coffeescript
tutor.card 'Fire', (err, card) ->
  console.log card.name
  # => "Fire"

tutor.card 'Ice', (err, card) ->
  console.log card.name
  # => "Ice"
```

#### Flip cards

Retrieving the top half of a flip card by id is straightforward:

```coffeescript
tutor.card 247175, (err, card) ->
  console.log card.name
  # => "Nezumi Graverobber"
```

Either half of a flip card can be retrieved explicitly by setting `which` to
`"a"` (for the upper half) or `"b"` (for the lower half):

```coffeescript
tutor.card id: 247175, which: 'b', (err, card) ->
  console.log card.name
  # => "Nighteyes the Desecrator"
```

When retrieving a flip card by name rather than id, one may simply provide the
name of the desired half:

```coffeescript
tutor.card 'Nighteyes the Desecrator', (err, card) ->
  console.log card.name
  # => "Nighteyes the Desecrator"
```

#### Double-faced cards

Either face of a double-faced card can be retrieved by id:

```coffeescript
tutor.card 262675, (err, card) ->
  console.log card.name
  # => "Afflicted Deserter"

tutor.card 262698, (err, card) ->
  console.log card.name
  # => "Werewolf Ransacker"
```

Or by name:

```coffeescript
tutor.card 'Afflicted Deserter', (err, card) ->
  console.log card.name
  # => "Afflicted Deserter"

tutor.card 'Werewolf Ransacker', (err, card) ->
  console.log card.name
  # => "Werewolf Ransacker"
```

### tutor.set

    tutor.set(name, callback(err, set))

Scrape cards from the set specified by `name`. For example:

```coffeescript
tutor.set 'Homelands', (err, cards) ->
  console.log cards.length
  # => 115
  console.log Object.keys(cards[0]).sort()
  # => [
  #   "converted_mana_cost",
  #   "expansion",
  #   "gatherer_url",
  #   "image_url",
  #   "mana_cost",
  #   "name",
  #   "power",
  #   "rarity",
  #   "subtypes",
  #   "supertypes",
  #   "text",
  #   "toughness",
  #   "types",
  #   "versions"
  # ]
```

### tutor.formats

    tutor.formats(callback(err, formatNames))

Provides the names of all the game's formats:

```coffeescript
tutor.formats (err, formatNames) ->
  console.log formatNames
  # => [
  #   "Classic",
  #   "Commander",
  #   ...
  #   "Vintage",
  #   "Zendikar Block"
  # ]
```

### tutor.sets

    tutor.sets(callback(err, setNames))

Provides the names of all the game's sets:

```coffeescript
tutor.sets (err, setNames) ->
  console.log setNames
  # => [
  #   "Alara Reborn",
  #   "Alliances",
  #   ...
  #   "Worldwake",
  #   "Zendikar"
  # ]
```

### tutor.types

    tutor.types(callback(err, types))

Provides the names of all the game's types:

```coffeescript
tutor.types (err, types) ->
  console.log types
  # => [
  #   "Artifact",
  #   "Basic",
  #   ...
  #   "Vanguard",
  #   "World"
  # ]
```

### CLI

`npm install tutor --global` will make the `tutor` command available globally.

    $ tutor card 'Demonic Tutor'
    Demonic Tutor {1}{B} Search your library for a card and put that card into your hand. Then shuffle your library.

    $ tutor card 'Demonic Tutor' --format json | python -mjson.tool | head -n 10
    {
        "community_rating": {
            "rating": 4.714,
            "votes": 229
        },
        "converted_mana_cost": 2,
        "languages": {},
        "legality": {
            "Commander": "Legal",
            "Legacy": "Banned",

    $ tutor card 60 --format json | python -mjson.tool | head -n 10
    {
        "artist": "Douglas Schuler",
        "community_rating": {
            "rating": 4.917,
            "votes": 109
        },
        "converted_mana_cost": 2,
        "expansion": "Limited Edition Alpha",
        "languages": {},
        "legality": {

    $ tutor set Alliances | head -n 2
    Aesthir Glider {3} 2/1 Flying Aesthir Glider can't block.
    Agent of Stromgald {R} 1/1 {R}: Add {B} to your mana pool.

### Running the tests

    make fixtures
    make test
    make testcli


[1]: http://gatherer.wizards.com/
