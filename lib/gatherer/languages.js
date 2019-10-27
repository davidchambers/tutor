'use strict';

const gatherer = require ('../gatherer');
const languages = require ('../languages');
const pagination = require ('../pagination');
const U = require ('../util');


//    paginationSelector :: String
const paginationSelector =
  '#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_' +
  'languageList_pagingControls';

//    fetch :: StrMap String -> Integer -> Promise $
const fetch = details => page =>
  gatherer.request (gatherer.card.url ('Languages.aspx', details, {page}));

//    languages
//    :: StrMap String
//    -> Promise (StrMap { name :: String, ids :: Array Integer })
module.exports = details =>
  fetch (details) (1)
  .then ($ => Promise.all (U.map (fetch (details))
                                 (U.range
                                    (2)
                                    (U.prop ('max')
                                            (pagination
                                               ($ (paginationSelector))) + 1)))
              .then (U.concat ([$])))
  .then (U.map (U.T ('tr.cardItem')))
  .then (U.chain (U.toArray))
  .then (U.map (U.children))
  .then (U.map (([fst, snd]) => ({
                  code: languages[U.trim (U.text (snd))],
                  name: U.trim (U.text (fst)),
                  id: gatherer._id_from_link (U.find ('a') (fst)),
                })))
  .then (U.sortBy (U.prop ('id')))
  .then (rs => U.reduce (map => ({code, id, name}) => {
                           if (!(code in map)) map[code] = {name, ids: []};
                           map[code].ids.push (id);
                           return map;
                         })
                        (Object.create (null))
                        (rs));
