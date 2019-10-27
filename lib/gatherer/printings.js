'use strict';

const gatherer = require ('../gatherer');
const U = require ('../util');


module.exports = ({id, name}) =>
  gatherer.request (
    gatherer.origin + '/Pages/Card/Printings.aspx?' +
    (id == null ? 'name=' + encodeURIComponent (name)
                : 'multiverseid=' + encodeURIComponent (id))
  )
  .then (extract);

const extract = $ => {
  const prefix = '#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent';

  const legality = {};
  for (let row = U.parent ($ (prefix +
                              '_LegalityList_listRepeater' +
                              '_ctl00_ConditionTableData'));
       row.hasClass ('cardItem');
       row = U.next (row)) {
    const cells = U.children (row);
    const format = gatherer._get_text (cells[0]);
    const legality_ = gatherer._get_text (cells[1]);
    legality[format] = legality_;
  }

  const versions = {};
  for (let row = U.parent (U.parent ($ (prefix +
                                        '_PrintingsList_listRepeater' +
                                        '_ctl00_cardTitle')));
       row.hasClass ('cardItem');
       row = U.next (row)) {
    const id = gatherer._id_from_link (U.find ('a') (row));
    const expansion = gatherer._get_text ((U.children (row))[2]);
    const rarity = U.strip (/[)].*$/g)
                           (U.strip (/^.*[(]/g)
                                    (U.attr ('alt') (U.find ('img') (row))));
    versions[String (id)] = {expansion, rarity};
  }

  return {legality, versions};
};
