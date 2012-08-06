# Tutor

[Gatherer][1] is the canonical source for _Magic: The Gathering_ card details.
While useful, it lacks an interface for retrieving this data programmatically.
The lack of an API makes creating _Magic_-related applications unnecessarily
difficult.

Tutor provides an API for Gatherer. It's a lightweight [Express][2] app that
reads data from Gatherer and returns neatly formatted JSON.

## Starting the app

To run the server:

    $ npm install
    $ coffee server

This starts a server listening on the port set as the environment variable PORT,
or on port 3000 if PORT is undefined.

## GET /card/:id

Returns a JSON representation of the card specified (by Gatherer id) in the
request path. The response includes version-specific metadata such as flavor
text and rarity.

![JSON response](http://cl.ly/image/3f0y1I3D1N1p/json-response.png)

![Flame Javelin][4]

## GET /card/:id/:part

Returns a JSON representation of the specified part of the specified multipart
card. For example, `GET /card/27166/Ice` returns the Ice half of Fire and Ice.

![Fire and Ice][5]

## GET /card/:name

Returns a JSON representation of the specified card. The response does *not*
include version-specific metadata such as flavor text and rarity.

![JSON response](http://cl.ly/image/2q0b3A3R3q0L/json-response.png)

## Attributes

These attributes may be included in a response:

  - `name`
  - `mana_cost`
  - `converted_mana_cost`
  - `types`
  - `subtypes`
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

## GET /language/:id or GET /language/:name

Return the JSON representation of the available translations of the specified
card (by Gatherer id) or by name. The result is an objects with where the keys
are a language code (or culture code when needed), and values are also objects
with the following properties:

  - `name` - translated name of the card
  - `id` - multiverse id of the translated card

Example:

    {
      "es": {
        "name": "Ave del paraiso",
        "id": 265034
      }
    }


## GET /set/:name/:page?

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
  - `types`
  - `subtypes`
  - `text`
  - `power`
  - `toughness`
  - `loyalty`
  - `expansion`
  - `rarity`
  - `gatherer_url`
  - `versions`

## Running the tests

    $ npm test


[1]: http://gatherer.wizards.com/
[2]: http://expressjs.com/
[3]: http://localhost:3000/
[4]: http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=146017&type=card
[5]: http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=27166&type=card&options=rotate90
