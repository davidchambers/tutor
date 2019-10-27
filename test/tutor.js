'use strict';

const assert    = require ('assert');
const {exec}    = require ('child_process');
const fs        = require ('fs');
const path      = require ('path');
const url       = require ('url');

const nock      = require ('nock');
const _         = require ('underscore');

const gatherer  = require ('../lib/gatherer');
const tutor     = require ('..');


const fixtures$sets = path.join (__dirname, 'fixtures', 'sets')

//    urls :: StrMap Url
const urls = fs.readdirSync (fixtures$sets)
  .filter (filename => path.extname (filename) === '')
  .reduce ((map, filename) =>
             Object.assign (map, {
               [filename]: url.parse (fs.readFileSync (path.join (fixtures$sets, filename), 'utf8')),
             }),
           Object.create (null))

const mockResponses = directory => filenames => {
  const scope = nock ('https://gatherer.wizards.com');
  filenames.forEach (filename => {
    scope.get (urls[filename].path)
         .replyWithFile (200, path.join (directory, filename) + '.html');
  });
  return scope;
};

const card_url = (...args) =>
  gatherer.card.url(...args).substr(gatherer.origin.length);

const capitalize = text => text.replace (/./, chr => chr.toUpperCase ());

const toSlug = value =>
  String(value).toLowerCase().replace(/[ ]/g, '-').replace(/[^\w-]/g, '');

const eq = assert.strictEqual;

const page_ranges = {
  'Apocalypse': [0, 1],
  'Eventide': [0, 1],
  'Future Sight': [0, 1],
  'Lorwyn': [0, 1, 2],
  'New Phyrexia': [0, 1],
  'Rise of the Eldrazi': [0, 1, 2],
  'Saviors of Kamigawa': [0, 1],
  'Shadowmoor': [0, 1, 2],
  'Unhinged': [0, 1],
  'Vanguard': [0, 1],
};

const page_ranges_2 = {
  'Apocalypse': [
    'apocalypse~0',
    'apocalypse~1',
  ],
  'Eventide': [
    'eventide~0',
    'eventide~1',
  ],
  'Future Sight': [
    'future-sight~0',
    'future-sight~1',
  ],
  'Lorwyn': [
    'lorwyn~0',
    'lorwyn~1',
    'lorwyn~2',
  ],
  'New Phyrexia': [
    'new-phyrexia~0',
    'new-phyrexia~1',
  ],
  'Rise of the Eldrazi': [
    'rise-of-the-eldrazi~0',
    'rise-of-the-eldrazi~1',
    'rise-of-the-eldrazi~2',
  ],
  'Saviors of Kamigawa': [
    'saviors-of-kamigawa~0',
    'saviors-of-kamigawa~1',
  ],
  'Shadowmoor': [
    'shadowmoor~0',
    'shadowmoor~1',
    'shadowmoor~2',
  ],
  'Unhinged': [
    'unhinged~0',
    'unhinged~1',
  ],
  'Vanguard': [
    'vanguard~0',
    'vanguard~1',
  ],
};

const card = (details, test) => () => {
  const scope = nock ('https://gatherer.wizards.com');
  ['details', 'languages', 'printings'].forEach (resource => {
    const parts = [toSlug (details.id == null ? details.name : details.id)];
    if ('id' in details && 'name' in details) {
      parts.push (toSlug (details.name));
    }
    parts.push (resource);
    scope
      .get (card_url (`${capitalize (resource)}.aspx`, details))
      .replyWithFile (200, `${__dirname}/fixtures/cards/${parts.join ('~')}.html`);
    if ('_pages' in details && details._pages > 1) {
      for (let page = 2; page <= details._pages; page += 1) {
        scope
          .get (card_url (`${capitalize (resource)}.aspx`, details, {page}))
          .replyWithFile (200, `${__dirname}/fixtures/cards/${parts.join ('~')}~${page}.html`);
      }
    }
  });

  return tutor.card (details)
         .then (test)
         .finally (scope.done);
};


describe ('tutor.formats', () => {

  it ('provides an array of format names', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Default.aspx')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'index.html'));

    return tutor.formats ()
      .then (formatNames => {
        assert (Array.isArray (formatNames));
        assert (formatNames.includes ('Vintage'));
      })
      .finally (scope.done);
  });

});


describe ('tutor.sets', () => {

  it ('provides an array of set names', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Default.aspx')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'index.html'));

    return tutor.sets ()
      .then (setNames => {
        assert (Array.isArray (setNames));
        assert (setNames.includes ('Arabian Nights'));
      })
      .finally (scope.done);
  });

});


describe ('tutor.types', () => {

  it ('provides an array of types', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Default.aspx')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'index.html'));

    return tutor.types ()
      .then (types => {
        assert (Array.isArray (types));
        assert (types.includes ('Land'));
      })
      .finally (scope.done);
  });

});


