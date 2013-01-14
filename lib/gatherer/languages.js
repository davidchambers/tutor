(function() {
  var extract, gatherer, languages, load, request;

  gatherer = require('../gatherer');

  languages = require('../languages');

  load = require('../load');

  request = require('../request');

  module.exports = function(details, callback) {
    var url;
    url = gatherer.card.url('Languages.aspx', details);
    request({
      url: url,
      followRedirect: false
    }, function(err, res, body) {
      if (res.statusCode !== 200) {
        if (err == null) {
          err = new Error('unexpected status code');
        }
      }
      if (err) {
        return callback(err);
      } else {
        return callback(null, extract(body));
      }
    });
  };

  extract = function(html) {
    var $, data;
    $ = load(html);
    data = {};
    $('tr.cardItem').each(function() {
      var $name, language, trans_card_name, _ref;
      _ref = this.children(), trans_card_name = _ref[0], language = _ref[1];
      $name = $(trans_card_name);
      return data[languages[$(language).text().trim()]] = {
        id: +$name.find('a').attr('href').match(/multiverseid=(\d+)/)[1],
        name: $name.text().trim()
      };
    });
    return data;
  };

}).call(this);
