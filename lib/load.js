(function() {

  if (typeof window === 'undefined') {
    module.exports = require('cheerio').load;
  }

}).call(this);