describe ('tutor.set', () => {

  const set = expansion => assertions => () => {
    const scope = mockResponses (fixtures$sets) (page_ranges_2[expansion]);
    return tutor.set (expansion)
           .then (assertions)
           .finally (scope.done);
  };

  it ('extracts names',
      set ('Lorwyn')
          (cards => {
             eq (cards[0].name, 'Ajani Goldmane');
           }));

  it ('extracts mana costs',
      set ('Lorwyn')
          (cards => {
             eq (cards[0].name, 'Ajani Goldmane');
             eq (cards[0].mana_cost, '{2}{W}{W}');
           }));

  it ('extracts mana costs containing hybrid mana symbols',
      set ('Eventide')
          (cards => {
             eq (cards[99].name, 'Crackleburr');
             eq (cards[99].mana_cost, '{1}{U/R}{U/R}');
           }));

  it ('extracts mana costs containing Phyrexian mana symbols',
      set ('New Phyrexia')
          (cards => {
             eq (cards[75].name, 'Vault Skirge');
             eq (cards[75].mana_cost, '{1}{B/P}');
           }));

  it ('extracts mana costs containing double-digit mana symbols',  // #71
      set ('Rise of the Eldrazi')
          (cards => {
             eq (cards[11].name, 'Ulamog, the Infinite Gyre');
             eq (cards[11].mana_cost, '{11}');
           }));

  it ('includes mana costs discerningly',
      set ('Future Sight')
          (cards => {
             eq (cards[176].name, 'Horizon Canopy');
             assert (!(_.has (cards[176], 'mana_cost')));
             eq (cards[41].name, 'Pact of Negation');
             assert (_.has (cards[41], 'mana_cost'));
           }));

  it ('calculates converted mana costs',
      set ('Shadowmoor')
          (cards => {
             eq (cards[91].name, 'Flame Javelin');
             eq (cards[91].mana_cost, '{2/R}{2/R}{2/R}');
             eq (cards[91].converted_mana_cost, 6);
           }));

  it ('extracts supertypes',
      set ('Lorwyn')
          (cards => {
             eq (cards[246].name, 'Doran, the Siege Tower');
             eq (cards[246].supertypes.length, 1);
             eq (cards[246].supertypes[0], 'Legendary');
           }));

  it ('extracts types',
      set ('Lorwyn')
          (cards => {
             eq (cards[246].name, 'Doran, the Siege Tower');
             eq (cards[246].types.length, 1);
             eq (cards[246].types[0], 'Creature');
           }));

  it ('extracts subtypes',
      set ('Lorwyn')
          (cards => {
             eq (cards[246].name, 'Doran, the Siege Tower');
             eq (cards[246].subtypes.length, 2);
             eq (cards[246].subtypes[0], 'Treefolk');
             eq (cards[246].subtypes[1], 'Shaman');
           }));

  it ('extracts rules text',
      set ('Lorwyn')
          (cards => {
             eq (cards[75].text,
                 'Flying\n' +
                 '\n' +
                 'When Mulldrifter enters the battlefield, draw two cards.\n' +
                 '\n' +
                 'Evoke {2}{U} (You may cast this spell for its evoke cost. ' +
                 "If you do, it's sacrificed when it enters the battlefield.)");
           }));

  it ('handles consecutive hybrid mana symbols',
      set ('Eventide')
          (cards => {
             eq (cards[138].text,
                 '{R/W}: Figure of Destiny becomes a Kithkin Spirit with base ' +
                 'power and toughness 2/2.\n' +
                 '\n' +
                 '{R/W}{R/W}{R/W}: If Figure of Destiny is a Spirit, it becomes ' +
                 'a Kithkin Spirit Warrior with base power and toughness 4/4.\n' +
                 '\n' +
                 '{R/W}{R/W}{R/W}{R/W}{R/W}{R/W}: If Figure of Destiny is a ' +
                 'Warrior, it becomes a Kithkin Spirit Warrior Avatar with base ' +
                 'power and toughness 8/8, flying, and first strike.');
           }));

  it.skip ('extracts color indicators',
    set ('Future Sight')
        (cards => {
           eq (cards[173].name, 'Dryad Arbor');
           eq (cards[173].color_indicator, 'Green');
         }));

  it.skip ('includes color indicators discerningly',
    set ('Lorwyn')
        (cards => {
           cards.forEach (card => {
             assert (!(_.has (card, 'color_indicator')));
           });
         }));

  it ('extracts image_url and gatherer_url',  // #73
      set ('Lorwyn')
          (cards => {
             cards.forEach (card => {
               assert (_.has (card, 'image_url'));
               assert (_.has (card, 'gatherer_url'));
             });
           }));

  it ('extracts stats',
      set ('Lorwyn')
          (cards => {
             eq (cards[77].name, 'Pestermite');
             eq (cards[77].power, 2);
             eq (cards[77].toughness, 1);
           }));

  it ('handles fractional stats',  // #39
      set ('Unhinged')
          (cards => {
             eq (cards[48].name, 'Bad Ass');
             eq (cards[48].power, 3.5);
             eq (cards[48].toughness, 1);
             eq (cards[4].name, 'Cheap Ass');
             eq (cards[4].power, 1);
             eq (cards[4].toughness, 3.5);
             eq (cards[15].name, 'Little Girl');
             eq (cards[15].power, 0.5);
             eq (cards[15].toughness, 0.5);
           }));

  it ('handles dynamic stats',
      set ('Future Sight')
          (cards => {
             eq (cards[152].name, 'Tarmogoyf');
             eq (cards[152].power, '*');
             eq (cards[152].toughness, '1+*');
           }));

  it ('extracts loyalties',
      set ('Lorwyn')
          (cards => {
             eq (cards[0].name, 'Ajani Goldmane');
             eq (cards[0].loyalty, 4);
           }));

  it ('includes loyalties discerningly',
      set ('Lorwyn')
          (cards => {
             eq (cards[77].name, 'Pestermite');
             assert (!(_.has (cards[77], 'loyalty')));
           }));

  it ('extracts hand modifiers',
      set ('Vanguard')
          (cards => {
             eq (cards[3].name, 'Eladamri');
             eq (cards[3].hand_modifier, -1);
           }));

  it ('extracts life modifiers',
      set ('Vanguard')
          (cards => {
             eq (cards[3].name, 'Eladamri');
             eq (cards[3].life_modifier, 15);
           }));

  it ('includes expansion',
      set ('Lorwyn')
          (cards => {
             cards.forEach (card => {
               eq (card.expansion, 'Lorwyn');
             });
           }));

  it ('extracts rarities',
      set ('New Phyrexia')
          (cards => {
             eq (cards[129].name, 'Batterskull');
             eq (cards[129].rarity, 'Mythic Rare');
             eq (cards[103].name, 'Birthing Pod');
             eq (cards[103].rarity, 'Rare');
             eq (cards[56].name, 'Dismember');
             eq (cards[56].rarity, 'Uncommon');
             eq (cards[34].name, 'Gitaxian Probe');
             eq (cards[34].rarity, 'Common');
             eq (cards[166].name, 'Island');
             eq (cards[166].rarity, 'Land');
           }));

  it ('extracts versions',
      set ('Lorwyn')
          (cards => {
             eq (cards[0].name, 'Ajani Goldmane');
             eq (cards[0].versions['Lorwyn'], 'Rare');
             eq (cards[0].versions['Magic 2010'], 'Mythic Rare');
             eq (cards[0].versions['Magic 2011'], 'Mythic Rare');
           }));

  it ('does not include all versions of each basic land',  // #66
      set ('Lorwyn')
          (cards => {
             eq (cards.length, 301 - 5 * 3);
             eq (cards[281].name, 'Plains');
             eq (cards[282].name, 'Island');
             eq (cards[283].name, 'Swamp');
             eq (cards[284].name, 'Mountain');
             eq (cards[285].name, 'Forest');
             eq (cards[281].gatherer_url, 'https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=143630');
             eq (cards[282].gatherer_url, 'https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=143624');
             eq (cards[283].gatherer_url, 'https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=143634');
             eq (cards[284].gatherer_url, 'https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=143627');
             eq (cards[285].gatherer_url, 'https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=143625');
             eq (cards[281].image_url, 'https://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=143630&type=card');
             eq (cards[282].image_url, 'https://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=143624&type=card');
             eq (cards[283].image_url, 'https://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=143634&type=card');
             eq (cards[284].image_url, 'https://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=143627&type=card');
             eq (cards[285].image_url, 'https://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=143625&type=card');
           }));

  it ('handles split cards',  // #86
      set ('Apocalypse')
          (cards => {
             eq (cards[127].name, 'Fire');
             eq (cards[128].name, 'Ice');
           }));

  it ('handles flip cards',  // #86
      set ('Saviors of Kamigawa')
          (cards => {
             eq (cards[35].name, 'Erayo, Soratami Ascendant');
             eq (cards[36].name, "Erayo's Essence");
           }));

});


