(function() {
  var printCard, printFullCard, printSet, withCaution;

  withCaution = function(view) {
    return function(error, response) {
      if (error) {
        if (error.errno === "ENOTFOUND") {
          return console.log("cannot connect to gatherer");
        } else {
          return console.log("unknown error: " + error);
        }
      } else {
        return view(response);
      }
    };
  };

  printCard = function(card) {
    var output;
    output = "" + card.name;
    if ('mana_cost' in card) {
      output += " " + card.mana_cost;
    }
    if ('power' in card) {
      output += " " + card.power + "/" + card.toughness;
    }
    if ('text' in card) {
      output += " " + (card.text.replace(/[\n\r]/g, " "));
    }
    console.log(output);
  };

  printFullCard = function(card) {
    return console.log(JSON.stringify(card));
  };

  printSet = function(set) {
    var card, _i, _len, _ref, _results;
    _ref = set.cards;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      card = _ref[_i];
      _results.push(printCard(card));
    }
    return _results;
  };

  exports.card = withCaution(printCard);

  exports.set = withCaution(printSet);

  exports.fullCard = withCaution(printFullCard);

}).call(this);
