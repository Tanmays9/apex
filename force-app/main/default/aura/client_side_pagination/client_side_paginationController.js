({
    init: function (cmp, event, helper) {
        
        cmp.set('v.mycolumns', helper.getColumnDefinitions());
        helper.getAccounts(cmp);
        // Reload in every 5 sec 
        // setTimeout(reloader,50000);
        // function reloader(){
        //     location.reload(true);
        // }  
    },
    recordsPerPage: function(cmp, event, helper){
        var data = cmp.get("v.selectedRows");
        cmp.set("v.selectedRows",  []);
        helper.getNoOfRecords(cmp);
        cmp.set("v.selectedRows",  data);

    },
    pageNoChanged: function(cmp, event, helper){
        console.log('button');
        var data = cmp.get("v.selectedRows");
        console.log(cmp.get("v.selectedRows"));
        cmp.set("v.selectedRows",  []);
        var value = event.getSource().get("v.value");
        helper.goToPage(cmp , value);
        cmp.set("v.selectedRows",  data);
    },
    pageNoSelected: function(cmp, event, helper){
        var data = cmp.get("v.selectedRows");
        cmp.set("v.selectedRows",  []);
        var label = event.getSource().get("v.label");
        console.log( event.getSource());
        helper.goToPage(cmp,label);
        cmp.set("v.selectedRows",  data);
    },
   
    handleSort: function(cmp, event, helper) {
        var data = cmp.get("v.selectedRows");
        cmp.set("v.selectedRows",  []);
        helper.handleSort(cmp, event);
        cmp.set("v.selectedRows",  data);

    },
    
    rowSelect : function(cmp, event, helper){
        helper.handelSelect(cmp, event)
    }

})