describe ('tutor.card', () => {

  it ('extracts name', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'hill-giant~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'hill-giant~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'hill-giant~printings.html'));

    return tutor.card ('Hill Giant')
      .then (card => { eq (card.name, 'Hill Giant'); })
      .finally (scope.done);
  });

  it ('extracts mana cost', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'hill-giant~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'hill-giant~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'hill-giant~printings.html'));

    return tutor.card ('Hill Giant')
      .then (card => { eq (card.mana_cost, '{3}{R}'); })
      .finally (scope.done);
  });

  it ('extracts mana cost containing hybrid mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Crackleburr')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'crackleburr~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Crackleburr')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'crackleburr~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Crackleburr')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'crackleburr~printings.html'));

    return tutor.card ('Crackleburr')
      .then (card => { eq (card.mana_cost, '{1}{U/R}{U/R}'); })
      .finally (scope.done);
  });

  it ('extracts mana cost containing Phyrexian mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Vault%20Skirge')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'vault-skirge~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Vault%20Skirge')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'vault-skirge~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Vault%20Skirge')
      .replyWithFile (200, path.join (__dirname, '/fixtures/cards/vault-skirge~printings.html'));

    return tutor.card ('Vault Skirge')
      .then (card => { eq (card.mana_cost, '{1}{B/P}'); })
      .finally (scope.done);
  });

  it ('extracts mana cost containing colorless mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Kozilek%2C%20the%20Great%20Distortion')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'kozilek-the-great-distortion~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Kozilek%2C%20the%20Great%20Distortion')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'kozilek-the-great-distortion~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Kozilek%2C%20the%20Great%20Distortion')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'kozilek-the-great-distortion~printings.html'));

    return tutor.card ('Kozilek, the Great Distortion')
      .then (card => { eq (card.mana_cost, '{8}{C}{C}'); })
      .finally (scope.done);
  });

  it ('includes mana cost only if present', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Ancestral%20Vision')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'ancestral-vision~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Ancestral%20Vision')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'ancestral-vision~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Ancestral%20Vision')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'ancestral-vision~printings.html'));

    return tutor.card ('Ancestral Vision')
      .then (card => { eq (Object.prototype.hasOwnProperty.call (card, 'mana_cost'), false); })
      .finally (scope.done);
  });

  it ('extracts converted mana cost', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'hill-giant~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'hill-giant~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'hill-giant~printings.html'));

    return tutor.card ('Hill Giant')
      .then (card => { eq (card.converted_mana_cost, 4); })
      .finally (scope.done);
  });

  it ('extracts supertypes', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Diamond%20Faerie')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'diamond-faerie~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Diamond%20Faerie')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'diamond-faerie~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Diamond%20Faerie')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'diamond-faerie~printings.html'));

    return tutor.card ('Diamond Faerie')
      .then (card => { assert.deepEqual (card.supertypes, ['Snow']); })
      .finally (scope.done);
  });

  it ('extracts types', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Diamond%20Faerie')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'diamond-faerie~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Diamond%20Faerie')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'diamond-faerie~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Diamond%20Faerie')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'diamond-faerie~printings.html'));

    return tutor.card ('Diamond Faerie')
      .then (card => { assert.deepEqual (card.types, ['Creature']); })
      .finally (scope.done);
  });

  it ('extracts subtypes', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Diamond%20Faerie')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'diamond-faerie~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Diamond%20Faerie')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'diamond-faerie~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Diamond%20Faerie')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'diamond-faerie~printings.html'));

    return tutor.card ('Diamond Faerie')
      .then (card => { assert.deepEqual (card.subtypes, ['Faerie']); })
      .finally (scope.done);
  });

  it ('extracts rules text', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Braids%2C%20Cabal%20Minion')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'braids-cabal-minion~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Braids%2C%20Cabal%20Minion')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'braids-cabal-minion~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Braids%2C%20Cabal%20Minion')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'braids-cabal-minion~printings.html'));

    return tutor.card ('Braids, Cabal Minion')
      .then (card => {
        eq (card.text,
            "At the beginning of each player's upkeep, that player " +
            'sacrifices an artifact, creature, or land.');
      })
      .finally (scope.done);
  });

  it ('recognizes tap and untap symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Crackleburr')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'crackleburr~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Crackleburr')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'crackleburr~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Crackleburr')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'crackleburr~printings.html'));

    return tutor.card ('Crackleburr')
      .then (card => {
        eq (card.text,
            '{U/R}{U/R}, {T}, Tap two untapped red creatures you control: ' +
            'Crackleburr deals 3 damage to any target.\n' +
            '\n' +
            '{U/R}{U/R}, {Q}, Untap two tapped blue creatures you control: ' +
            "Return target creature to its owner's hand. " +
            '({Q} is the untap symbol.)');
      })
      .finally (scope.done);
  });

  it ('recognizes colorless mana symbols',
    card ({name: 'Sol Ring'}, card => {
      eq (card.text, '{T}: Add {C}{C}.');
    })
  );

  it ('extracts flavor text from card identified by id',
    card ({id: 2960}, card => {
      eq (card.flavor_text,
          'Joskun and the other Constables serve with passion, ' +
          'if not with grace.');
      eq (card.flavor_text_attribution, 'Devin, Faerie Noble');
    })
  );

  it ('ignores flavor text of card identified by name',
    card ({name: 'Hill Giant'}, card => {
      assert (!(_.has (card, 'flavor_text')));
    })
  );

  it ('extracts color indicator',
    card ({name: 'Ancestral Vision'}, card => {
      eq (card.color_indicator, 'Blue');
      assert (!(_.has (card, 'mana_cost')));
    })
  );

  it ('includes color indicator only if present',
    card ({name: 'Hill Giant'}, card => {
      assert (!(_.has (card, 'color_indicator')));
    })
  );

  it ('extracts watermark',
    card ({name: 'Vault Skirge'}, card => {
      eq (card.watermark, 'Phyrexian');
    })
  );

  it ('extracts power',
    card ({name: 'Hill Giant'}, card => {
      eq (card.power, 3);
    })
  );

  it ('extracts decimal power',
    card ({name: 'Cardpecker'}, card => {
      eq (card.power, 1.5);
    })
  );

  it ('extracts toughness',
    card ({name: 'Hill Giant'}, card => {
      eq (card.toughness, 3);
    })
  );

  it ('extracts decimal toughness',
    card ({name: 'Cheap Ass'}, card => {
      eq (card.toughness, 3.5);
    })
  );

  it ('extracts dynamic toughness',
    card ({id: 2960}, card => {
      eq (card.toughness, '1+*');
    })
  );

  it ('extracts loyalty',
    card ({name: 'Ajani Goldmane'}, card => {
      eq (card.loyalty, 4);
    })
  );

  it ('includes loyalty only if present',
    card ({name: 'Hill Giant'}, card => {
      assert (!(_.has (card, 'loyalty')));
    })
  );

  it ('extracts hand modifier',
    card ({name: 'Akroma, Angel of Wrath Avatar'}, card => {
      eq (card.hand_modifier, 1);
    })
  );

  it ('extracts life modifier',
    card ({name: 'Akroma, Angel of Wrath Avatar'}, card => {
      eq (card.life_modifier, 7);
    })
  );

  it ('extracts expansion from card identified by id',
    card ({id: 2960}, card => {
      eq (card.expansion, 'Homelands');
    })
  );

  it ('extracts an image_url and gatherer_url for a card identified by name',  // #73
    card ({name: 'Braids, Cabal Minion'}, card => {
      eq (card.image_url, 'https://gatherer.wizards.com/Handlers/Image.ashx?type=card&name=Braids%2C%20Cabal%20Minion');
      eq (card.gatherer_url, 'https://gatherer.wizards.com/Pages/Card/Details.aspx?name=Braids%2C%20Cabal%20Minion');
    })
  );

  it ('ignores expansion of card identified by name',
    card ({name: 'Hill Giant'}, card => {
      assert (!(_.has (card, 'expansion')));
    })
  );

  it ('extracts rarity from card identified by id',
    card ({id: 2960}, card => {
      eq (card.rarity, 'Rare');
    })
  );

  it ('extracts an image_url and gatherer_url from card identified by id',  // #73
    card ({id: 2960}, card => {
      eq (card.image_url, 'https://gatherer.wizards.com/Handlers/Image.ashx?type=card&multiverseid=2960');
      eq (card.gatherer_url, 'https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2960');
    })
  );

  it ('ignores rarity of card identified by name',
    card ({name: 'Hill Giant'}, card => {
      assert (!(_.has (card, 'rarity')));
    })
  );

  it ('extracts number from card identified by id',
    card ({id: 262698}, card => {
      eq (card.number, '81b');
    })
  );

  it ('ignores number of card identified by name',
    card ({name: 'Ancestral Vision'}, card => {
      assert (!(_.has (card, 'number')));
    })
  );

  it ('extracts artist from card identified by id',
    card ({id: 2960}, card => {
      eq (card.artist, 'Dan Frazier');
    })
  );

  it ('ignores artist of card identified by name',
    card ({name: 'Hill Giant'}, card => {
      assert (!(_.has (card, 'artist')));
    })
  );

  it ('extracts versions',
    card ({name: 'Ajani Goldmane'}, card => {
      assert.deepEqual (card.versions, {
        140233: {
          expansion: 'Lorwyn',
          rarity: 'Rare',
        },
        191239: {
          expansion: 'Magic 2010',
          rarity: 'Mythic Rare',
        },
        205957: {
          expansion: 'Magic 2011',
          rarity: 'Mythic Rare',
        },
      });
    })
  );

  it ('extracts version from card with exactly one version',  // #51
    card ({name: 'Cheap Ass'}, card => {
      assert.deepEqual (card.versions, {
        74220: {
          expansion: 'Unhinged',
          rarity: 'Common',
        },
      });
    })
  );

  it ('extracts community rating',
    card ({name: 'Ajani Goldmane'}, card => {
      const {rating, votes} = card.community_rating;
      assert (typeof rating === 'number', 'rating must be a number');
      assert (rating >= 0 && rating <= 5, 'rating must be between 0 and 5');
      assert (typeof votes === 'number',  'votes must be a number');
      assert (votes >= 0,                 'votes must not be negative');
      assert (votes % 1 === 0,            'votes must be an integer');
    })
  );

  it ('extracts rulings',
    card ({name: 'Ajani Goldmane'}, card => {
      eq (card.rulings[0].length, 2);
      eq (card.rulings[0][0], '2007-10-01');
      eq (card.rulings[0][1],
          'The vigilance granted to a creature by the second ability ' +
          'remains until the end of the turn even if the +1/+1 counter ' +
          'is removed.');
      eq (card.rulings[1].length, 2);
      eq (card.rulings[1][0], '2007-10-01');
      eq (card.rulings[1][1],
          'The power and toughness of the Avatar created by the third ' +
          'ability will change as your life total changes.');
    })
  );

  it ('extracts rulings for back face of double-faced card',
    card ({name: 'Werewolf Ransacker'}, card => {
      assert (card.rulings.length > 0);
    })
  );

  const assert_languages_equal = expected => card => {
    const codes = _.keys(expected).sort();
    assert.deepEqual (_.keys(card.languages).sort(), codes);
    _.each (card.languages, (value, code) => {
      eq (value.name, expected[code].name);
      assert.deepEqual (value.ids, expected[code].ids);
    });
  };

  it ('extracts languages',
    card ({id: 262698}, assert_languages_equal ({
      /* eslint-disable key-spacing */
      'de'    : {ids: [337042], name: 'Werwolf-Einsacker'},
      'es'    : {ids: [337213], name: 'Saqueador licántropo'},
      'fr'    : {ids: [336700], name: 'Saccageur loup-garou'},
      'it'    : {ids: [337384], name: 'Predone Mannaro'},
      'ja'    : {ids: [337555], name: '\u72FC\u7537\u306E\u8352\u3089\u3057\u5C4B'},
      'kr'    : {ids: [336187], name: '\uB291\uB300\uC778\uAC04 \uC57D\uD0C8\uC790'},
      'pt-BR' : {ids: [336529], name: 'Lobisomem Saqueador'},
      'ru'    : {ids: [336871], name: '\u0412\u0435\u0440\u0432\u043E\u043B\u044C\u0444-\u041F\u043E\u0433\u0440\u043E\u043C\u0449\u0438\u043A'},
      'zh-CN' : {ids: [336358], name: '\u641C\u62EC\u72FC\u4EBA'},
      'zh-TW' : {ids: [336016], name: '\u641C\u62EC\u72FC\u4EBA'},
      /* eslint-enable key-spacing */
    }))
  );

  it ('extracts languages for card with multiple pages of languages',  // #37
    card ({id: 289327, _pages: {languages: 2}}, assert_languages_equal ({
      /* eslint-disable key-spacing */
      'de'    : {ids: [356006, 356007, 356008, 356009, 356010], name: 'Wald'},
      'es'    : {ids: [365728, 365729, 365730, 365731, 365732], name: 'Bosque'},
      'fr'    : {ids: [356280, 356281, 356282, 356283, 356284], name: 'Forêt'},
      'it'    : {ids: [356554, 356555, 356556, 356557, 356558], name: 'Foresta'},
      'ja'    : {ids: [356828, 356829, 356830, 356831, 356832], name: '\u68ee'},
      'kr'    : {ids: [357650, 357651, 357652, 357653, 357654], name: '\uc232'},
      'pt-BR' : {ids: [357102, 357103, 357104, 357105, 357106], name: 'Floresta'},
      'ru'    : {ids: [355458, 355459, 355460, 355461, 355462], name: '\u041b\u0435\u0441'},
      'zh-CN' : {ids: [355732, 355733, 355734, 355735, 355736], name: '\u6a39\u6797'},
      'zh-TW' : {ids: [357376, 357377, 357378, 357379, 357380], name: '\u6811\u6797'},
      /* eslint-enable key-spacing */
    }))
  );

  it ('extracts legality info',
    card ({name: 'Braids, Cabal Minion'}, card => {
      assert.deepEqual (_.keys(card.legality).sort(), ['Commander', 'Legacy', 'Vintage']);
      eq (card.legality['Commander'], 'Banned');
      eq (card.legality['Legacy'], 'Legal');
      eq (card.legality['Vintage'], 'Legal');
    })
  );

  it ('parses left side of split card specified by name',
    card ({name: 'Fire'}, card => {
      eq (card.name, 'Fire');
    })
  );

  it ('parses right side of split card specified by name',
    card ({name: 'Ice'}, card => {
      eq (card.name, 'Ice');
    })
  );

  it ('parses left side of split card specified by id',
    card ({id: 27165, name: 'Fire'}, card => {
      eq (card.name, 'Fire');
    })
  );

  it ('parses right side of split card specified by id',
    card ({id: 27165, name: 'Ice'}, card => {
      eq (card.name, 'Ice');
    })
  );

  it ('parses top half of flip card specified by name',
    card ({name: 'Jushi Apprentice'}, card => {
      eq (card.name, 'Jushi Apprentice');
    })
  );

  it ('parses bottom half of flip card specified by name',
    card ({name: 'Tomoya the Revealer'}, card => {
      eq (card.name, 'Tomoya the Revealer');
    })
  );

  it ('parses top half of flip card specified by id',
    card ({id: 247175}, card => {
      eq (card.name, 'Nezumi Graverobber');
    })
  );

  it ('parses bottom half of flip card specified by id',
    card ({id: 247175, which: 'b'}, card => {
      eq (card.name, 'Nighteyes the Desecrator');
    })
  );

  it ('parses front face of double-faced card specified by name',
    card ({name: 'Afflicted Deserter'}, card => {
      eq (card.name, 'Afflicted Deserter');
    })
  );

  it ('parses back face of double-faced card specified by name',
    card ({name: 'Werewolf Ransacker'}, card => {
      eq (card.name, 'Werewolf Ransacker');
    })
  );

  it ('parses back face of double-faced card specified by lower-case name',  // #57
    card ({name: 'werewolf ransacker'}, card => {
      eq (card.name, 'Werewolf Ransacker');
    })
  );

  it ('parses front face of double-faced card specified by id',
    card ({id: 262675}, card => {
      eq (card.name, 'Afflicted Deserter');
    })
  );

  it ('parses back face of double-faced card specified by id',
    card ({id: 262698}, card => {
      eq (card.name, 'Werewolf Ransacker');
    })
  );

  it ('allows accents to be omitted', () => {  // #52
    //  tutor.card("Juzam Djinn")
    //
    //                 1           2                        3
    //                   languages
    //                  /         \
    //                 /           \
    //                /             \
    //     tutor.card --- details --- search (Juzam Djinn) ==> details (159132)
    //                \             /
    //                 \           /
    //                  \         /
    //                   printings
    //
    //  1. tutor.card("Juzam Djinn") produces three HTTP requests:
    //
    //     - GET /Pages/Card/Details.aspx?name=Juzam%20Djinn
    //     - GET /Pages/Card/Languages.aspx?name=Juzam%20Djinn
    //     - GET /Pages/Card/Printings.aspx?name=Juzam%20Djinn
    //
    //  2. Each of these requests is redirected to
    //     /Pages/Search/Default.aspx?name=+[Juzam%20Djinn]
    //
    //  3. In turn, each of *these* requests is redirected to
    //     /Pages/Card/Details.aspx?multiverseid=159132
    //
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=Juzam%20Djinn')
      .reply (302, '', {Location: '/Pages/Search/Default.aspx?name=+[Juzam Djinn]'})
      .get ('/Pages/Card/Languages.aspx?name=Juzam%20Djinn')
      .reply (302, '', {Location: '/Pages/Search/Default.aspx?name=+[Juzam Djinn]'})
      .get ('/Pages/Card/Printings.aspx?name=Juzam%20Djinn')
      .reply (302, '', {Location: '/Pages/Search/Default.aspx?name=+[Juzam Djinn]'})
      .get ('/Pages/Search/Default.aspx?name=+[Juzam%20Djinn]')
      .reply (302, '', {Location: '/Pages/Card/Details.aspx?multiverseid=159132'})
      .get ('/Pages/Search/Default.aspx?name=+[Juzam%20Djinn]')
      .reply (302, '', {Location: '/Pages/Card/Details.aspx?multiverseid=159132'})
      .get ('/Pages/Search/Default.aspx?name=+[Juzam%20Djinn]')
      .reply (302, '', {Location: '/Pages/Card/Details.aspx?multiverseid=159132'})
      .get ('/Pages/Card/Details.aspx?multiverseid=159132')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', '159132~details.html'))
      .get ('/Pages/Card/Details.aspx?multiverseid=159132')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', '159132~details.html'))
      .get ('/Pages/Card/Details.aspx?multiverseid=159132')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', '159132~details.html'))
      .get ('/Pages/Card/Details.aspx?name=Juz%C3%A1m%20Djinn')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'juzam-djinn~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=Juz%C3%A1m%20Djinn')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'juzam-djinn~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=Juz%C3%A1m%20Djinn')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'juzam-djinn~printings.html'));

    return tutor.card ('Juzam Djinn')
      .then (card => { eq (card.name, 'Juzám Djinn'); })
      .finally (scope.done);
  });

  it ('responds with "no results" given non-existent card name', () => {  // #90
    const scope = nock ('https://gatherer.wizards.com')
      .get ('/Pages/Card/Details.aspx?name=fizzbuzzldspla')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'fizzbuzzldspla~details.html'))
      .get ('/Pages/Card/Languages.aspx?name=fizzbuzzldspla')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'fizzbuzzldspla~languages.html'))
      .get ('/Pages/Card/Printings.aspx?name=fizzbuzzldspla')
      .replyWithFile (200, path.join (__dirname, 'fixtures', 'cards', 'fizzbuzzldspla~printings.html'));

    return tutor.card ('fizzbuzzldspla')
      .then (
        card => Promise.reject (new Error ('expected promise to be rejected')),
        err => {
          eq (err.constructor, Error);
          eq (err.message, 'no results');
          return Promise.resolve (null);
        }
      )
      .finally (scope.done);
  });

});


