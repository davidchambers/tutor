'use strict';

const https         = require ('https');
const url           = require ('url');

const cheerio       = require ('cheerio');
const entities      = require ('entities');


const tutor = module.exports;

//    I :: a -> a
const I = x => x;

//    T :: a -> (a -> b) -> b
const T = x => f => f (x);

//    any :: (a -> Boolean) -> Array a -> Boolean
const any = pred => xs => xs.some (x => pred (x));

//    attr :: String -> Cheerio -> String
const attr = name => x => x.attr (name);

//    chain :: (a -> Array b) -> Array a -> Array b
const chain = f => xs => {
  const result = [];
  xs.forEach (x => { Array.prototype.push.apply (result, f (x)); });
  return result;
};

//    children :: Cheerio -> Array Cheerio
const children = x => toArray (x.children ());

//    complement :: (a -> Boolean) -> a -> Boolean
const complement = pred => x => !(pred (x));

//    concat :: Semigroup a => a -> a -> a
const concat = x => y => x.concat (y);

//    eq :: Integer -> Cheerio -> Cheerio
const eq = n => x => x.eq (n);

//    filter :: (a -> Boolean) -> Array a -> Array a
const filter = pred => xs => xs.filter (x => pred (x));

//    find :: String -> Cheerio -> Cheerio
const find = sel => x => x.find (sel);

//    finds :: Array String -> Cheerio -> Cheerio
const finds = sels => x => sels.reduce ((x, sel) => x.find (sel), x);

//    flip :: (a -> b -> c) -> b -> a -> c
const flip = f => y => x => f (x) (y);

//    joinWith :: String -> Array String -> String
const joinWith = sep => ss => ss.join (sep);

//    last :: NonEmpty (Array a) -> a
const last = xs => xs[xs.length - 1];

//    map :: (a -> b) -> Array a -> Array b
const map = f => xs => xs.map (x => f (x));

//    max :: Ord a => a -> a -> a
const max = x => y => x > y ? x : y;

//    min :: Ord a => a -> a -> a
const min = x => y => x < y ? x : y;

//    next :: Cheerio -> Cheerio
const next = x => x.next ();

//    parent :: Cheerio -> Cheerio
const parent = x => x.parent ();

//    pipe :: Array (Any -> Any) -> a -> b
const pipe = fs => x => fs.reduce ((x, f) => f (x), x);

//    prop :: String -> a -> b
const prop = key => x => {
  const obj = x == null ? Object.create (null) : Object (x);
  if (key in obj) return obj[key];
  throw new TypeError (
    `‘prop’ expected object to have a property named ‘${key}’`
  );
};

//    range :: Integer -> Integer -> Array Integer
const range = lower => upper => {
  const result = [];
  for (let n = lower; n < upper; n += 1) result.push (n);
  return result;
};

//    reduce :: (b -> a -> b) -> b -> Array a -> b
const reduce = f => y => xs => xs.reduce ((y, x) => f (y) (x), y);

//    replace :: GlobalRegExp -> String -> String -> String
const replace = pat => rep => s => s.replace (pat, rep);

//    sort :: Ord a => Array a -> Array a
const sort = xs => sortBy (I) (xs);

//    sortBy :: Ord b => (a -> b) -> Array a -> Array a
const sortBy = f => xs =>
  xs.slice ()
    .sort ((x, y) => {
      const fx = f (x);
      const fy = f (y);
      return fx < fy ? -1 : fx > fy ? 1 : 0;
    });

//    splitOn :: String -> String -> Array String
const splitOn = sep => s => s.split (sep);

//    splitOnRegex :: GlobalRegExp -> String -> Array String
const splitOnRegex = sep => s => s.split (sep);

//    startsWith :: String -> String -> Boolean
const startsWith = sub => s => s.startsWith (sub);

//    strip :: GlobalRegExp -> String -> String
const strip = pat => s => s.replace (pat, '');

//    text :: Cheerio -> String
const text = x => x.text ();

