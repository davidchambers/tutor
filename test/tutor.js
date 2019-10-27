'use strict';

const assert    = require ('assert');
const {exec}    = require ('child_process');
const path      = require ('path');

const nock      = require ('nock');
const _         = require ('underscore');

const tutor     = require ('..');


const fixtures$cards = path.join (__dirname, 'fixtures', 'cards');
const fixtures$sets = path.join (__dirname, 'fixtures', 'sets');

const eq = assert.deepStrictEqual;


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

  it ('extracts names', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[0].name, 'Ajani Goldmane');
    })
    .finally (scope.done);
  });

  it ('extracts mana costs', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[0].name, 'Ajani Goldmane');
      eq (cards[0].mana_cost, '{2}{W}{W}');
    })
    .finally (scope.done);
  });

  it ('extracts mana costs containing hybrid mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Eventide%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'eventide~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Eventide%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'eventide~1.html'));

    return tutor.set ('Eventide')
    .then (cards => {
      eq (cards[99].name, 'Crackleburr');
      eq (cards[99].mana_cost, '{1}{U/R}{U/R}');
    })
    .finally (scope.done);
  });

  it ('extracts mana costs containing Phyrexian mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22New%20Phyrexia%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'new-phyrexia~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22New%20Phyrexia%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'new-phyrexia~1.html'));

    return tutor.set ('New Phyrexia')
    .then (cards => {
      eq (cards[75].name, 'Vault Skirge');
      eq (cards[75].mana_cost, '{1}{B/P}');
    })
    .finally (scope.done);
  });

  it ('extracts mana costs containing double-digit mana symbols', () => {  // #71
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Rise%20of%20the%20Eldrazi%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'rise-of-the-eldrazi~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Rise%20of%20the%20Eldrazi%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'rise-of-the-eldrazi~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Rise%20of%20the%20Eldrazi%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'rise-of-the-eldrazi~2.html'));

    return tutor.set ('Rise of the Eldrazi')
    .then (cards => {
      eq (cards[11].name, 'Ulamog, the Infinite Gyre');
      eq (cards[11].mana_cost, '{11}');
    })
    .finally (scope.done);
  });

  it ('includes mana costs discerningly', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Future%20Sight%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'future-sight~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Future%20Sight%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'future-sight~1.html'));

    return tutor.set ('Future Sight')
    .then (cards => {
      eq (cards[176].name, 'Horizon Canopy');
      assert (!(_.has (cards[176], 'mana_cost')));
      eq (cards[41].name, 'Pact of Negation');
      assert (_.has (cards[41], 'mana_cost'));
    })
    .finally (scope.done);
  });

  it ('calculates converted mana costs', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Shadowmoor%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'shadowmoor~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Shadowmoor%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'shadowmoor~1.html'));

    return tutor.set ('Shadowmoor')
    .then (cards => {
      eq (cards[91].name, 'Flame Javelin');
      eq (cards[91].mana_cost, '{2/R}{2/R}{2/R}');
      eq (cards[91].converted_mana_cost, 6);
    })
    .finally (scope.done);
  });

  it ('extracts supertypes', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[246].name, 'Doran, the Siege Tower');
      eq (cards[246].supertypes, ['Legendary']);
    })
    .finally (scope.done);
  });

  it ('extracts types', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[246].name, 'Doran, the Siege Tower');
      eq (cards[246].types, ['Creature']);
    })
    .finally (scope.done);
  });

  it ('extracts subtypes', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[246].name, 'Doran, the Siege Tower');
      eq (cards[246].subtypes, ['Treefolk', 'Shaman']);
    })
    .finally (scope.done);
  });

  it ('extracts rules text', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[75].text,
          'Flying\n' +
          '\n' +
          'When Mulldrifter enters the battlefield, draw two cards.\n' +
          '\n' +
          'Evoke {2}{U} (You may cast this spell for its evoke cost. ' +
          "If you do, it's sacrificed when it enters the battlefield.)");
    })
    .finally (scope.done);
  });

  it ('handles consecutive hybrid mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Eventide%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'eventide~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Eventide%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'eventide~1.html'));

    return tutor.set ('Eventide')
    .then (cards => {
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
    })
    .finally (scope.done);
  });

  it.skip ('extracts color indicators', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Future%20Sight%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'future-sight~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Future%20Sight%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'future-sight~1.html'));

    return tutor.set ('Future Sight')
    .then (cards => {
      eq (cards[173].name, 'Dryad Arbor');
      eq (cards[173].color_indicator, 'Green');
    })
    .finally (scope.done);
  });

  it.skip ('includes color indicators discerningly', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      cards.forEach (card => {
        assert (!(_.has (card, 'color_indicator')));
      });
    })
    .finally (scope.done);
  });

  it ('extracts image_url and gatherer_url', () => {  // #73
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      cards.forEach (card => {
        assert (_.has (card, 'image_url'));
        assert (_.has (card, 'gatherer_url'));
      });
    })
    .finally (scope.done);
  });

  it ('extracts stats', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[77].name, 'Pestermite');
      eq (cards[77].power, 2);
      eq (cards[77].toughness, 1);
    })
    .finally (scope.done);
  });

  it ('handles fractional stats', () => {  // #39
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Unhinged%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'unhinged~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Unhinged%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'unhinged~1.html'));

    return tutor.set ('Unhinged')
    .then (cards => {
      eq (cards[48].name, 'Bad Ass');
      eq (cards[48].power, 3.5);
      eq (cards[48].toughness, 1);
      eq (cards[4].name, 'Cheap Ass');
      eq (cards[4].power, 1);
      eq (cards[4].toughness, 3.5);
      eq (cards[15].name, 'Little Girl');
      eq (cards[15].power, 0.5);
      eq (cards[15].toughness, 0.5);
    })
    .finally (scope.done);
  });

  it ('handles dynamic stats', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Future%20Sight%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'future-sight~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Future%20Sight%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'future-sight~1.html'));

    return tutor.set ('Future Sight')
    .then (cards => {
      eq (cards[152].name, 'Tarmogoyf');
      eq (cards[152].power, '*');
      eq (cards[152].toughness, '1+*');
    })
    .finally (scope.done);
  });

  it ('extracts loyalties', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[0].name, 'Ajani Goldmane');
      eq (cards[0].loyalty, 4);
    })
    .finally (scope.done);
  });

  it ('includes loyalties discerningly', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[77].name, 'Pestermite');
      assert (!(_.has (cards[77], 'loyalty')));
    })
    .finally (scope.done);
  });

  it ('extracts hand modifiers', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Vanguard%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'vanguard~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Vanguard%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'vanguard~1.html'));

    return tutor.set ('Vanguard')
    .then (cards => {
      eq (cards[3].name, 'Eladamri');
      eq (cards[3].hand_modifier, -1);
    })
    .finally (scope.done);
  });

  it ('extracts life modifiers', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Vanguard%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'vanguard~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Vanguard%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'vanguard~1.html'));

    return tutor.set ('Vanguard')
    .then (cards => {
      eq (cards[3].name, 'Eladamri');
      eq (cards[3].life_modifier, 15);
    })
    .finally (scope.done);
  });

  it ('includes expansion', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      cards.forEach (card => {
        eq (card.expansion, 'Lorwyn');
      });
    })
    .finally (scope.done);
  });

  it ('extracts rarities', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22New%20Phyrexia%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'new-phyrexia~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22New%20Phyrexia%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'new-phyrexia~1.html'));

    return tutor.set ('New Phyrexia')
    .then (cards => {
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
    })
    .finally (scope.done);
  });

  it ('extracts versions', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
      eq (cards[0].name, 'Ajani Goldmane');
      eq (cards[0].versions['Lorwyn'], 'Rare');
      eq (cards[0].versions['Magic 2010'], 'Mythic Rare');
      eq (cards[0].versions['Magic 2011'], 'Mythic Rare');
    })
    .finally (scope.done);
  });

  it ('does not include all versions of each basic land', () => {  // #66
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~1.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=2&set=%5B%22Lorwyn%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'lorwyn~2.html'));

    return tutor.set ('Lorwyn')
    .then (cards => {
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
    })
    .finally (scope.done);
  });

  it ('handles split cards', () => {  // #86
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Apocalypse%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'apocalypse~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Apocalypse%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'apocalypse~1.html'));

    return tutor.set ('Apocalypse')
    .then (cards => {
      eq (cards[127].name, 'Fire');
      eq (cards[128].name, 'Ice');
    })
    .finally (scope.done);
  });

  it ('handles flip cards', () => {  // #86
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=0&set=%5B%22Saviors%20of%20Kamigawa%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'saviors-of-kamigawa~0.html'))
    .get ('/Pages/Search/Default.aspx?action=advanced&output=standard&page=1&set=%5B%22Saviors%20of%20Kamigawa%22%5D&sort=cn%2B')
    .replyWithFile (200, path.join (fixtures$sets, 'saviors-of-kamigawa~1.html'));

    return tutor.set ('Saviors of Kamigawa')
    .then (cards => {
      eq (cards[35].name, 'Erayo, Soratami Ascendant');
      eq (cards[36].name, "Erayo's Essence");
    })
    .finally (scope.done);
  });

});


