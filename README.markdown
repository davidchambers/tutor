# mtg-api

[Gatherer][1] is the canonical source for _Magic: The Gathering_ card details.
While useful, it lacks an interface for retrieving this data programmatically.
The lack of an API makes creating _Magic_-related applications unnecessarily
difficult.

mtg-api provides an API for Gatherer. It's a lightweight [Express][2] app that
reads data from Gatherer and returns neatly formatted JSON.

## Starting the app

To run the server:

    :::console
    $ npm install
    $ coffee server.coffee

This starts a server listening on the port set as the environment variable PORT,
or on port 3000 if PORT is undefined.

## `GET /card/:id`

Returns a JSON representation of the card specified (by Gatherer id) in the
request path. The response includes version-specific metadata such as flavor
text and rarity.

    $ curl http://localhost:3000/card/146017 --silent | python -mjson.tool
    {
        "artist": "Trevor Hairsine", 
        "converted_mana_cost": 6, 
        "expansion": "Shadowmoor", 
        "flavor_text": "Gyara Spearhurler would have been renowned for her deadly accuracy, if it weren't for her deadly accuracy.", 
        "gatherer_url": "http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=146017", 
        "mana_cost": "[2/R][2/R][2/R]", 
        "name": "Flame Javelin", 
        "number": 92, 
        "rarity": "Uncommon", 
        "rulings": [
            [
                "2008-05-01", 
                "If an effect reduces the cost to cast a spell by an amount of generic mana, it applies to a monocolored hybrid spell only if you've chosen a method of paying for it that includes generic mana."
            ], 
            [
                "2008-05-01", 
                "A card with a monocolored hybrid mana symbol in its mana cost is each of the colors that appears in its mana cost, regardless of what mana was spent to cast it. Thus, Flame Javelin is red even if you spend six green mana to cast it."
            ], 
            [
                "2008-05-01", 
                "A card with monocolored hybrid mana symbols in its mana cost has a converted mana cost equal to the highest possible cost it could be cast for. Its converted mana cost never changes. Thus, Flame Javelin has a converted mana cost of 6, even if you spend [R][R][R] to cast it."
            ], 
            [
                "2008-05-01", 
                "If a cost includes more than one monocolored hybrid mana symbol, you can choose a different way to pay for each symbol. For example, you can pay for Flame Javelin by spending [R][R][R], [2][R][R], [4][R], or [6]."
            ]
        ], 
        "text": "([2/R] can be paid with any two mana or with [R]. This card's converted mana cost is 6.)\n\nFlame Javelin deals 4 damage to target creature or player.", 
        "type": "Instant", 
        "versions": {
            "146017": {
                "expansion": "Shadowmoor", 
                "rarity": "Uncommon"
            }, 
            "189220": {
                "expansion": "Duel Decks: Jace vs. Chandra", 
                "rarity": "Uncommon"
            }
        }
    }

![Flame Javelin][4]

## `GET /card/:id/:part`

Returns a JSON representation of the specified part of the specified multipart
card. For example, `GET /card/27166/Ice` returns the Ice half of Fire and Ice.

![Fire and Ice][5]

## `GET /card/:name`

Returns a JSON representation of the specified card. The response does *not*
include version-specific metadata such as flavor text and rarity.

    $ curl http://localhost:3000/card/%C3%86ther%20Storm --silent | python -mjson.tool
    {
        "converted_mana_cost": 4, 
        "mana_cost": "[3][U]", 
        "name": "\u00c6ther Storm", 
        "rulings": [
            [
                "2004-10-04", 
                "This does not stop a creature card from being put directly onto the battlefield by a spell or ability."
            ], 
            [
                "2008-08-01", 
                "Affects any spell with the type creature, including those with other types such as artifact or enchantment. This includes older cards with \"summon\" on their type line."
            ]
        ], 
        "text": "Creature spells can't be cast.\n\nPay 4 life: Destroy \u00c6ther Storm. It can't be regenerated. Any player may activate this ability.", 
        "type": "Enchantment", 
        "versions": {
            "184722": {
                "expansion": "Masters Edition II", 
                "rarity": "Uncommon"
            }, 
            "2935": {
                "expansion": "Homelands", 
                "rarity": "Uncommon"
            }, 
            "3891": {
                "expansion": "Fifth Edition", 
                "rarity": "Uncommon"
            }
        }
    }

## Attributes

These attributes may be included in a response:

  - `name`
  - `mana_cost`
  - `converted_mana_cost`
  - `type`
  - `subtype`
  - `text`
  - `flavor_text`
  - `flavor_text_attribution`
  - `color_indicator`
  - `watermark`
  - `power`
  - `toughness`
  - `loyalty`
  - `expansion`
  - `rarity`
  - `number`
  - `artist`
  - `gatherer_url`
  - `versions`
  - `rulings`

Attributes not applicable to the card type (e.g. lands have no mana cost) or
not present (e.g. certain creatures have no rules text) are omitted.

## `GET /set/:name/:page?`

Returns a page of cards (up to 25) from the specified set. The first page of
results is returned if `page` is omitted. Responses contain `page`, `pages`,
and `cards`. For example:

    page: 1
    pages: 5
    cards: [...]

Each card in `cards` contains all applicable attributes among the following:

  - `name`
  - `mana_cost`
  - `converted_mana_cost`
  - `type`
  - `subtype`
  - `text`
  - `power`
  - `toughness`
  - `loyalty`
  - `expansion`
  - `rarity`
  - `gatherer_url`
  - `versions`

## Running the tests

    :::console
    $ npm test

## Contributing

The tests, due to their nature, break from time to time. Before making code
changes, update any failing tests (as an isolated commit). Then, change the
code and update the test suite as appropriate. Finally, make a pull request.


[1]: http://gatherer.wizards.com/
[2]: http://expressjs.com/
[3]: http://localhost:3000/
[4]: http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=146017&type=card
[5]: http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=27166&type=card&options=rotate90
