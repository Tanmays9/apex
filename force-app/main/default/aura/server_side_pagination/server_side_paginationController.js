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
        cmp.set("v.records", helper.checkState(cmp, result));
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
        cmp.set("v.records", helper.checkState(cmp, result));
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
    if(sortDir == undefined  && sortBy == undefined || sortBy != sortedBy){
      sortDir = 'asc';
    }else if(sortBy == sortedBy){
      sortDir = (sortDir == 'asc')? 'desc': 'asc';
    }
    console.log(sortedBy);
    cmp.set('v.sortedBy', sortBy);
    cmp.set('v.sortDirection', sortDir);
    cmp.set("v.pageNo", 1);

    helper
    .server(cmp, "c.getRecords", helper.createParms(cmp))
    .then((result) => {
      cmp.set("v.records", helper.checkState(cmp, result));
    })
    .catch((result) => {
      throw result;
    });
  },
  checkBox : function(cmp,Event) {
    var selected = cmp.get('v.selectedRecords');
    var records = cmp.get('v.records');
    var checked = Event.currentTarget.checked;
    var value = Event.currentTarget.value;
    var index = Event.currentTarget.getAttribute('tabindex');
    console.log(index);
    var unselected = [];

    records.forEach((record,i) => {
      if(value === 'select-all' && record.isChecked != checked){
        record.isChecked = checked;
      }else if(i == index){
        record.isChecked = checked;
      }
      (record.isChecked)? selected.push(record.data[0].value): unselected.push(record.data[0].value);
    });

    console.log(' unselected '+unselected);
    if(unselected.length>0){
      for(var i = 0; selected.length > i; ++i){
        if(unselected.includes(selected[i])){
          selected.splice(i, 1);
          i--;
        }
      }
      document.querySelector('input.select-all').checked = false;
    }else{
      document.querySelector('input.select-all').checked = true;
    }
    
    cmp.set('v.selectedRecords', selected);
    cmp.set('v.records' , records);
   }
  
});