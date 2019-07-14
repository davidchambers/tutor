'use strict';

const cheerio = require ('cheerio');

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
  var card, encodedName, set, t, t1, verbose;
  verbose = 'id' in details;
  t = el => gatherer._get_text ($ (el));
  t1 = el => gatherer._get_text (U.next ($ (el)));
  card = {
    converted_mana_cost: 0,
    supertypes: [],
    types: [],
    subtypes: [],
    rulings: U.map ($el => {
                      var d, date, m, pad, ruling, y, _ref, _ref1;
                      _ref = U.children ($el), date = _ref[0], ruling = _ref[1];
                      _ref1 = U.splitOn ('/') (U.trim (U.text ($ (date)))), m = _ref1[0], d = _ref1[1], y = _ref1[2];
                      pad = s => `0${s}`.substr (-2);
                      return [
                        `${y}-${pad(m)}-${pad(d)}`,
                        U.replace (/[ ]{2,}/g) (' ') (U.trim (U.text ($ (ruling)))),
                      ];
                    })
                   (U.toArray (U.find ('tr.post') ($ ('.discussion')))),
  };
  set = gatherer._set.bind (null, card);
  const get_versions = U.pipe ([
    $,
    U.find ('.label'),
    labels => labels.filter ((_, label) => U.trim (U.text ($ (label)))
                                           === 'Expansion:'),
    U.next,
    U.find ('img'),
    gatherer._get_versions,
  ]);
  $ ((() => {
    // XXX
    const _ref = $ ('.cardComponentContainer');
    const left = _ref[0];
    const right = _ref[1];
    return (
      details.which === 'b' ?
        left :
      verbose &&
      (details.id in get_versions (right) &&
       !(details.id in get_versions (left))) ?
        left :
      (details.name != null ? details.name.toLowerCase () : undefined) === $(right).find('.label').filter((idx, el) => U.trim (U.text ($ (el))) === 'Card Name:').next().text().trim().toLowerCase() ?
        left :
      // else
        right
    );
  }) ()).remove ();
  $('.label').each(function() {
    var $el, $flavor, match, pattern, power, subtypes, text, toughness, type, types, _i, _j, _len, _ref, _ref1, _ref2;
    $el = $ (this);
    switch (U.trim (U.text ($el))) {
      case 'Card Name:':
        set ('name', U.trim (U.text (U.next ($el))));
        break;
      case 'Mana Cost:':
        set ('mana_cost', gatherer._get_text (U.next ($el)));
        break;
      case 'Converted Mana Cost:':
        set ('converted_mana_cost', Number (t1 ($el)));
        break;
      case 'Types:':
        _ref = /^(.+?)(?:\s+\u2014\s+(.+))?$/.exec(t1($el)), _i = _ref.length - 2, types = _ref[_i++], subtypes = _ref[_i++];
        _ref1 = U.splitOnRegex (/\s+/g) (types);
        for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
          type = _ref1[_j];
          card[supertypes.includes (type) ? 'supertypes' : 'types'].push (type);
        }
        set ('subtypes', subtypes == null ? [] : U.splitOnRegex (/\s+/g) (subtypes));
        break;
      case 'Card Text:':
        set ('text', gatherer._get_rules_text (gatherer._get_text) (U.next ($el)));
        break;
      case 'Flavor Text:':
        if (!verbose) break;
        $flavor = U.next ($el);
        $el = U.last (U.children ($flavor));
        match = /^(\u2014|\u2015\u2015|\uFF5E)\s*(.+)$/.exec (U.trim (U.text ($el)));
        if (match != null) {
          set ('flavor_text_attribution', match[2]);
          $el.remove ();
        }
        pattern = /^["\u00AB\u201E\u300C]\s*(.+?)\s*["\u00BB\u300D]([.]?)$/;
        text = U.joinWith ('\n')
                          (U.map (gatherer._get_text) (U.children ($flavor)));
        if (match && (match = pattern.exec (text))) {
          text = match[1] + match[2];
        }
        set ('flavor_text', text);
        break;
      case 'Color Indicator:':
        set ('color_indicator', t1 ($el));
        break;
      case 'Watermark:':
        set ('watermark', t1 ($el));
        break;
      case 'P/T:':
        [, power, toughness] = /^(.+?)\s+[/]\s+(.+)$/.exec (t1 ($el));
        set ('power', gatherer._to_stat (power));
        set ('toughness', gatherer._to_stat (toughness));
        break;
      case 'Loyalty:':
        set ('loyalty', Number (t1 ($el)));
        break;
      case 'Hand/Life:':
        text = t1 ($el);
        set ('hand_modifier', Number (text.match (/Hand Modifier: ([+-]\d+)/)[1]));
        set ('life_modifier', Number (text.match (/Life Modifier: ([+-]\d+)/)[1]));
        break;
      case 'Expansion:':
        if (verbose) {
          set ('expansion',
               U.trim (U.text (U.find ('a:last-child') (U.next ($el)))));
        }
        break;
      case 'Rarity:':
        if (verbose) {
          set ('rarity', t1 ($el));
        }
        break;
      case 'Card Number:':
        if (verbose) {
          set ('number', gatherer._to_stat (t1 ($el)));
        }
        break;
      case 'Artist:':
        if (verbose) {
          set ('artist', t1 ($el));
        }
        break;
      case 'All Sets:':
        set ('versions',
             gatherer._get_versions (U.find ('img') (U.next ($el))));
        break;
    }
  });
  const [, rating, votes] = /^CommunityRating:(\d(?:[.]\d+)?)[/]5[(](\d+)votes?[)]$/.exec ((U.text ($ ('.textRating'))).replace (/\s+/g, ''));
  set ('community_rating', {
    rating: Number (rating),
    votes: Number (votes),
  });
  if (verbose) {
    set ('image_url', `${gatherer.origin}/Handlers/Image.ashx?type=card&multiverseid=${details.id}`);
    set ('gatherer_url', `${gatherer.origin}/Pages/Card/Details.aspx?multiverseid=${details.id}`);
  } else {
    encodedName = (encodeURIComponent (details.name)).replace (/'/g, '%27');
    set ('image_url', `${gatherer.origin}/Handlers/Image.ashx?type=card&name=${encodedName}`);
    set ('gatherer_url', `${gatherer.origin}/Pages/Card/Details.aspx?name=${encodedName}`);
  }
  return card;
};

module.exports.url = (path, ...rest) => {
  const {id, name, page} = Object.assign ({}, ...rest);
  const query = {};
  if (id != null) {
    query.multiverseid = id;
  } else {
    query.name = name;
  }
  if (page > 1) {
    query.page = page - 1;
  }
  return gatherer.url ('/Pages/Card/' + path, query);
};
