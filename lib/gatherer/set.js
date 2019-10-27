'use strict';

const gatherer = require ('../gatherer');
const pagination = require ('../pagination');
const supertypes = require ('../supertypes');
const U = require ('../util');


module.exports = name => {
  const common_params = {
    action: 'advanced',
    output: 'standard',
    set: `["${name}"]`,
    sort: 'cn+',
  };
  const query = Object.assign ({page: '0'}, common_params);
  return gatherer.request (
    U.strip (/&$/)
            (U.reduce (url => key =>
                         url + key + '=' +
                         encodeURIComponent (query[key]) + '&')
                      (gatherer.origin + '/Pages/Search/Default.aspx?')
                      (U.sort (Object.keys (query))))
  )
  .then (
    $ => {
      const {min, max} = pagination ($ ('#ctl00_ctl00_ctl00_' +
                                        'MainContent_SubContent_' +
                                        'topPagingControlsContainer'));
      return Promise.all (
        U.map (page => {
                 const query = Object.assign ({page}, common_params);
                 return gatherer.request (
                   U.strip (/&$/)
                           (U.reduce (url => key =>
                                        url + key + '=' +
                                        encodeURIComponent (query[key]) + '&')
                                     (gatherer.origin +
                                      '/Pages/Search/Default.aspx?')
                                     (U.sort (Object.keys (query))))
                 );
               })
              (U.map (String) (U.range (min) (max)))
      )
      .then (U.concat ([$]))
      .then (U.chain (U.pipe ([
        U.T ('.cardItem'),
        U.toArray,
        U.filter (U.pipe ([versions, U.any (U.startsWith (`${name} (`))])),
        U.map (extract_card (name)),
        U.map (version => Object.assign ({expansion: name}, version)),
      ])));
    }
  );
};

//    versions :: Cheerio -> Array String
const versions = U.pipe ([
  U.finds (['.setVersions', 'img']),
  U.toArray,
  U.map (U.attr ('alt')),
]);

const extract_card = set_name => $card => {
  let match;
  const param =
    `multiverseid=${gatherer._id_from_link (U.find ('a') ($card))}`;
  const card$ = {
    supertypes: [],
    types: [],
    subtypes: [],
    text: U.joinWith ('\n\n')
                     (U.map (gatherer._get_text)
                            (U.toArray (U.finds (['.rulesText', 'p'])
                                                ($card)))),
    gatherer_url: `${gatherer.origin}/Pages/Card/Details.aspx?${param}`,
    image_url: `${gatherer.origin}/Handlers/Image.ashx?${param}&type=card`,
    versions: U.reduce (m => alt => {
                          const match = /^(.*) [(](.*?)[)]$/.exec (alt);
                          m[match[1]] = match[2];
                          return m;
                        })
                       ({})
                       (versions ($card)),
  };
  const name = U.trim (U.text (U.find ('.cardTitle') ($card)));
  const name_match = /[(](.*)[)]$/.exec (name);
  card$.name = (name_match != null) &&
               (set_name !== 'Unglued' && set_name !== 'Unhinged')
               ? name_match[1]
               : name;
  const mana_cost = gatherer._get_text (U.find ('.manaCost') ($card));
  if (mana_cost !== '') {
    card$.mana_cost = mana_cost;
  }
  card$.converted_mana_cost = to_converted_mana_cost (mana_cost);
  const lines = U.map (U.trim)
                      ((U.text (U.find ('.typeLine') ($card)))
                       .match (/^.*$/gm));
  const stats = lines[4].slice (1, -1);
  if (lines[2] === 'Vanguard') {
    [card$.hand_modifier, card$.life_modifier] =
      U.map (gatherer._to_stat) (U.splitOn ('/') (stats));
  } else {
    if (/^\d+$/.test (stats)) {
      card$.loyalty = Number (stats);
    } else if ((match = /^((?:[{][^}]*[}]|[^/])*)[/](.*)$/.exec (stats))) {
      [card$.power, card$.toughness] =
        U.map (gatherer._to_stat) (match.slice (1));
    }
    const [types, subtypes] = U.map (U.trim) (U.splitOn ('\u2014') (lines[2]));
    (U.splitOn (' ') (types)).forEach (type => {
      if (supertypes.has (type)) {
        card$.supertypes.push (type);
      } else {
        card$.types.push (type);
      }
    });
    if (subtypes != null) card$.subtypes = U.splitOn (' ') (subtypes);
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

const to_converted_mana_cost = U.pipe ([
  U.splitOnRegex (/(?=[{])/g),
  U.reduce (cmc => symbol =>
              cmc +
              (Object.prototype.hasOwnProperty.call (converted_mana_costs,
                                                     symbol) ?
               converted_mana_costs[symbol] :
               1))
           (0),
]);
