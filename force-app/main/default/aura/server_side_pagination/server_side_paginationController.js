({
  init: function (cmp, event, helper) {
    // helper.getInitialDefinitions(component, helper);
    var objName = cmp.get("v.objectName");
    var objFields = cmp.get("v.fieldsList");
    helper
      .server(cmp, "c.getObjectData", {
        objectName: objName,
        fieldNames: objFields
      })
      .then((result) => {
        helper.parseResponse(cmp, result);
        helper.getNoOfRecords(cmp);
        if (cmp.get("v.totalpages") > 0) {
          cmp.set("v.pageNo", 1);
        }
        cmp.set("v.pageNo", 1);
      })
      .catch((result) => {
        throw result;
      });
  },

  recordsPerPageChanged: function (cmp, event, helper) {
    cmp.set("v.pageNo", 1);
    helper
      .server(cmp, "c.getRecords", helper.createParms(cmp))
      .then((result) => {
        cmp.set("v.records", result);
        helper.getNoOfRecords(cmp);
      })
      .catch((result) => {
        throw result;
      });
  },
  pageNoChanged: function (cmp, event, helper) {
    var value = event.getSource().get("v.value");
    if(value === undefined){
        value = event.getSource().get("v.label");
    }
    if(cmp.get("v.pageNo") === value){
        return;
    }
        console.log("page changed " + value);
        cmp.set("v.pageNo", value);
    helper
      .server(cmp, "c.getRecords", helper.createParms(cmp))
      .then((result) => {
        cmp.set("v.records", result);
        cmp.set("v.pageNo", value);
      })
      .catch((result) => {
        throw result;
      });
  },
  sorting : function(cmp, event, helper){
    var sortDir = cmp.get('v.sortDirection');
    var sortedBy = cmp.get('v.sortedBy');
    var sortBy = event.currentTarget.querySelector('.data').title;
    if(sortDir == undefined  && sortBy != sortedBy){
      sortDir = 'asc';
    }else {
      sortDir = 'desc';
    }
    console.log(sortedBy);
    cmp.set('v.sortedBy', sortBy);
    console.log(cmp.get('v.sortedBy'));
    cmp.set('v.sortDirection', sortDir);
    helper.test();
  }
  
});