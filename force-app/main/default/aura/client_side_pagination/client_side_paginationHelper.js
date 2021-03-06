({
    getColumnDefinitions: function () {
        var columns = [

            {
                label: 'Name',
                fieldName: 'Name',
                type: 'text',
                sortable: true,
            },
            {
                label: 'Annual Revenue',
                fieldName: 'AnnualRevenue',
                type: 'currency',
                sortable: true,
                typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0' },
            },
            {
                label: 'Description',
                fieldName: 'Description',
                type: 'text area',
                sortable: true,
            },
            { label: 'Phone', fieldName: 'Phone', type: 'phone', sortable: true, }
        ];
        return columns;

    },

    getAccounts: function (cmp) {
        var action = cmp.get('c.retriveAccounts');

        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log(JSON.stringify(response.getReturnValue()));
                var data = response.getReturnValue();
                cmp.set('v.totalrecords', data.length);
                let totalpages = (data.length % 5 > 0) ? (data.length - data.length % 5) / 5 + 1 : data.length / 5;
                cmp.set('v.totalpages', totalpages);
                cmp.set('v.mydata', data);
                var records = data.slice(0, 5);
                cmp.set('v.records', records);
            } else if (status === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    getNoOfRecords: function (cmp) {
        let count = cmp.get('v.noOfRecordsDisplay');
        let data = cmp.get('v.mydata');
        var records = data.slice(0, count);
        cmp.set('v.records', records);
        let totalpages = (data.length % count > 0) ? (data.length - data.length % count) / count + 1 : data.length / count;
        cmp.set('v.totalpages', totalpages);
        cmp.set('v.pageNo', 1);
    },

    goToPage: function (cmp, value) {
        console.log('helper' + value);
        let count = cmp.get('v.noOfRecordsDisplay');
        let data = cmp.get('v.mydata');
        let initial = count * (value - 1);
        let final = count * (value);
        var records = data.slice(initial, final);
        cmp.set('v.records', records);
        cmp.set('v.pageNo', value);
    },
    handleSort: function (cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // var direction = cmp.get("v.sortedDirection");
        let data = cmp.get('v.mydata');
        console.log(sortedBy);
        console.log(sortDirection);

        const sorted = data.sort(this.sortData(sortedBy, sortDirection));
        console.log(sorted);
        cmp.set("v.mydata", sorted);
        this.goToPage(cmp, 1);

        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);

    },
    sortData: function (key, order) {
        console.log(key + order);
        return ((a, b) => {
            if (a.hasOwnProperty(key) && b.hasOwnProperty(key)) {
                // property doesn't exist on either object
                console.log("both");
            } else if (!a.hasOwnProperty(key) && b.hasOwnProperty(key)) {
                // alert("a");
                return (order === 'desc') ? +1 : -1;
            } else if (a.hasOwnProperty(key) && !b.hasOwnProperty(key)) {
                // alert("b");
                return (order === 'desc') ? -1 : +1;
            } else {
                // alert("not both");
                return (order === 'desc') ? +1 : -1;
            }
            const varA = (typeof a[key] === 'string')
                ? a[key].toUpperCase() : a[key];
            const varB = (typeof b[key] === 'string')
                ? b[key].toUpperCase() : b[key];
            let comparision = 0;
            console.log(varA + " comparision of " + varB)
            if (varA > varB) {
                console.log("varA > varB")
                comparision = 1;
            } else if (varA < varB) {
                console.log("varA < varB")
                comparision = -1;
            }
            return (
                (order === 'desc') ? (comparision * -1) : comparision
            );
        });
    },
    handelSelect : function(cmp, event){
        var selectedRows = event.getParam('selectedRows');
        var selection = cmp.get("v.selection");
        var selected = cmp.get("v.selectedRows");
       
        var dataSet = new Set(selection);
        console.log(dataSet);
        selectedRows.forEach((row, Index) =>{
            dataSet.add(row.Id);
        })
        
        let result = selectedRows.map(a => a.Id);
        let records = cmp.get("v.records").map(a => a.Id);
        selected.forEach((row, Index) => {
            if(!result.includes(row) && records.includes(row)){
                dataSet.delete(row);
                
            }else{
                console.log(" contains "+row);
            }
        })
        

        let array = Array.from(dataSet); 
        cmp.set("v.selection", array);
        cmp.set("v.selectedRows",  array);
    }

})