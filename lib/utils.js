(function() {
  var entities, identity, symbols, to_symbol, utils;

  entities = require('./entities');

  symbols = require('./symbols');

  utils = module.exports;

  utils.card = function() {
    return {
      converted_mana_cost: 0,
      supertypes: [],
      types: [],
      subtypes: []
    };
  };

  to_symbol = function(alt) {
    var m;
    m = /^(\S+) or (\S+)$/.exec(alt);
    return m && ("" + (to_symbol(m[1])) + "/" + (to_symbol(m[2]))) || symbols[alt] || alt;
  };

  identity = function(value) {
    return value;
  };

  utils.get_rules_text = function(node, get_text) {
    return node.children().toArray().map(get_text).filter(identity).join('\n\n');
  };

  utils.get_text = function(node) {
    node.find('img').each(function() {
      return this.replaceWith("{" + (to_symbol(this.attr('alt'))) + "}");
    });
    return node.text().trim();
  };

  utils.get_versions = function(image_nodes) {
    var versions;
    versions = {};
    image_nodes.each(function() {
      var expansion, rarity, _ref;
      _ref = /^(.*\S)\s+[(](.+)[)]$/.exec(this.attr('alt')).slice(1), expansion = _ref[0], rarity = _ref[1];
      expansion = entities.decode(expansion);
      return versions[/\d+$/.exec(this.parent().attr('href'))] = {
        expansion: expansion,
        rarity: rarity
      };
    });
    return versions;
  };

  utils.isNaN = function(value) {
    return value !== value;
  };

  utils.set = function(object, key, value) {
    if (!(value === void 0 || utils.isNaN(value))) {
      return object[key] = value;
    }
  };

  utils.to_stat = function(stat_as_string) {
    var stat_as_number;
    stat_as_number = +(stat_as_string != null ? stat_as_string.replace('{1/2}', '.5') : void 0);
    if (utils.isNaN(stat_as_number)) {
      return stat_as_string;
    } else {
      return stat_as_number;
    }
  };

}).call(this);
