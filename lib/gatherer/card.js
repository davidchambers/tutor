'use strict';

const gatherer = require ('../gatherer');
const supertypes = require ('../supertypes');
const U = require ('../util');


module.exports = details => {
  if ('which' in details && (details.which !== 'a' && details.which !== 'b')) {
    return Promise.reject (
      new Error ('invalid which property (valid values are "a" and "b")')
    );
  }
  return gatherer.request (gatherer.card.url ('Details.aspx', details))
    .then ($ => U.startsWith ('Card Search - Search:')
                             (U.trim (U.text ($ ('title')))) ?
                Promise.reject (new Error ('no results')) :
                Promise.resolve (extract ($, details)));
};

const extract = ($, details) => {
  const verbose = 'id' in details;
  const t1 = el => gatherer._get_text (U.next ($ (el)));
  const card = {
    converted_mana_cost: 0,
    supertypes: [],
    types: [],
    subtypes: [],
    rulings: U.map ($el => {
                      const [$date, $ruling] = U.children ($el);
                      const [m, d, y] = U.splitOn ('/')
                                                  (U.trim (U.text ($date)));
                      const pad = s => `0${s}`.slice (-2);
                      return [
                        `${y}-${pad (m)}-${pad (d)}`,
                        U.replace (/[ ]{2,}/g)
                                  (' ')
                                  (U.trim (U.text ($ruling))),
                      ];
                    })
                   (U.toArray (U.find ('tr.post') ($ ('.discussion')))),
  };
  const get_versions = U.pipe ([
    U.find ('.label:contains("Expansion:")'),
    U.next,
    U.find ('img'),
    gatherer._get_versions,
  ]);
  const $side = (() => {
    const [$left, $right] = U.toArray ($ ('.cardComponentContainer'));
    if (
      details.which === 'b' ||

      verbose &&
      (details.id in get_versions ($right) &&
       !(details.id in get_versions ($left))) ||

      (details.name != null ? U.toLower (details.name) : undefined) ===
      U.toLower (U.trim (U.text (U.next (U.find
                                           ('.label:contains("Card Name:")')
                                           ($right)))))
    ) {
      return $right;
    } else {
      return $left;
    }
  }) ();
  U.find ('.label') ($side)
  .each (function() {
    const $el = $ (this);
    const label = U.trim (U.text ($el));
    if (label === 'Card Name:') {
      card.name = U.trim (U.text (U.next ($el)));
    } else if (label === 'Mana Cost:') {
      card.mana_cost = gatherer._get_text (U.next ($el));
    } else if (label === 'Converted Mana Cost:') {
      card.converted_mana_cost = Number (t1 ($el));
    } else if (label === 'Types:') {
      const [, types, subtypes = ''] =
        /^(.+?)(?:\s+\u2014\s+(.+))?$/.exec (t1 ($el));
      //    filter :: (String -> Boolean) -> Array String
      const filter = U.flip (U.filter) (U.words (types));
      //    supertype :: String -> Boolean
      const supertype = type => supertypes.has (type);
      card.supertypes = filter (supertype);
      card.types = filter (U.complement (supertype));
      card.subtypes = U.words (subtypes);
    } else if (label === 'Card Text:') {
      card.text = U.joinWith ('\n\n')
                             (U.map (gatherer._get_text)
                                    (U.children (U.next ($el))));
    } else if (label === 'Flavor Text:' && verbose) {
      const $flavor = U.next ($el);
      const $el2 = U.last (U.children ($flavor));
      let match = /^(\u2014|\u2015\u2015|\uFF5E)\s*(.+)$/
                  .exec (U.trim (U.text ($el2)));
      if (match != null) {
        card.flavor_text_attribution = match[2];
        $el2.remove ();
      }
      const pattern =
        /^["\u00AB\u201E\u300C]\s*(.+?)\s*["\u00BB\u300D]([.]?)$/;
      let text = U.joinWith ('\n')
                            (U.map (gatherer._get_text)
                                   (U.children ($flavor)));
      if (match && (match = pattern.exec (text))) {
        text = match[1] + match[2];
      }
      card.flavor_text = text;
    } else if (label === 'Color Indicator:') {
      card.color_indicator = t1 ($el);
    } else if (label === 'Watermark:') {
      card.watermark = t1 ($el);
    } else if (label === 'P/T:') {
      const [, power, toughness] = /^(.+?)\s+[/]\s+(.+)$/.exec (t1 ($el));
      card.power = gatherer._to_stat (power);
      card.toughness = gatherer._to_stat (toughness);
    } else if (label === 'Loyalty:') {
      card.loyalty = Number (t1 ($el));
    } else if (label === 'Hand/Life:') {
      const text = t1 ($el);
      card.hand_modifier = Number (text.match (/Hand Modifier: ([+-]\d+)/)[1]);
      card.life_modifier = Number (text.match (/Life Modifier: ([+-]\d+)/)[1]);
    } else if (label === 'Expansion:' && verbose) {
      card.expansion = U.trim (U.text (U.find ('a:last-child')
                                              (U.next ($el))));
    } else if (label === 'Rarity:' && verbose) {
      card.rarity = t1 ($el);
    } else if (label === 'Card Number:' && verbose) {
      card.number = gatherer._to_stat (t1 ($el));
    } else if (label === 'Artist:' && verbose) {
      card.artist = t1 ($el);
    } else if (label === 'All Sets:') {
      card.versions = gatherer._get_versions (U.find ('img') (U.next ($el)));
    }
  });
  const [, rating, votes] =
    /^CommunityRating:(\d(?:[.]\d+)?)[/]5[(](\d+)votes?[)]$/
    .exec (U.strip (/\s+/g) (U.text (U.find ('.textRating') ($side))));
  card.community_rating = {
    rating: Number (rating),
    votes: Number (votes),
  };
  if (verbose) {
    card.image_url =
      `${gatherer.origin}/Handlers/Image.ashx` +
      `?type=card&multiverseid=${details.id}`;
    card.gatherer_url =
      `${gatherer.origin}/Pages/Card/Details.aspx` +
      `?multiverseid=${details.id}`;
  } else {
    const encodedName = U.replace (/'/g)
                                  ('%27')
                                  (encodeURIComponent (details.name));
    card.image_url =
      `${gatherer.origin}/Handlers/Image.ashx?type=card&name=${encodedName}`;
    card.gatherer_url =
      `${gatherer.origin}/Pages/Card/Details.aspx?name=${encodedName}`;
  }
  return card;
};

module.exports.url = (path, ...rest) => {
  const {id, name, page} = Object.assign ({}, ...rest);
  let url = gatherer.origin + '/Pages/Card/' + path + '?';
  if (id != null) {
    url += 'multiverseid=' + encodeURIComponent (id) + '&';
  } else {
    url += 'name=' + encodeURIComponent (name) + '&';
  }
  if (page > 1) {
    url += 'page=' + String (page - 1) + '&';
  }
  return U.strip (/&$/) (url);
};
