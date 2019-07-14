'use strict';

const url = require ('url');

const gatherer = require ('./gatherer');
const U = require ('./util');


module.exports = $container => {
  const $links = $container.children ('a');
  const $selected = $links.filter ('[style="text-decoration:underline;"]');
  const numbers = U.map (U.pipe ([U.attr ('href'),
                                  href => url.parse (href, true),
                                  U.prop ('query'),
                                  U.prop ('page'),
                                  Number,
                                  U.add (1)]))
                        (U.toArray ($links));
  return {
    min: U.reduce (U.min) (1) (numbers),
    max: U.reduce (U.max) (1) (numbers),
    selected: $selected.length ? Number (gatherer._get_text ($selected)) : 1,
  };
};