//    toArray :: Cheerio -> Array Cheerio
const toArray = x => map (cheerio) (x.toArray ());

//    toLower :: String -> String
const toLower = s => s.toLowerCase ();

//    trim :: String -> String
const trim = s => s.trim ();

//    words :: String -> Array String
const words = s => {
  const words = s.split (/\s+/);
  const len = words.length;
  return words.slice (words[0] === '' ? 1 : 0,
                      words[len - 1] === '' ? len - 1 : len);
};

const symbols = {
  /* eslint-disable key-spacing */
  'White':                'W',
  'Blue':                 'U',
  'Black':                'B',
  'Red':                  'R',
  'Green':                'G',
  'Two':                  '2',
  'Colorless':            'C',
  'Snow':                 'S',
  'Tap':                  'T',
  'Untap':                'Q',
  'Variable Colorless':   'X',
  'Phyrexian White':      'W/P',
  'Phyrexian Blue':       'U/P',
  'Phyrexian Black':      'B/P',
  'Phyrexian Red':        'R/P',
  'Phyrexian Green':      'G/P',
  /* eslint-enable key-spacing */
};

const origin = 'https://gatherer.wizards.com';

function request(uri) {
  return new Promise ((resolve, reject) => {
    const req = https.request (uri, res => {
      if (res.statusCode === 302) {
        request (origin + res.headers.location)
        .then (resolve, reject);
      } else {
        let body = '';
        res.setEncoding ('utf8');
        res.on ('data', chunk => { body += chunk; });
        res.on ('end', () => { resolve (cheerio.load (body)); });
      }
    });
    req.on ('error', err => { reject (err); });
    req.end ();
  });
}

const gatherer$card = details => {
  if ('which' in details && (details.which !== 'a' && details.which !== 'b')) {
    return Promise.reject (
      new Error ('invalid which property (valid values are "a" and "b")')
    );
  }
  return request (
    origin + '/Pages/Card/Details.aspx?' +
    ('id' in details ? 'multiverseid=' + encodeURIComponent (details.id)
                     : 'name=' + encodeURIComponent (details.name))
  )
  .then ($ => startsWith ('Card Search - Search:')
                         (trim (text ($ ('title')))) ?
              Promise.reject (new Error ('no results')) :
              Promise.resolve (extract_jkl ($, details)));
};

