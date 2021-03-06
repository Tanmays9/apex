({
  getInitialDefinitions: function (cmp, event, helper) {
    // var objName = cmp.get("v.objectName");
    // var objFields = cmp.get("v.fieldsList");
    // var countRecords = cmp.get("v.noOfRecordsDisplay");
    // var pageNo = cmp.get("v.pageNo");
    // this.server(cmp, "c.getObjectData", {
    //   objectName: objName,
    //   fields: objFields
    // })
    //   .then((result) => parseResponse(result, helper))
    //   .catch((result) => {
    //     throw result;
    //   });
    //   // this.getNoOfRecords(cmp);
    // function parseResponse(response, helper) {
    //   if ( response.hasOwnProperty("objectLabel") &&
    //     response.hasOwnProperty("fieldLabels") &&
    //     response.hasOwnProperty("totalRecords") &&
    //     response.hasOwnProperty("records") ) 
    //     {
    //     cmp.set("v.objectLabel", response.objectLabel);
    //     cmp.set("v.fieldLabels", response.fieldLabels);
    //     cmp.set("v.totalrecords", response.totalRecords);
    //     cmp.set("v.records", response.records);
    //     // helper.getNoOfRecords(cmp);
    //   } else throw "Invalid Response From Server";
    // }
  },
  parseResponse : function(cmp, response){
    console.log(response);
    if (
      response.hasOwnProperty("objectLabel") &&
      response.hasOwnProperty("fields") &&
      response.hasOwnProperty("totalRecords") &&
      response.hasOwnProperty("records")
    ) {
      cmp.set("v.objectLabel", response.objectLabel);
      cmp.set("v.fields", response.fields);
      cmp.set("v.totalrecords", response.totalRecords);
      cmp.set("v.records", this.validateRecords(cmp, response.fields, response.records));
    } else throw "Invalid Response From Server";
  },
  validateRecords : function(cmp, fields, records){
    console.log(cmp.get("v.fields"));
    var currencyFields = fields.reduce((fieldList, field) => {
      if(field.type === "CURRENCY"){
        fieldList.push(field.fieldName);
      }
      return fieldList;

    }, []);

    records.forEach(record => {
      record.forEach(params => {
        if(currencyFields.includes(params.fieldName)){
          params.value = '$'+params.value;
        }
      }); 
    });
    return records;
  },
  getNoOfRecords: function (cmp) {
    let count = cmp.get("v.noOfRecordsDisplay");
    let totalRecords = cmp.get("v.totalrecords");
    let totalpages =
      totalRecords % count > 0
        ? (totalRecords - (totalRecords % count)) / count + 1
        : totalRecords / count;
    cmp.set("v.totalpages", totalpages);
  },
  server: function (component, actionName, params) {
    return new Promise(
      $A.getCallback((resolve, reject) => {
        var action = component.get(actionName);
        params && action.setParams(params);
        action.setCallback(this, (result) => {
          switch (result.getState()) {
            case "SUCCESS":
              // console.log('Success ' + result.getReturnValue());
              resolve(result.getReturnValue());
              break;
            default:
              // console.log('failed ' + result.getError());
              reject(result.getError()[0]['message']);
          }
        });
        $A.enqueueAction(action);
      })
    );
  },
  createParms: function(cmp){
    return {
          'objectName' : cmp.get("v.objectName"),
          'fieldNames' : cmp.get("v.fieldsList"),
          'recordsCount' : cmp.get("v.noOfRecordsDisplay"),
          'pageno' : cmp.get("v.pageNo")
      };
  },
  test: function(){
    alert('her');
  }
});