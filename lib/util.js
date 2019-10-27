'use strict';

const cheerio = require ('cheerio');


//      I :: a -> a
exports.I = x => x;

//      T :: a -> (a -> b) -> b
exports.T = x => f => f (x);

//      add :: Number -> Number -> Number
exports.add = x => y => x + y;

//      any :: (a -> Boolean) -> Array a -> Boolean
exports.any = pred => xs => xs.some (x => pred (x));

//      attr :: String -> Cheerio -> String
exports.attr = name => x => x.attr (name);

//      chain :: (a -> Array b) -> Array a -> Array b
exports.chain = f => xs => {
  const result = [];
  xs.forEach (x => { Array.prototype.push.apply (result, f (x)); });
  return result;
};

//      children :: Cheerio -> Array Cheerio
exports.children = x => exports.toArray (x.children ());

//      complement :: (a -> Boolean) -> a -> Boolean
exports.complement = pred => x => !(pred (x));

//      concat :: Semigroup a => a -> a -> a
exports.concat = x => y => x.concat (y);

//      eq :: Integer -> Cheerio -> Cheerio
exports.eq = n => x => x.eq (n);

//      filter :: (a -> Boolean) -> Array a -> Array a
exports.filter = pred => xs => xs.filter (x => pred (x));

//      find :: String -> Cheerio -> Cheerio
exports.find = sel => x => x.find (sel);

//      finds :: Array String -> Cheerio -> Cheerio
exports.finds = sels => x => sels.reduce ((x, sel) => x.find (sel), x);

//      flip :: (a -> b -> c) -> b -> a -> c
exports.flip = f => y => x => f (x) (y);

//      identical :: a -> a -> Boolean
exports.identical = x => y => x === y;

//      join :: Array (Array a) -> Array a
exports.join = exports.chain (exports.I);

//      joinWith :: String -> Array String -> String
exports.joinWith = sep => ss => ss.join (sep);

//      last :: NonEmpty (Array a) -> a
exports.last = xs => xs[xs.length - 1];

//      map :: (a -> b) -> Array a -> Array b
exports.map = f => xs => xs.map (x => f (x));

//      max :: Ord a => a -> a -> a
exports.max = x => y => x > y ? x : y;

//      min :: Ord a => a -> a -> a
exports.min = x => y => x < y ? x : y;

//      next :: Cheerio -> Cheerio
exports.next = x => x.next ();

//      parent :: Cheerio -> Cheerio
exports.parent = x => x.parent ();

//      pipe :: Array (Any -> Any) -> a -> b
exports.pipe = fs => x => fs.reduce ((x, f) => f (x), x);

//      prop :: String -> a -> b
exports.prop = key => x => {
  const obj = x == null ? Object.create (null) : Object (x);
  if (key in obj) return obj[key];
  throw new TypeError (
    `‘prop’ expected object to have a property named ‘${key}’`
  );
};

//      range :: Integer -> Integer -> Array Integer
exports.range = lower => upper => {
  const result = [];
  for (let n = lower; n < upper; n += 1) result.push (n);
  return result;
};

//      reduce :: (b -> a -> b) -> b -> Array a -> b
exports.reduce = f => y => xs => xs.reduce ((y, x) => f (y) (x), y);

//      replace :: GlobalRegExp -> String -> String -> String
exports.replace = pat => rep => s => s.replace (pat, rep);

//      slice :: Integer -> Integer -> Array a -> Array a
exports.slice = start => end => xs => xs.slice (start, end);

//      sort :: Ord a => Array a -> Array a
exports.sort = xs => exports.sortBy (exports.I) (xs);

//      sortBy :: Ord b => (a -> b) -> Array a -> Array a
exports.sortBy = f => xs =>
  xs.slice ()
    .sort ((x, y) => {
      const fx = f (x);
      const fy = f (y);
      return fx < fy ? -1 : fx > fy ? 1 : 0;
    });

//      splitOn :: String -> String -> Array String
exports.splitOn = sep => s => s.split (sep);

//      splitOnRegex :: GlobalRegExp -> String -> Array String
exports.splitOnRegex = sep => s => s.split (sep);

//      startsWith :: String -> String -> Boolean
exports.startsWith = sub => s => s.startsWith (sub);

//      strip :: GlobalRegExp -> String -> String
exports.strip = pat => s => s.replace (pat, '');

//      text :: Cheerio -> String
exports.text = x => x.text ();

//      toArray :: Cheerio -> Array Cheerio
exports.toArray = x => exports.map (cheerio) (x.toArray ());

//      toLower :: String -> String
exports.toLower = s => s.toLowerCase ();

//      trim :: String -> String
exports.trim = s => s.trim ();

//      words :: String -> Array String
exports.words = s => {
  const words = s.split (/\s+/);
  const len = words.length;
  return words.slice (words[0] === '' ? 1 : 0,
                      words[len - 1] === '' ? len - 1 : len);
};

//      values :: StrMap a -> Array a
exports.values = o => {
  const result = [];
  for (const k in o) {
    if (Object.prototype.hasOwnProperty.call (o, k) &&
        Object.prototype.propertyIsEnumerable.call (o, k)) {
      result.push (o[k]);
    }
  }
  return result;
};