const $ = (command, test) => done => {
  exec (`bin/${command}`, (err, stdout, stderr) => {
    test (err, stdout, stderr);
    done ();
  });
};


describe ('$ tutor formats', () => {

  it ('prints formats',
    $ ('tutor formats', (err, stdout) => {
      eq (err, null);
      assert (stdout.split('\n').includes('Vintage'));
    })
  );

  it ('prints JSON representation of formats',
    $ ('tutor formats --format json', (err, stdout) => {
      eq (err, null);
      assert ((JSON.parse (stdout)).includes ('Vintage'));
    })
  );

});


describe ('$ tutor sets', () => {

  it ('prints sets',
    $ ('tutor sets', (err, stdout) => {
      eq (err, null);
      assert (stdout.split('\n').includes('Stronghold'));
    })
  );

  it ('prints JSON representation of sets',
    $ ('tutor sets --format json', (err, stdout) => {
      eq (err, null);
      assert ((JSON.parse (stdout)).includes ('Stronghold'));
    })
  );

});


describe ('$ tutor types', () => {

  it ('prints types',
    $ ('tutor types', (err, stdout) => {
      eq (err, null);
      assert (stdout.split('\n').includes('Enchantment'));
    })
  );

  it ('prints JSON representation of types',
    $ ('tutor types --format json', (err, stdout) => {
      eq (err, null);
      assert ((JSON.parse (stdout)).includes ('Enchantment'));
    })
  );

});


