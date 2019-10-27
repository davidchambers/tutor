'use strict';

const https = require ('https');
const url = require ('url');

const cheerio = require ('cheerio');
const entities = require ('entities');

const symbols = require ('./symbols');
const U = require ('./util');


const gatherer = module.exports;

gatherer.origin = 'https://gatherer.wizards.com';

gatherer.url = (pathname, query) => {
  const url = gatherer.origin + pathname;
  const keys = query == null ? [] : U.sort (Object.keys (query));
  return keys.length === 0 ?
         url :
         U.pipe ([U.map (k => encodeURIComponent (k) +
                              '=' +
                              encodeURIComponent (query[k])),
                  U.joinWith ('&'),
                  U.concat ('?'),
                  U.concat (url)])
                (keys);
};

gatherer.request = function recur(uri) {
  return new Promise ((resolve, reject) => {
    const req = https.request (uri, res => {
      if (res.statusCode === 302) {
        recur (gatherer.origin + res.headers.location)
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
};

gatherer.card = require ('./gatherer/card');
gatherer.languages = require ('./gatherer/languages');
gatherer.printings = require ('./gatherer/printings');
gatherer.set = require ('./gatherer/set');

const collect_options = label => () =>
  gatherer.request (gatherer.url ('/Pages/Default.aspx'))
  .then (U.T ('#ctl00_ctl00_MainContent_Content_SearchControls_' +
              label +
              'AddText'))
  .then (U.children)
  .then (U.map (U.attr ('value')))
  .then (U.map (entities.decode));

//    formats :: () -> Promise ???
gatherer.formats = collect_options ('format');

//    sets :: () -> Promise ???
gatherer.sets = collect_options ('set');

//    types :: () -> Promise ???
gatherer.types = collect_options ('type');

function to_symbol(alt) {
  const m = /^(\S+) or (\S+)$/.exec (alt);
  return m && `${to_symbol (m[1])}/${to_symbol (m[2])}` || symbols[alt] || alt;
}

gatherer._get_text = node => {
  const clone = node.clone ();
  const imgs = U.find ('img') (clone);
  for (let idx = 0; idx < imgs.length; idx += 1) {
    const img = U.eq (idx) (imgs);
    img.replaceWith ('{' + to_symbol (U.attr ('alt') (img)) + '}');
  }
  return U.trim (U.text (clone));
};

gatherer._get_versions = image_nodes =>
  U.reduce (versions => $el => {
              const match = /^(.*) [(](.*?)[)]$/.exec (U.attr ('alt') ($el));
              versions[String (gatherer._id_from_link (U.parent ($el)))] = {
                expansion: entities.decode (match[1]),
                rarity: match[2],
              };
              return versions;
            })
           ({})
           (U.toArray (image_nodes));

gatherer._id_from_link = a =>
  Number (U.prop ('multiverseid')
                 (U.prop ('query')
                         (url.parse (U.attr ('href') (a), true))));

gatherer._to_stat = str => {
  const num = Number (U.replace (/[{]1[/]2[}]|½/g) ('.5') (str));
  return Number.isNaN (num) ? str : num;
};