const extract_jkl = ($, details) => {
  const verbose = 'id' in details;
  const t1 = el => gatherer$_get_text (next ($ (el)));
  const card = {
    converted_mana_cost: 0,
    supertypes: [],
    types: [],
    subtypes: [],
    rulings: map ($el => {
                    const [$date, $ruling] = children ($el);
                    const [m, d, y] = splitOn ('/') (trim (text ($date)));
                    const pad = s => `0${s}`.slice (-2);
                    return [
                      `${y}-${pad (m)}-${pad (d)}`,
                      replace (/[ ]{2,}/g) (' ') (trim (text ($ruling))),
                    ];
                  })
                 (toArray (find ('tr.post') ($ ('.discussion')))),
  };
  const get_versions = pipe ([
    find ('.label:contains("Expansion:")'),
    next,
    find ('img'),
    gatherer$_get_versions,
  ]);
  const $side = (() => {
    const [$left, $right] = toArray ($ ('.cardComponentContainer'));
    if (
      details.which === 'b' ||

      verbose &&
      (details.id in get_versions ($right) &&
       !(details.id in get_versions ($left))) ||

      (details.name != null ? toLower (details.name) : undefined) ===
      toLower (trim (text (next (find ('.label:contains("Card Name:")')
                                      ($right)))))
    ) {
      return $right;
    } else {
      return $left;
    }
  }) ();
  find ('.label') ($side)
  .each (function() {
    const $el = $ (this);
    const label = trim (text ($el));
    if (label === 'Card Name:') {
      card.name = trim (text (next ($el)));
    } else if (label === 'Mana Cost:') {
      card.mana_cost = gatherer$_get_text (next ($el));
    } else if (label === 'Converted Mana Cost:') {
      card.converted_mana_cost = Number (t1 ($el));
    } else if (label === 'Types:') {
      const [, types, subtypes = ''] =
        /^(.+?)(?:\s+\u2014\s+(.+))?$/.exec (t1 ($el));
      //    filter_asdf :: (String -> Boolean) -> Array String
      const filter_asdf = flip (filter) (words (types));
      //    supertype :: String -> Boolean
      const supertype = type => supertypes.has (type);
      card.supertypes = filter_asdf (supertype);
      card.types = filter_asdf (complement (supertype));
      card.subtypes = words (subtypes);
    } else if (label === 'Card Text:') {
      card.text = joinWith ('\n\n')
                           (map (gatherer$_get_text)
                                (children (next ($el))));
    } else if (label === 'Flavor Text:' && verbose) {
      const $flavor = next ($el);
      const $el2 = last (children ($flavor));
      let match = /^(\u2014|\u2015\u2015|\uFF5E)\s*(.+)$/
                  .exec (trim (text ($el2)));
      if (match != null) {
        card.flavor_text_attribution = match[2];
        $el2.remove ();
      }
      const pattern =
        /^["\u00AB\u201E\u300C]\s*(.+?)\s*["\u00BB\u300D]([.]?)$/;
      let text_asdf = joinWith ('\n')
                               (map (gatherer$_get_text)
                                    (children ($flavor)));
      if (match && (match = pattern.exec (text))) {
        text_asdf = match[1] + match[2];
      }
      card.flavor_text = text_asdf;
    } else if (label === 'Color Indicator:') {
      card.color_indicator = t1 ($el);
    } else if (label === 'Watermark:') {
      card.watermark = t1 ($el);
    } else if (label === 'P/T:') {
      const [, power, toughness] = /^(.+?)\s+[/]\s+(.+)$/.exec (t1 ($el));
      card.power = gatherer$_to_stat (power);
      card.toughness = gatherer$_to_stat (toughness);
    } else if (label === 'Loyalty:') {
      card.loyalty = Number (t1 ($el));
    } else if (label === 'Hand/Life:') {
      const text_asdf = t1 ($el);
      card.hand_modifier =
        Number (text_asdf.match (/Hand Modifier: ([+-]\d+)/)[1]);
      card.life_modifier =
        Number (text_asdf.match (/Life Modifier: ([+-]\d+)/)[1]);
    } else if (label === 'Expansion:' && verbose) {
      card.expansion = trim (text (find ('a:last-child') (next ($el))));
    } else if (label === 'Rarity:' && verbose) {
      card.rarity = t1 ($el);
    } else if (label === 'Card Number:' && verbose) {
      card.number = gatherer$_to_stat (t1 ($el));
    } else if (label === 'Artist:' && verbose) {
      card.artist = t1 ($el);
    } else if (label === 'All Sets:') {
      card.versions = gatherer$_get_versions (find ('img') (next ($el)));
    }
  });
  const [, rating, votes] =
    /^CommunityRating:(\d(?:[.]\d+)?)[/]5[(](\d+)votes?[)]$/
    .exec (strip (/\s+/g) (text (find ('.textRating') ($side))));
  card.community_rating = {
    rating: Number (rating),
    votes: Number (votes),
  };
  if (verbose) {
    card.image_url =
      `${origin}/Handlers/Image.ashx?type=card&multiverseid=${details.id}`;
    card.gatherer_url =
      `${origin}/Pages/Card/Details.aspx?multiverseid=${details.id}`;
  } else {
    const encodedName = replace (/'/g)
                                ('%27')
                                (encodeURIComponent (details.name));
    card.image_url =
      `${origin}/Handlers/Image.ashx?type=card&name=${encodedName}`;
    card.gatherer_url =
      `${origin}/Pages/Card/Details.aspx?name=${encodedName}`;
  }
  return card;
};

const languages = {
  'Chinese Simplified': 'zh-TW',
  'Chinese Traditional': 'zh-CN',
  'English': 'en',
  'French': 'fr',
  'German': 'de',
  'Italian': 'it',
  'Japanese': 'ja',
  'Korean': 'kr',
  'Portuguese (Brazil)': 'pt-BR',
  'Portuguese': 'pt-BR',
  'Russian': 'ru',
  'Spanish': 'es',
};

const pagination = $container => {
  const $links = $container.children ('a');
  const $selected = $links.filter ('[style="text-decoration:underline;"]');
  const numbers =
    map (x => Number ((url.parse (attr ('href') (x), true)).query.page) + 1)
        (toArray ($links));
  return {
    min: reduce (min) (1) (numbers),
    max: reduce (max) (1) (numbers),
    selected: $selected.length ? Number (gatherer$_get_text ($selected)) : 1,
  };
};

//    paginationSelector :: String
const paginationSelector =
  '#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_' +
  'languageList_pagingControls';

//    fetch :: StrMap String -> Integer -> Promise $
const fetch = ({id, name}) => page => {
  let url = origin + '/Pages/Card/Languages.aspx?';
  if (id != null) {
    url += 'multiverseid=' + encodeURIComponent (id) + '&';
  } else {
    url += 'name=' + encodeURIComponent (name) + '&';
  }
  if (page > 1) {
    url += 'page=' + String (page - 1) + '&';
  }
  return request (strip (/&$/) (url));
};

//    languages
//    :: StrMap String
//    -> Promise (StrMap { name :: String, ids :: Array Integer })
const gatherer$languages = details =>
  fetch (details) (1)
  .then ($ => Promise.all (map (fetch (details))
                               (range (2)
                                      (prop ('max')
                                            (pagination
                                               ($ (paginationSelector))) + 1)))
              .then (concat ([$])))
  .then (map (T ('tr.cardItem')))
  .then (chain (toArray))
  .then (map (children))
  .then (map (([fst, snd]) => ({
                code: languages[trim (text (snd))],
                name: trim (text (fst)),
                id: gatherer$_id_from_link (find ('a') (fst)),
              })))
  .then (sortBy (prop ('id')))
  .then (rs => reduce (map => ({code, id, name}) => {
                         if (!(code in map)) map[code] = {name, ids: []};
                         map[code].ids.push (id);
                         return map;
                       })
                      (Object.create (null))
                      (rs));

const gatherer$printings = ({id, name}) =>
  request (
    origin + '/Pages/Card/Printings.aspx?' +
    (id == null ? 'name=' + encodeURIComponent (name)
                : 'multiverseid=' + encodeURIComponent (id))
  )
  .then (extract_asdf);

const extract_asdf = $ => {
  const prefix = '#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent';

  const legality = {};
  for (let row = parent ($ (prefix +
                            '_LegalityList_listRepeater' +
                            '_ctl00_ConditionTableData'));
       row.hasClass ('cardItem');
       row = next (row)) {
    const cells = children (row);
    const format = gatherer$_get_text (cells[0]);
    const legality_ = gatherer$_get_text (cells[1]);
    legality[format] = legality_;
  }

  const versions = {};
  for (let row = parent (parent ($ (prefix +
                                    '_PrintingsList_listRepeater' +
                                    '_ctl00_cardTitle')));
       row.hasClass ('cardItem');
       row = next (row)) {
    const id = gatherer$_id_from_link (find ('a') (row));
    const expansion = gatherer$_get_text ((children (row))[2]);
    const rarity = strip (/[)].*$/g)
                         (strip (/^.*[(]/g)
                                (attr ('alt') (find ('img') (row))));
    versions[String (id)] = {expansion, rarity};
  }

  return {legality, versions};
};

const supertypes = new Set ([
  'Basic',
  'Legendary',
  'Ongoing',
  'Snow',
  'World',
]);

tutor.set = name => {
  const common_params = {
    action: 'advanced',
    output: 'standard',
    set: `["${name}"]`,
    sort: 'cn+',
  };
  const query = Object.assign ({page: '0'}, common_params);
  return request (
    strip (/&$/)
          (reduce (url => key =>
                     url + key + '=' +
                     encodeURIComponent (query[key]) + '&')
                  (origin + '/Pages/Search/Default.aspx?')
                  (sort (Object.keys (query))))
  )
  .then (
    $ => {
      const {min, max} = pagination ($ ('#ctl00_ctl00_ctl00_' +
                                        'MainContent_SubContent_' +
                                        'topPagingControlsContainer'));
      return Promise.all (
        map (page => {
               const query = Object.assign ({page}, common_params);
               return request (
                 strip (/&$/)
                       (reduce (url => key =>
                                  url + key + '=' +
                                  encodeURIComponent (query[key]) + '&')
                               (origin + '/Pages/Search/Default.aspx?')
                               (sort (Object.keys (query))))
               );
             })
            (map (String) (range (min) (max)))
      )
      .then (concat ([$]))
      .then (chain (pipe ([
        T ('.cardItem'),
        toArray,
        filter (pipe ([versions, any (startsWith (`${name} (`))])),
        map (extract_card (name)),
        map (version => Object.assign ({expansion: name}, version)),
      ])));
    }
  );
};

//    versions :: Cheerio -> Array String
const versions = pipe ([
  finds (['.setVersions', 'img']),
  toArray,
  map (attr ('alt')),
]);

const extract_card = set_name => $card => {
  let match;
  const param =
    `multiverseid=${gatherer$_id_from_link (find ('a') ($card))}`;
  const card$ = {
    supertypes: [],
    types: [],
    subtypes: [],
    text: joinWith ('\n\n')
                   (map (gatherer$_get_text)
                        (toArray (finds (['.rulesText', 'p']) ($card)))),
    gatherer_url: `${origin}/Pages/Card/Details.aspx?${param}`,
    image_url: `${origin}/Handlers/Image.ashx?${param}&type=card`,
    versions: reduce (m => alt => {
                        const match = /^(.*) [(](.*?)[)]$/.exec (alt);
                        m[match[1]] = match[2];
                        return m;
                      })
                     ({})
                     (versions ($card)),
  };
  const name = trim (text (find ('.cardTitle') ($card)));
  const name_match = /[(](.*)[)]$/.exec (name);
  card$.name = (name_match != null) &&
               (set_name !== 'Unglued' && set_name !== 'Unhinged')
               ? name_match[1]
               : name;
  const mana_cost = gatherer$_get_text (find ('.manaCost') ($card));
  if (mana_cost !== '') {
    card$.mana_cost = mana_cost;
  }
  card$.converted_mana_cost = to_converted_mana_cost (mana_cost);
  const lines = map (trim)
                    ((text (find ('.typeLine') ($card)))
                     .match (/^.*$/gm));
  const stats = lines[4].slice (1, -1);
  if (lines[2] === 'Vanguard') {
    [card$.hand_modifier, card$.life_modifier] =
      map (gatherer$_to_stat) (splitOn ('/') (stats));
  } else {
    if (/^\d+$/.test (stats)) {
      card$.loyalty = Number (stats);
    } else if ((match = /^((?:[{][^}]*[}]|[^/])*)[/](.*)$/.exec (stats))) {
      [card$.power, card$.toughness] =
        map (gatherer$_to_stat) (match.slice (1));
    }
    const [types, subtypes] = map (trim) (splitOn ('\u2014') (lines[2]));
    (splitOn (' ') (types)).forEach (type => {
      if (supertypes.has (type)) {
        card$.supertypes.push (type);
      } else {
        card$.types.push (type);
      }
    });
    if (subtypes != null) card$.subtypes = splitOn (' ') (subtypes);
    const prefix = `${set_name} (`;
    const alts = versions ($card);
    for (let idx = 0; idx < alts.length; idx += 1) {
      const alt = alts[idx];
      if (alt.startsWith (prefix)) {
        card$.rarity = alt.substring (prefix.length, alt.length - 1);
        break;
      }
    }
  }
  return card$;
};