describe ('$ tutor set', () => {

  it ('prints summary of cards in set',
    $ ('tutor set Alliances | head -n 3', (err, stdout) => {
      eq (err, null);
      eq (stdout, `
        Aesthir Glider {3} 2/1 Flying Aesthir Glider can't block.
        Agent of Stromgald {R} 1/1 {R}: Add {B}.
        Arcane Denial {1}{U} Counter target spell. Its controller may draw up to two cards at the beginning of the next turn's upkeep. You draw a card at the beginning of the next turn's upkeep.

      `);
    })
  );

  it ('prints JSON representation of cards in set',
    $ ('tutor set Alliances --format json', (err, stdout) => {
      eq (err, null);
      const cards = JSON.parse (stdout);
      eq (cards[0].name, 'Aesthir Glider');
      eq (cards[1].name, 'Agent of Stromgald');
      eq (cards[2].name, 'Arcane Denial');
    })
  );

  it ('handles sets with (one version of) exactly one basic land',  // #69
    $ ('tutor set "Arabian Nights" --format json', (err, stdout) => {
      eq (err, null);
      const cards = JSON.parse (stdout);
      eq (cards.length, 78);
      eq (cards[55].name, 'Mountain');
    })
  );

  it ('handles sets with (multiple versions of) exactly one basic land',  // #69
    $ ('tutor set "Premium Deck Series: Fire and Lightning" --format json', (err, stdout) => {
      eq (err, null);
      const cards = JSON.parse (stdout);
      eq (cards.length, 31);
      eq (cards[30].name, 'Mountain');
    })
  );

});


describe ('$ tutor card', () => {

  it ('prints summary of card',
    $ ('tutor card Braingeyser', (err, stdout) => {
      eq (err, null);
      eq (stdout, 'Braingeyser {X}{U}{U} Target player draws X cards.\n');
    })
  );

  it ('prints JSON representation of card specified by name',
    $ ('tutor card Fireball --format json', (err, stdout) => {
      eq (err, null);
      eq (JSON.parse(stdout).name, 'Fireball');
    })
  );

  it ('prints JSON representation of card specified by id',
    $ ('tutor card 987 --format json', (err, stdout) => {
      eq (err, null);
      eq (JSON.parse(stdout).artist, 'Brian Snoddy');
    })
  );

});
