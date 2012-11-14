# Tutor

[Gatherer][1] is the canonical source for _Magic: The Gathering_ card details.
While useful, it lacks an interface for retrieving this data programmatically.
The lack of an API makes creating _Magic_-related applications unnecessarily
difficult.

Tutor provides an API for Gatherer.  Each method call makes a single request
to a page on Gatherer, scrapes the relevant information, and passes it to 
a callback.

## gettage
 
    $ npm install tutor
    
## usage    

    > t = require('tutor')

### .card(parameter, callback)

This method requests the details page for the specified card, such as
http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=247340

`parameter` can be a string, an integer, or an object.

If it's a string, it's interpreted as the name of the card you want.

If it's an integer, it's interpreted as the 'multiverse id' of the card you
want.  This is a mostly-unique number assigned by Gatherer, and is particular
to a given printing of a card.  When you use a multiverse id, the response
will include printing-specific information such as set, rarity and flavor-text. 

If it's an object, `parameter` _must_ have one of the following properties:

+ __name__: Treated as passing a string, described above. 
+ __id__: Treated as passing a multiverse id, described above. 

If both are present, `id` takes priority.

It also _may_ have the following properties:

+ __printed__: When `true`, card text and other information will be as it originally 
appeared on the card printing.  (By default, the latest oracle text is used.)
+ __part__: The name of a particular part of a multi-part or flippable card.
The parts of a card share an ID, but can be found by name.

`callback` should be a function which can accept an error and response object.
For example:

    > output = function(error, card){
    >   if(error == null){
    >     console.log(card.text)
    >   } else {
    >     console.log(error.message)
    >   }
    > }
    > t.card('Demonic Tutor', output)
    'Search your library for a card and put that card into your hand. Then shuffle your library.'

These attributes may be included in a response:

  - `name`
  - `mana_cost`
  - `converted_mana_cost`
  - `supertypes`
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
  - `image_url`
  - `versions`
  - `community_rating`
  - `rulings`

Attributes not applicable to the card type (e.g. lands have no mana cost) or
not present (e.g. certain creatures have no rules text) are omitted.

### .languages(parameter, callback)

This takes the same arguments as `.card`, but instead gives you a collection
of printings the specified card has seen in non-english languages, keyed by
ISO code.

       > t.languages(233078, function(err, list){console.log(list)})
       { 
         'zh-CN': { id: 249202, name: '鑿靈鑽' },
         de: { id: 247802, name: 'Schädelkurbel' },
         fr: { id: 247977, name: 'Manivelle à esprit' },
         it: { id: 248327, name: 'Trivellamente' },
         ja: { id: 248852, name: '精神クランク' },
         ru: { id: 249027, name: 'Мозговорот' },
         'zh-TW': { id: 248677, name: '凿灵钻' },
         'pt-BR': { id: 248152, name: 'Manivela Mental' },
         es: { id: 248502, name: 'Perforamente' } 
       }

### .set(parameter, callback)

If `parameter` is a string, it is treated as the name of a set.

If it's an object, then it _must_ have a `name` property, and it _may_ have a
positive integer `page` property, specifying a page of results. 

If no page is specified, the first page of results is given.

On success, the second argument passed to the callback will be an object
with the following properties: 

+ __page__: The current page of results.
+ __pages__: How many pages the set has. 
+ __cards__: An array of objects no more than 25 items in length.

Each card in `cards` contains all applicable attributes among the following:

  - `name`
  - `mana_cost`
  - `converted_mana_cost`
  - `supertypes`
  - `types`
  - `subtypes`
  - `text`
  - `power`
  - `toughness`
  - `loyalty`
  - `expansion`
  - `rarity`
  - `gatherer_url`
  - `image_url`
  - `versions`

### .index(callback)

The second argument passed to the callback is an object with three properties,
each of which are an array of strings:

+ __formats__: The names of all blocks and formats currently known to Gatherer.
+ __sets__: The names of all sets currently known to Gatherer.
+ __types__: All extant card types and supertypes.

[1]: http://gatherer.wizards.com/