describe ('tutor.card', () => {

  it ('extracts name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ('Hill Giant')
    .then (card => {
      eq (card.name, 'Hill Giant');
    })
    .finally (scope.done);
  });

  it ('extracts mana cost', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ('Hill Giant')
    .then (card => {
      eq (card.mana_cost, '{3}{R}');
    })
    .finally (scope.done);
  });

  it ('extracts mana cost containing hybrid mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Crackleburr')
    .replyWithFile (200, path.join (fixtures$cards, 'crackleburr~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Crackleburr')
    .replyWithFile (200, path.join (fixtures$cards, 'crackleburr~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Crackleburr')
    .replyWithFile (200, path.join (fixtures$cards, 'crackleburr~printings.html'));

    return tutor.card ('Crackleburr')
    .then (card => {
      eq (card.mana_cost, '{1}{U/R}{U/R}');
    })
    .finally (scope.done);
  });

  it ('extracts mana cost containing Phyrexian mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Vault%20Skirge')
    .replyWithFile (200, path.join (fixtures$cards, 'vault-skirge~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Vault%20Skirge')
    .replyWithFile (200, path.join (fixtures$cards, 'vault-skirge~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Vault%20Skirge')
    .replyWithFile (200, path.join (__dirname, '/fixtures/cards/vault-skirge~printings.html'));

    return tutor.card ('Vault Skirge')
    .then (card => {
      eq (card.mana_cost, '{1}{B/P}');
    })
    .finally (scope.done);
  });

  it ('extracts mana cost containing colorless mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Kozilek%2C%20the%20Great%20Distortion')
    .replyWithFile (200, path.join (fixtures$cards, 'kozilek-the-great-distortion~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Kozilek%2C%20the%20Great%20Distortion')
    .replyWithFile (200, path.join (fixtures$cards, 'kozilek-the-great-distortion~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Kozilek%2C%20the%20Great%20Distortion')
    .replyWithFile (200, path.join (fixtures$cards, 'kozilek-the-great-distortion~printings.html'));

    return tutor.card ('Kozilek, the Great Distortion')
    .then (card => {
      eq (card.mana_cost, '{8}{C}{C}');
    })
    .finally (scope.done);
  });

  it ('includes mana cost only if present', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Ancestral%20Vision')
    .replyWithFile (200, path.join (fixtures$cards, 'ancestral-vision~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Ancestral%20Vision')
    .replyWithFile (200, path.join (fixtures$cards, 'ancestral-vision~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Ancestral%20Vision')
    .replyWithFile (200, path.join (fixtures$cards, 'ancestral-vision~printings.html'));

    return tutor.card ('Ancestral Vision')
    .then (card => {
      eq (Object.prototype.hasOwnProperty.call (card, 'mana_cost'), false);
    })
    .finally (scope.done);
  });

  it ('extracts converted mana cost', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ('Hill Giant')
    .then (card => {
      eq (card.converted_mana_cost, 4);
    })
    .finally (scope.done);
  });

  it ('extracts supertypes', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Diamond%20Faerie')
    .replyWithFile (200, path.join (fixtures$cards, 'diamond-faerie~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Diamond%20Faerie')
    .replyWithFile (200, path.join (fixtures$cards, 'diamond-faerie~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Diamond%20Faerie')
    .replyWithFile (200, path.join (fixtures$cards, 'diamond-faerie~printings.html'));

    return tutor.card ('Diamond Faerie')
    .then (card => {
      assert.deepEqual (card.supertypes, ['Snow']);
    })
    .finally (scope.done);
  });

  it ('extracts types', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Diamond%20Faerie')
    .replyWithFile (200, path.join (fixtures$cards, 'diamond-faerie~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Diamond%20Faerie')
    .replyWithFile (200, path.join (fixtures$cards, 'diamond-faerie~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Diamond%20Faerie')
    .replyWithFile (200, path.join (fixtures$cards, 'diamond-faerie~printings.html'));

    return tutor.card ('Diamond Faerie')
    .then (card => {
      assert.deepEqual (card.types, ['Creature']);
    })
    .finally (scope.done);
  });

  it ('extracts subtypes', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Diamond%20Faerie')
    .replyWithFile (200, path.join (fixtures$cards, 'diamond-faerie~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Diamond%20Faerie')
    .replyWithFile (200, path.join (fixtures$cards, 'diamond-faerie~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Diamond%20Faerie')
    .replyWithFile (200, path.join (fixtures$cards, 'diamond-faerie~printings.html'));

    return tutor.card ('Diamond Faerie')
    .then (card => {
      assert.deepEqual (card.subtypes, ['Faerie']);
    })
    .finally (scope.done);
  });

  it ('extracts rules text', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Braids%2C%20Cabal%20Minion')
    .replyWithFile (200, path.join (fixtures$cards, 'braids-cabal-minion~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Braids%2C%20Cabal%20Minion')
    .replyWithFile (200, path.join (fixtures$cards, 'braids-cabal-minion~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Braids%2C%20Cabal%20Minion')
    .replyWithFile (200, path.join (fixtures$cards, 'braids-cabal-minion~printings.html'));

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
    .replyWithFile (200, path.join (fixtures$cards, 'crackleburr~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Crackleburr')
    .replyWithFile (200, path.join (fixtures$cards, 'crackleburr~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Crackleburr')
    .replyWithFile (200, path.join (fixtures$cards, 'crackleburr~printings.html'));

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

  it ('recognizes colorless mana symbols', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Sol%20Ring')
    .replyWithFile (200, path.join (fixtures$cards, 'sol-ring~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Sol%20Ring')
    .replyWithFile (200, path.join (fixtures$cards, 'sol-ring~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Sol%20Ring')
    .replyWithFile (200, path.join (fixtures$cards, 'sol-ring~printings.html'));

    return tutor.card ({name: 'Sol Ring'})
    .then (card => {
      eq (card.text, '{T}: Add {C}{C}.');
    })
    .finally (scope.done);
  });

  it ('extracts flavor text from card identified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~printings.html'));

    return tutor.card ({id: 2960})
    .then (card => {
      eq (card.flavor_text,
          'Joskun and the other Constables serve with passion, ' +
          'if not with grace.');
      eq (card.flavor_text_attribution, 'Devin, Faerie Noble');
    })
    .finally (scope.done);
  });

  it ('ignores flavor text of card identified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ({name: 'Hill Giant'})
    .then (card => {
      assert (!(_.has (card, 'flavor_text')));
    })
    .finally (scope.done);
  });

  it ('extracts color indicator', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Ancestral%20Vision')
    .replyWithFile (200, path.join (fixtures$cards, 'ancestral-vision~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Ancestral%20Vision')
    .replyWithFile (200, path.join (fixtures$cards, 'ancestral-vision~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Ancestral%20Vision')
    .replyWithFile (200, path.join (fixtures$cards, 'ancestral-vision~printings.html'));

    return tutor.card ({name: 'Ancestral Vision'})
    .then (card => {
      eq (card.color_indicator, 'Blue');
      assert (!(_.has (card, 'mana_cost')));
    })
    .finally (scope.done);
  });

  it ('includes color indicator only if present', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ({name: 'Hill Giant'})
    .then (card => {
      assert (!(_.has (card, 'color_indicator')));
    })
    .finally (scope.done);
  });

  it ('extracts watermark', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Vault%20Skirge')
    .replyWithFile (200, path.join (fixtures$cards, 'vault-skirge~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Vault%20Skirge')
    .replyWithFile (200, path.join (fixtures$cards, 'vault-skirge~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Vault%20Skirge')
    .replyWithFile (200, path.join (fixtures$cards, 'vault-skirge~printings.html'));

    return tutor.card ({name: 'Vault Skirge'})
    .then (card => {
      eq (card.watermark, 'Phyrexian');
    })
    .finally (scope.done);
  });

  it ('extracts power', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ({name: 'Hill Giant'})
    .then (card => {
      eq (card.power, 3);
    })
    .finally (scope.done);
  });

  it ('extracts decimal power', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Cardpecker')
    .replyWithFile (200, path.join (fixtures$cards, 'cardpecker~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Cardpecker')
    .replyWithFile (200, path.join (fixtures$cards, 'cardpecker~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Cardpecker')
    .replyWithFile (200, path.join (fixtures$cards, 'cardpecker~printings.html'));

    return tutor.card ({name: 'Cardpecker'})
    .then (card => {
      eq (card.power, 1.5);
    })
    .finally (scope.done);
  });

  it ('extracts toughness', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ({name: 'Hill Giant'})
    .then (card => {
      eq (card.toughness, 3);
    })
    .finally (scope.done);
  });

  it ('extracts decimal toughness', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Cheap%20Ass')
    .replyWithFile (200, path.join (fixtures$cards, 'cheap-ass~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Cheap%20Ass')
    .replyWithFile (200, path.join (fixtures$cards, 'cheap-ass~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Cheap%20Ass')
    .replyWithFile (200, path.join (fixtures$cards, 'cheap-ass~printings.html'));

    return tutor.card ({name: 'Cheap Ass'})
    .then (card => {
      eq (card.toughness, 3.5);
    })
    .finally (scope.done);
  });

  it ('extracts dynamic toughness', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~printings.html'));

    return tutor.card ({id: 2960})
    .then (card => {
      eq (card.toughness, '1+*');
    })
    .finally (scope.done);
  });

  it ('extracts loyalty', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~printings.html'));

    return tutor.card ({name: 'Ajani Goldmane'})
    .then (card => {
      eq (card.loyalty, 4);
    })
    .finally (scope.done);
  });

  it ('includes loyalty only if present', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ({name: 'Hill Giant'})
    .then (card => {
      assert (!(_.has (card, 'loyalty')));
    })
    .finally (scope.done);
  });

  it ('extracts hand modifier', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Akroma%2C%20Angel%20of%20Wrath%20Avatar')
    .replyWithFile (200, path.join (fixtures$cards, 'akroma-angel-of-wrath-avatar~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Akroma%2C%20Angel%20of%20Wrath%20Avatar')
    .replyWithFile (200, path.join (fixtures$cards, 'akroma-angel-of-wrath-avatar~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Akroma%2C%20Angel%20of%20Wrath%20Avatar')
    .replyWithFile (200, path.join (fixtures$cards, 'akroma-angel-of-wrath-avatar~printings.html'));

    return tutor.card ({name: 'Akroma, Angel of Wrath Avatar'})
    .then (card => {
      eq (card.hand_modifier, 1);
    })
    .finally (scope.done);
  });

  it ('extracts life modifier', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Akroma%2C%20Angel%20of%20Wrath%20Avatar')
    .replyWithFile (200, path.join (fixtures$cards, 'akroma-angel-of-wrath-avatar~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Akroma%2C%20Angel%20of%20Wrath%20Avatar')
    .replyWithFile (200, path.join (fixtures$cards, 'akroma-angel-of-wrath-avatar~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Akroma%2C%20Angel%20of%20Wrath%20Avatar')
    .replyWithFile (200, path.join (fixtures$cards, 'akroma-angel-of-wrath-avatar~printings.html'));

    return tutor.card ({name: 'Akroma, Angel of Wrath Avatar'})
    .then (card => {
      eq (card.life_modifier, 7);
    })
    .finally (scope.done);
  });

  it ('extracts expansion from card identified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~printings.html'));

    return tutor.card ({id: 2960})
    .then (card => {
      eq (card.expansion, 'Homelands');
    })
    .finally (scope.done);
  });

  it ('extracts an image_url and gatherer_url for a card identified by name', () => {  // #73
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Braids%2C%20Cabal%20Minion')
    .replyWithFile (200, path.join (fixtures$cards, 'braids-cabal-minion~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Braids%2C%20Cabal%20Minion')
    .replyWithFile (200, path.join (fixtures$cards, 'braids-cabal-minion~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Braids%2C%20Cabal%20Minion')
    .replyWithFile (200, path.join (fixtures$cards, 'braids-cabal-minion~printings.html'));

    return tutor.card ({name: 'Braids, Cabal Minion'})
    .then (card => {
      eq (card.image_url, 'https://gatherer.wizards.com/Handlers/Image.ashx?type=card&name=Braids%2C%20Cabal%20Minion');
      eq (card.gatherer_url, 'https://gatherer.wizards.com/Pages/Card/Details.aspx?name=Braids%2C%20Cabal%20Minion');
    })
    .finally (scope.done);
  });

  it ('ignores expansion of card identified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ({name: 'Hill Giant'})
    .then (card => {
      assert (!(_.has (card, 'expansion')));
    })
    .finally (scope.done);
  });

  it ('extracts rarity from card identified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~printings.html'));

    return tutor.card ({id: 2960})
    .then (card => {
      eq (card.rarity, 'Rare');
    })
    .finally (scope.done);
  });

  it ('extracts an image_url and gatherer_url from card identified by id', () => {  // #73
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~printings.html'));

    return tutor.card ({id: 2960})
    .then (card => {
      eq (card.image_url, 'https://gatherer.wizards.com/Handlers/Image.ashx?type=card&multiverseid=2960');
      eq (card.gatherer_url, 'https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=2960');
    })
    .finally (scope.done);
  });

  it ('ignores rarity of card identified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ({name: 'Hill Giant'})
    .then (card => {
      assert (!(_.has (card, 'rarity')));
    })
    .finally (scope.done);
  });

  it ('extracts number from card identified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=262698')
    .replyWithFile (200, path.join (fixtures$cards, '262698~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=262698')
    .replyWithFile (200, path.join (fixtures$cards, '262698~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=262698')
    .replyWithFile (200, path.join (fixtures$cards, '262698~printings.html'));

    return tutor.card ({id: 262698})
    .then (card => {
      eq (card.number, '81b');
    })
    .finally (scope.done);
  });

  it ('ignores number of card identified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Ancestral%20Vision')
    .replyWithFile (200, path.join (fixtures$cards, 'ancestral-vision~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Ancestral%20Vision')
    .replyWithFile (200, path.join (fixtures$cards, 'ancestral-vision~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Ancestral%20Vision')
    .replyWithFile (200, path.join (fixtures$cards, 'ancestral-vision~printings.html'));

    return tutor.card ('Ancestral Vision')
    .then (card => {
      assert (!(_.has (card, 'number')));
    })
    .finally (scope.done);
  });

  it ('extracts artist from card identified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=2960')
    .replyWithFile (200, path.join (fixtures$cards, '2960~printings.html'));

    return tutor.card ({id: 2960})
    .then (card => {
      eq (card.artist, 'Dan Frazier');
    })
    .finally (scope.done);
  });

  it ('ignores artist of card identified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Hill%20Giant')
    .replyWithFile (200, path.join (fixtures$cards, 'hill-giant~printings.html'));

    return tutor.card ({name: 'Hill Giant'})
    .then (card => {
      assert (!(_.has (card, 'artist')));
    })
    .finally (scope.done);
  });

  it ('extracts versions', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~printings.html'));

    return tutor.card ({name: 'Ajani Goldmane'})
    .then (card => {
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
    .finally (scope.done);
  });

  it ('extracts version from card with exactly one version', () => {  // #51
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Cheap%20Ass')
    .replyWithFile (200, path.join (fixtures$cards, 'cheap-ass~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Cheap%20Ass')
    .replyWithFile (200, path.join (fixtures$cards, 'cheap-ass~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Cheap%20Ass')
    .replyWithFile (200, path.join (fixtures$cards, 'cheap-ass~printings.html'));

    return tutor.card ({name: 'Cheap Ass'})
    .then (card => {
      assert.deepEqual (card.versions, {
        74220: {
          expansion: 'Unhinged',
          rarity: 'Common',
        },
      });
    })
    .finally (scope.done);
  });

  it ('extracts community rating', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~printings.html'));

    return tutor.card ({name: 'Ajani Goldmane'})
    .then (card => {
      const {rating, votes} = card.community_rating;
      assert (typeof rating === 'number', 'rating must be a number');
      assert (rating >= 0 && rating <= 5, 'rating must be between 0 and 5');
      assert (typeof votes === 'number',  'votes must be a number');
      assert (votes >= 0,                 'votes must not be negative');
      assert (votes % 1 === 0,            'votes must be an integer');
    })
    .finally (scope.done);
  });

  it ('extracts rulings', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Ajani%20Goldmane')
    .replyWithFile (200, path.join (fixtures$cards, 'ajani-goldmane~printings.html'));

    return tutor.card ({name: 'Ajani Goldmane'})
    .then (card => {
      eq (card.rulings,
          [['2007-10-01',
            'The vigilance granted to a creature by the second ability ' +
            'remains until the end of the turn even if the +1/+1 counter ' +
            'is removed.'],
           ['2007-10-01',
            'The power and toughness of the Avatar created by the third ' +
            'ability will change as your life total changes.']]);
    })
    .finally (scope.done);
  });

  it ('extracts rulings for back face of double-faced card', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Werewolf%20Ransacker')
    .replyWithFile (200, path.join (fixtures$cards, 'werewolf-ransacker~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Werewolf%20Ransacker')
    .replyWithFile (200, path.join (fixtures$cards, 'werewolf-ransacker~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Werewolf%20Ransacker')
    .replyWithFile (200, path.join (fixtures$cards, 'werewolf-ransacker~printings.html'));

    return tutor.card ({name: 'Werewolf Ransacker'})
    .then (card => {
      assert (card.rulings.length > 0);
    })
    .finally (scope.done);
  });

  const assert_languages_equal = expected => card => {
    const codes = (_.keys (expected)).sort ();
    assert.deepEqual ((_.keys (card.languages)).sort (), codes);
    _.each (card.languages, (value, code) => {
      eq (value.name, expected[code].name);
      assert.deepEqual (value.ids, expected[code].ids);
    });
  };

  it ('extracts languages', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=262698')
    .replyWithFile (200, path.join (fixtures$cards, '262698~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=262698')
    .replyWithFile (200, path.join (fixtures$cards, '262698~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=262698')
    .replyWithFile (200, path.join (fixtures$cards, '262698~printings.html'));

    return tutor.card ({id: 262698})
    .then (assert_languages_equal ({
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
    .finally (scope.done);
  });

  it ('extracts languages for card with multiple pages of languages', () => {  // #37
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=289327')
    .replyWithFile (200, path.join (fixtures$cards, '289327~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=289327')
    .replyWithFile (200, path.join (fixtures$cards, '289327~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=289327')
    .replyWithFile (200, path.join (fixtures$cards, '289327~printings.html'));

    return tutor.card ({id: 289327, _pages: {languages: 2}})
    .then (assert_languages_equal ({
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
    .finally (scope.done);
  });

  it ('extracts legality info', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Braids%2C%20Cabal%20Minion')
    .replyWithFile (200, path.join (fixtures$cards, 'braids-cabal-minion~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Braids%2C%20Cabal%20Minion')
    .replyWithFile (200, path.join (fixtures$cards, 'braids-cabal-minion~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Braids%2C%20Cabal%20Minion')
    .replyWithFile (200, path.join (fixtures$cards, 'braids-cabal-minion~printings.html'));

    return tutor.card ('Braids, Cabal Minion')
    .then (card => {
      assert.deepEqual ((_.keys (card.legality)).sort (), ['Commander', 'Legacy', 'Vintage']);
      eq (card.legality['Commander'], 'Banned');
      eq (card.legality['Legacy'], 'Legal');
      eq (card.legality['Vintage'], 'Legal');
    })
    .finally (scope.done);
  });

  it ('parses left side of split card specified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Fire')
    .replyWithFile (200, path.join (fixtures$cards, 'fire~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Fire')
    .replyWithFile (200, path.join (fixtures$cards, 'fire~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Fire')
    .replyWithFile (200, path.join (fixtures$cards, 'fire~printings.html'));

    return tutor.card ({name: 'Fire'})
    .then (card => {
      eq (card.name, 'Fire');
    })
    .finally (scope.done);
  });

  it ('parses right side of split card specified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Ice')
    .replyWithFile (200, path.join (fixtures$cards, 'ice~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Ice')
    .replyWithFile (200, path.join (fixtures$cards, 'ice~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Ice')
    .replyWithFile (200, path.join (fixtures$cards, 'ice~printings.html'));

    return tutor.card ({name: 'Ice'})
    .then (card => {
      eq (card.name, 'Ice');
    })
    .finally (scope.done);
  });

  it ('parses left side of split card specified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=27165')
    .replyWithFile (200, path.join (fixtures$cards, '27165~fire~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=27165')
    .replyWithFile (200, path.join (fixtures$cards, '27165~fire~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=27165')
    .replyWithFile (200, path.join (fixtures$cards, '27165~fire~printings.html'));

    return tutor.card ({id: 27165, name: 'Fire'})
    .then (card => {
      eq (card.name, 'Fire');
    })
    .finally (scope.done);
  });

  it ('parses right side of split card specified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=27165')
    .replyWithFile (200, path.join (fixtures$cards, '27165~fire~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=27165')
    .replyWithFile (200, path.join (fixtures$cards, '27165~fire~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=27165')
    .replyWithFile (200, path.join (fixtures$cards, '27165~fire~printings.html'));

    return tutor.card ({id: 27165, name: 'Ice'})
    .then (card => {
      eq (card.name, 'Ice');
    })
    .finally (scope.done);
  });

  it ('parses top half of flip card specified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Jushi%20Apprentice')
    .replyWithFile (200, path.join (fixtures$cards, 'jushi-apprentice~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Jushi%20Apprentice')
    .replyWithFile (200, path.join (fixtures$cards, 'jushi-apprentice~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Jushi%20Apprentice')
    .replyWithFile (200, path.join (fixtures$cards, 'jushi-apprentice~printings.html'));

    return tutor.card ({name: 'Jushi Apprentice'})
    .then (card => {
      eq (card.name, 'Jushi Apprentice');
    })
    .finally (scope.done);
  });

  it ('parses bottom half of flip card specified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Tomoya%20the%20Revealer')
    .replyWithFile (200, path.join (fixtures$cards, 'tomoya-the-revealer~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Tomoya%20the%20Revealer')
    .replyWithFile (200, path.join (fixtures$cards, 'tomoya-the-revealer~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Tomoya%20the%20Revealer')
    .replyWithFile (200, path.join (fixtures$cards, 'tomoya-the-revealer~printings.html'));

    return tutor.card ({name: 'Tomoya the Revealer'})
    .then (card => {
      eq (card.name, 'Tomoya the Revealer');
    })
    .finally (scope.done);
  });

  it ('parses top half of flip card specified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=247175')
    .replyWithFile (200, path.join (fixtures$cards, '247175~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=247175')
    .replyWithFile (200, path.join (fixtures$cards, '247175~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=247175')
    .replyWithFile (200, path.join (fixtures$cards, '247175~printings.html'));

    return tutor.card ({id: 247175})
    .then (card => {
      eq (card.name, 'Nezumi Graverobber');
    })
    .finally (scope.done);
  });

  it ('parses bottom half of flip card specified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=247175')
    .replyWithFile (200, path.join (fixtures$cards, '247175~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=247175')
    .replyWithFile (200, path.join (fixtures$cards, '247175~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=247175')
    .replyWithFile (200, path.join (fixtures$cards, '247175~printings.html'));

    return tutor.card ({id: 247175, which: 'b'})
    .then (card => {
      eq (card.name, 'Nighteyes the Desecrator');
    })
    .finally (scope.done);
  });

  it ('parses front face of double-faced card specified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Afflicted%20Deserter')
    .replyWithFile (200, path.join (fixtures$cards, 'afflicted-deserter~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Afflicted%20Deserter')
    .replyWithFile (200, path.join (fixtures$cards, 'afflicted-deserter~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Afflicted%20Deserter')
    .replyWithFile (200, path.join (fixtures$cards, 'afflicted-deserter~printings.html'));

    return tutor.card ({name: 'Afflicted Deserter'})
    .then (card => {
      eq (card.name, 'Afflicted Deserter');
    })
    .finally (scope.done);
  });

  it ('parses back face of double-faced card specified by name', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Werewolf%20Ransacker')
    .replyWithFile (200, path.join (fixtures$cards, 'werewolf-ransacker~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Werewolf%20Ransacker')
    .replyWithFile (200, path.join (fixtures$cards, 'werewolf-ransacker~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Werewolf%20Ransacker')
    .replyWithFile (200, path.join (fixtures$cards, 'werewolf-ransacker~printings.html'));

    return tutor.card ({name: 'Werewolf Ransacker'})
    .then (card => {
      eq (card.name, 'Werewolf Ransacker');
    })
    .finally (scope.done);
  });

  it ('parses back face of double-faced card specified by lower-case name', () => {  // #57
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=Werewolf%20Ransacker')
    .replyWithFile (200, path.join (fixtures$cards, 'werewolf-ransacker~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Werewolf%20Ransacker')
    .replyWithFile (200, path.join (fixtures$cards, 'werewolf-ransacker~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Werewolf%20Ransacker')
    .replyWithFile (200, path.join (fixtures$cards, 'werewolf-ransacker~printings.html'));

    return tutor.card ({name: 'Werewolf Ransacker'})
    .then (card => {
      eq (card.name, 'Werewolf Ransacker');
    })
    .finally (scope.done);
  });

  it ('parses front face of double-faced card specified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=262675')
    .replyWithFile (200, path.join (fixtures$cards, '262675~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=262675')
    .replyWithFile (200, path.join (fixtures$cards, '262675~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=262675')
    .replyWithFile (200, path.join (fixtures$cards, '262675~printings.html'));

    return tutor.card ({id: 262675})
    .then (card => {
      eq (card.name, 'Afflicted Deserter');
    })
    .finally (scope.done);
  });

  it ('parses back face of double-faced card specified by id', () => {
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?multiverseid=262698')
    .replyWithFile (200, path.join (fixtures$cards, '262698~details.html'))
    .get ('/Pages/Card/Languages.aspx?multiverseid=262698')
    .replyWithFile (200, path.join (fixtures$cards, '262698~languages.html'))
    .get ('/Pages/Card/Printings.aspx?multiverseid=262698')
    .replyWithFile (200, path.join (fixtures$cards, '262698~printings.html'));

    return tutor.card ({id: 262698})
    .then (card => {
      eq (card.name, 'Werewolf Ransacker');
    })
    .finally (scope.done);
  });

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
    .replyWithFile (200, path.join (fixtures$cards, '159132~details.html'))
    .get ('/Pages/Card/Details.aspx?multiverseid=159132')
    .replyWithFile (200, path.join (fixtures$cards, '159132~details.html'))
    .get ('/Pages/Card/Details.aspx?multiverseid=159132')
    .replyWithFile (200, path.join (fixtures$cards, '159132~details.html'))
    .get ('/Pages/Card/Details.aspx?name=Juz%C3%A1m%20Djinn')
    .replyWithFile (200, path.join (fixtures$cards, 'juzam-djinn~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=Juz%C3%A1m%20Djinn')
    .replyWithFile (200, path.join (fixtures$cards, 'juzam-djinn~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=Juz%C3%A1m%20Djinn')
    .replyWithFile (200, path.join (fixtures$cards, 'juzam-djinn~printings.html'));

    return tutor.card ('Juzam Djinn')
    .then (card => {
      eq (card.name, 'Juzám Djinn');
    })
    .finally (scope.done);
  });

  it ('responds with "no results" given non-existent card name', () => {  // #90
    const scope = nock ('https://gatherer.wizards.com')
    .get ('/Pages/Card/Details.aspx?name=fizzbuzzldspla')
    .replyWithFile (200, path.join (fixtures$cards, 'fizzbuzzldspla~details.html'))
    .get ('/Pages/Card/Languages.aspx?name=fizzbuzzldspla')
    .replyWithFile (200, path.join (fixtures$cards, 'fizzbuzzldspla~languages.html'))
    .get ('/Pages/Card/Printings.aspx?name=fizzbuzzldspla')
    .replyWithFile (200, path.join (fixtures$cards, 'fizzbuzzldspla~printings.html'));

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
      const formats = stdout.split ('\n');
      assert (formats.includes ('Vintage'));
    })
  );

  it ('prints JSON representation of formats',
    $ ('tutor formats --format json', (err, stdout) => {
      eq (err, null);
      const formats = JSON.parse (stdout);
      assert (formats.includes ('Vintage'));
    })
  );

});


describe ('$ tutor sets', () => {

  it ('prints sets',
    $ ('tutor sets', (err, stdout) => {
      eq (err, null);
      const sets = stdout.split ('\n');
      assert (sets.includes ('Stronghold'));
    })
  );

  it ('prints JSON representation of sets',
    $ ('tutor sets --format json', (err, stdout) => {
      eq (err, null);
      const sets = JSON.parse (stdout);
      assert (sets.includes ('Stronghold'));
    })
  );

});


describe ('$ tutor types', () => {

  it ('prints types',
    $ ('tutor types', (err, stdout) => {
      eq (err, null);
      const types = stdout.split ('\n');
      assert (types.includes ('Enchantment'));
    })
  );

  it ('prints JSON representation of types',
    $ ('tutor types --format json', (err, stdout) => {
      eq (err, null);
      const types = JSON.parse (stdout);
      assert (types.includes ('Enchantment'));
    })
  );

});


describe ('$ tutor set', () => {

  it ('prints summary of cards in set',
    $ ('tutor set Alliances | head -n 3', (err, stdout) => {
      eq (err, null);
      eq (stdout,
          "Aesthir Glider {3} 2/1 Flying Aesthir Glider can't block.\n" +
          'Agent of Stromgald {R} 1/1 {R}: Add {B}.\n' +
          'Arcane Denial {1}{U} Counter target spell. Its controller may ' +
          "draw up to two cards at the beginning of the next turn's upkeep. " +
          "You draw a card at the beginning of the next turn's upkeep.\n");
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
      eq ((JSON.parse (stdout)).name, 'Fireball');
    })
  );

  it ('prints JSON representation of card specified by id',
    $ ('tutor card 987 --format json', (err, stdout) => {
      eq (err, null);
      eq ((JSON.parse (stdout)).artist, 'Brian Snoddy');
    })
  );

});
