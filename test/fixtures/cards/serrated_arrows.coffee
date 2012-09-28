params: {name: 'Serrated Arrows'}
response:
  name: 'Serrated Arrows'
  mana_cost: '{4}'
  converted_mana_cost: 4
  supertypes: []
  types: ['Artifact']
  subtypes: []
  text: __ """
    Serrated Arrows enters the battlefield with three arrowhead
    counters on it.

    At the beginning of your upkeep, if there are no arrowhead
    counters on Serrated Arrows, sacrifice it.

    {T}, Remove an arrowhead counter from Serrated Arrows:
    Put a -1/-1 counter on target creature.
  """
  gatherer_url:
    'http://gatherer.wizards.com/Pages/Card/Details.aspx?name=Serrated+Arrows'
  image_url:
    'http://gatherer.wizards.com/Handlers/Image.ashx?name=Serrated+Arrows&type=card'
  versions:
    2909:
      expansion: 'Homelands'
      rarity: 'Common'
    109730:
      expansion: 'Time Spiral "Timeshifted"'
      rarity: 'Special'
    202280:
      expansion: 'Duel Decks: Garruk vs. Liliana'
      rarity: 'Common'
  community_rating:
    rating: 4.024
    votes: 42
  rulings: [
    ['2008-08-01', __ """
      The upkeep trigger checks the number of counters at the start
      of upkeep, and only goes on the stack if there are no arrowhead
      counters at that time. It will check again on resolution, and
      will do nothing if you've somehow manage to get a new arrowhead
      counter on the Arrows.
    """]
  ]
