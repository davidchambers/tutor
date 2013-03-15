(function() {
  var extract, gatherer, load, pagination, request, supertypes,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  gatherer = require('../gatherer');

  load = require('../load');

  pagination = require('../pagination');

  request = require('../request');

  supertypes = require('../supertypes');

  module.exports = function(_arg, callback) {
    var name, page, url;
    name = _arg.name, page = _arg.page;
    if (page == null) {
      page = 1;
    }
    if (!(page > 0)) {
      callback(new Error('invalid page number'));
      return;
    }
    url = 'http://gatherer.wizards.com/Pages/Search/Default.aspx';
    url += "?set=[%22" + (encodeURIComponent(name)) + "%22]&page=" + (page - 1);
    request({
      url: url
    }, function(err, res, body) {
      var set;
      if (err != null) {
        return callback(err);
      }
      if (res.statusCode !== 200) {
        return callback(new Error('unexpected status code'));
      }
      try {
        set = extract(body);
      } catch (err) {
        return callback(err);
      }
      return callback(null, set);
    });
  };

  extract = function(html) {
    var $, match, max, selected, set, t, _ref;
    $ = load(html);
    t = function(el) {
      return gatherer._get_text($(el));
    };
    _ref = pagination($('#ctl00_ctl00_ctl00_MainContent_SubContent_topPagingControlsContainer')), selected = _ref.selected, max = _ref.max;
    set = {
      page: selected,
      pages: max,
      cards: []
    };
    match = $('#aspnetForm').attr('action').match(/page=(\d+)/);
    if (!(match && ++match[1] === set.page)) {
      throw new Error('page not found');
    }
    $('.cardItem').each(function() {
      var card, expansion, href, id, param, rarity, _ref1, _ref2;
      set.cards.push(card = {
        converted_mana_cost: 0,
        supertypes: [],
        types: [],
        subtypes: []
      });
      this.find('div, span').each(function() {
        var loyalty, power, regex, subtypes, toughness, type, types, _i, _len, _ref1, _ref2;
        switch (this.attr('class')) {
          case 'cardTitle':
            return gatherer._set(card, 'name', t(this));
          case 'manaCost':
            return gatherer._set(card, 'mana_cost', t(this));
          case 'convertedManaCost':
            return gatherer._set(card, 'converted_mana_cost', +t(this));
          case 'typeLine':
            regex = /^([^\u2014]+?)(?:\s+\u2014\s+(.+?))?(?:\s+[(](?:([^\/]+(?:[{][^}]+[}])?)\s*\/\s*([^\/]+(?:[{][^}]+[}])?)|(\d+))[)])?$/;
            _ref1 = regex.exec(t(this)).slice(1), types = _ref1[0], subtypes = _ref1[1], power = _ref1[2], toughness = _ref1[3], loyalty = _ref1[4];
            _ref2 = types.split(/\s+/);
            for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
              type = _ref2[_i];
              card[__indexOf.call(supertypes, type) >= 0 ? 'supertypes' : 'types'].push(type);
            }
            gatherer._set(card, 'subtypes', (subtypes != null ? subtypes.split(/\s+/) : void 0) || []);
            gatherer._set(card, 'power', gatherer._to_stat(power));
            gatherer._set(card, 'toughness', gatherer._to_stat(toughness));
            return gatherer._set(card, 'loyalty', +loyalty);
        }
      });
      gatherer._set(card, 'text', gatherer._get_rules_text(this.find('.rulesText'), t));
      href = this.find('.cardTitle').find('a').attr('href');
      _ref1 = /multiverseid=(\d+)/.exec(href), param = _ref1[0], id = _ref1[1];
      card.gatherer_url = "http://gatherer.wizards.com/Pages/Card/Details.aspx?" + param;
      card.image_url = "http://gatherer.wizards.com/Handlers/Image.ashx?" + param + "&type=card";
      card.versions = gatherer._get_versions(this.find('.setVersions').find('img'));
      _ref2 = card.versions[id], expansion = _ref2.expansion, rarity = _ref2.rarity;
      card.expansion = expansion;
      return card.rarity = rarity;
    });
    return set;
  };

}).call(this);
