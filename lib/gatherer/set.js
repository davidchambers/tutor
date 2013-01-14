(function() {
  var extract, gatherer, load, request, supertypes,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  gatherer = require('../gatherer');

  load = require('../load');

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
    var $, match, set, t, underlined;
    $ = load(html);
    t = function(el) {
      return gatherer._get_text($(el));
    };
    underlined = $('#ctl00_ctl00_ctl00_MainContent_SubContent_topPagingControlsContainer').children('a[style="text-decoration:underline;"]');
    set = {
      page: underlined.length ? +t(underlined) : 1,
      pages: (function() {
        var link, number, _i, _len, _ref;
        _ref = $('.paging').find('a').toArray().reverse();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          link = _ref[_i];
          if ((number = +t(link)) > 0) {
            return number;
          }
        }
        return 1;
      })(),
      cards: []
    };
    match = $('#aspnetForm').attr('action').match(/page=(\d+)/);
    if (!(match && ++match[1] === set.page)) {
      throw new Error('page not found');
    }
    $('.cardItem').each(function() {
      var card, expansion, href, id, param, rarity, _ref, _ref1;
      set.cards.push(card = {
        converted_mana_cost: 0,
        supertypes: [],
        types: [],
        subtypes: []
      });
      this.find('div, span').each(function() {
        var loyalty, power, regex, subtypes, toughness, type, types, _i, _len, _ref, _ref1;
        switch (this.attr('class')) {
          case 'cardTitle':
            return gatherer._set(card, 'name', t(this));
          case 'manaCost':
            return gatherer._set(card, 'mana_cost', t(this));
          case 'convertedManaCost':
            return gatherer._set(card, 'converted_mana_cost', +t(this));
          case 'typeLine':
            regex = /^([^\u2014]+?)(?:\s+\u2014\s+(.+?))?(?:\s+[(](?:([^\/]+(?:[{][^}]+[}])?)\s*\/\s*([^\/]+(?:[{][^}]+[}])?)|(\d+))[)])?$/;
            _ref = regex.exec(t(this)).slice(1), types = _ref[0], subtypes = _ref[1], power = _ref[2], toughness = _ref[3], loyalty = _ref[4];
            _ref1 = types.split(/\s+/);
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              type = _ref1[_i];
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
      _ref = /multiverseid=(\d+)/.exec(href), param = _ref[0], id = _ref[1];
      card.gatherer_url = "http://gatherer.wizards.com/Pages/Card/Details.aspx?" + param;
      card.image_url = "http://gatherer.wizards.com/Handlers/Image.ashx?" + param + "&type=card";
      card.versions = gatherer._get_versions(this.find('.setVersions').find('img'));
      _ref1 = card.versions[id], expansion = _ref1.expansion, rarity = _ref1.rarity;
      card.expansion = expansion;
      return card.rarity = rarity;
    });
    return set;
  };

}).call(this);
