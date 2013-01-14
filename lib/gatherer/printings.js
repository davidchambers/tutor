(function() {
  var extract, gatherer, load, request;

  gatherer = require('../gatherer');

  load = require('../load');

  request = require('../request');

  module.exports = function(details, callback) {
    var url;
    url = gatherer.card.url('Printings.aspx', details);
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
    var $, conditions, data, format, legality, row, _ref;
    $ = load(html);
    row = $('#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent' + '_LegalityList_listRepeater_ctl00_ConditionTableData').parent();
    data = {
      legality: {}
    };
    while (row.length) {
      _ref = row.children().map(function() {
        return gatherer._get_text(this);
      }), format = _ref[0], legality = _ref[1], conditions = _ref[2];
      if (legality === 'Special') {
        legality += ": " + conditions;
      }
      data.legality[format] = legality;
      if (row.next() === row) {
        break;
      }
      row = row.next();
    }
    return data;
  };

}).call(this);