const converted_mana_costs = {
  /* eslint-disable object-property-newline */
  '{X}': 0, '{4}': 4, '{10}': 10, '{16}': 16, '{2/W}': 2,
  '{Y}': 0, '{5}': 5, '{11}': 11, '{17}': 17, '{2/U}': 2,
  '{Z}': 0, '{6}': 6, '{12}': 12, '{18}': 18, '{2/B}': 2,
  '{0}': 0, '{7}': 7, '{13}': 13, '{19}': 19, '{2/R}': 2,
  '{2}': 2, '{8}': 8, '{14}': 14, '{20}': 20, '{2/G}': 2,
  '{3}': 3, '{9}': 9, '{15}': 15,
  /* eslint-enable object-property-newline */
};

const to_converted_mana_cost = pipe ([
  splitOnRegex (/(?=[{])/g),
  reduce (cmc => symbol =>
            cmc +
            (Object.prototype.hasOwnProperty.call (converted_mana_costs,
                                                   symbol) ?
             converted_mana_costs[symbol] :
             1))
         (0),
]);

function to_symbol(alt) {
  const m = /^(\S+) or (\S+)$/.exec (alt);
  return m && `${to_symbol (m[1])}/${to_symbol (m[2])}` || symbols[alt] || alt;
}

const gatherer$_get_text = node => {
  const clone = node.clone ();
  const imgs = find ('img') (clone);
  for (let idx = 0; idx < imgs.length; idx += 1) {
    const img = eq (idx) (imgs);
    img.replaceWith ('{' + to_symbol (attr ('alt') (img)) + '}');
  }
  return trim (text (clone));
};

const gatherer$_get_versions = image_nodes =>
  reduce (versions => $el => {
            const match = /^(.*) [(](.*?)[)]$/.exec (attr ('alt') ($el));
            versions[String (gatherer$_id_from_link (parent ($el)))] = {
              expansion: entities.decode (match[1]),
              rarity: match[2],
            };
            return versions;
          })
         ({})
         (toArray (image_nodes));

const gatherer$_id_from_link = a =>
  Number (prop ('multiverseid')
               (prop ('query')
                     (url.parse (attr ('href') (a), true))));

const gatherer$_to_stat = str => {
  const num = Number (replace (/[{]1[/]2[}]|½/g) ('.5') (str));
  return Number.isNaN (num) ? str : num;
};

const collect_options = label => () =>
  request (origin + '/Pages/Default.aspx')
  .then (T ('#ctl00_ctl00_MainContent_Content_SearchControls_' +
            label +
            'AddText'))
  .then (children)
  .then (map (attr ('value')))
  .then (map (entities.decode));

//    formats :: () -> Promise ???
tutor.formats = collect_options ('format');

//    sets :: () -> Promise ???
tutor.sets = collect_options ('set');

//    types :: () -> Promise ???
tutor.types = collect_options ('type');

tutor.card = function recur(spec) {
  const details = typeof spec === 'number' ? {id: spec} :
                  typeof spec === 'string' ? {name: spec} :
                                             spec;
  return Promise.all ([
    gatherer$card (details),
    gatherer$languages (details),
    gatherer$printings (details),
  ])
  .then (([card, languages, {legality, versions}]) =>
    // If card.name and details.name differ, requests were redirected
    // (e.g. "Juzam Djinn" => "Juzám Djinn"). Resend requests with the
    // correct name to get languages, legality, and versions.
    'name' in details && card.name !== details.name ?
    recur (Object.assign ({}, details, {name: card.name})) :
    Promise.resolve (Object.assign ({languages, legality, versions}, card))
  );
};
