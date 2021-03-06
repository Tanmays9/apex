public inherited sharing class server_side_pagination_controller {
    @AuraEnabled
    public static objectData getObjectData(string objectName ,List<String> fieldNames){
        system.debug(' request  ' + objectName + ' : ' +fieldNames);
        DescribeSObjectResult objectDescribe = ((SObject)(Type.forName(objectName).newInstance())).getSObjectType().getDescribe();
        return new objectData(objectDescribe.getLabel(), getTotalRecords(objectName), fetchfields(objectName ,fieldNames ,objectDescribe) , getRecords(objectName ,fieldNames ,null ,null));   
    }

    @AuraEnabled
    public static List<List<record>> getRecords(string objectName ,List<String> fieldNames ,Integer recordsCount ,Integer pageno){
        system.debug(' Get Records ' + objectName + ' : ' +fieldNames + ' : '+ recordsCount + ' : '+ pageno);
        if(recordsCount == null){
            recordsCount = 5;
        }
        Integer offset = 0;
        if(pageno == null || pageno < 1){
            pageno = 1;
        }else {
            offset = (pageno -1)*recordsCount;
        }
        return universalQuery(objectName, fieldNames, recordsCount, offset);
    }

    public static List<List<record>> universalQuery(string objectName ,List<String> fieldNames, Integer recordsCount ,Integer offset) {
        string querySOQL = 'SELECT ';
        if(!fieldNames.contains('Id')){
            fieldNames.add(0, 'Id');
        }else if(fieldNames.size() == 0 ){
            fieldNames.add('Id');
        }
        querySOQL += String.join(fieldNames, ' ,');
        querySOQL += ' FROM '+ objectName;
        querySOQL += ' LIMIT ' + recordsCount;
        querySOQL += ' OFFSET ' + offset;
        system.debug(' Query ' + querySOQL);
        List<SObject> con = Database.query(querySOQL);
        List<List<record>> parsedRecords = parseRecordsToJson(fieldNames, con);
        system.debug(parsedRecords);
        return parsedRecords;
    }

    public static List<field> fetchFields(string objectName ,List<String> fieldNames, DescribeSObjectResult objectDescribe){
        Map <String, Schema.SObjectField>objDescribeFields = objectDescribe.fields.getMap();
        system.debug(objDescribeFields);
        system.debug(objDescribeFields.get('name').getDescribe());
        
        list<field> fieldList = new List<field>();
        for(string field : fieldNames){
            fieldList.add(new field(objDescribeFields.get(field).getDescribe()));
        }

        return fieldList;
    }

    public static Integer getTotalRecords(String objectName){
        system.debug(objectName);
        string countQuery = 'SELECT count() FROM '+ objectName;
        system.debug(Database.countQuery(countQuery));
        return Database.countQuery(countQuery);
    }

    @AuraEnabled
    public static List<List<record>> parseRecordsToJson(list<string> fieldNames, List<SObject> records){ 
        system.debug(fieldNames);
        system.debug(records);
        List<List<record>> parsedRecords = new List<List<record>>(); 
        for(Sobject obj : records){

            list<record> objRecords = new List<record>();
            for(string field : fieldNames){
                string value = string.valueOf(obj.get(field));
                if(value == 'null'){
                    value = '';
                }
                // if(objDescribeFields.get(field).getDescribe().getType() == schema.DisplayType.CURRENCY){
                //     value = '$'+ value;
                // }
                objRecords.add(new record(field , value));
            }
            parsedRecords.add(objRecords);
        }
        return parsedRecords;
    }

    public class objectData {
        @AuraEnabled public string objectLabel;
        @AuraEnabled public Integer totalRecords;
        @AuraEnabled public List<field> fields;
        @AuraEnabled public List<List<record>> records;
        public objectData(string objectLabel, Integer totalRecords, List<field> fields, List<List<record>> records){
            this.objectLabel = objectLabel;
            this.totalRecords = totalRecords; 
            this.fields = fields;
            this.records = records;
        }
    }

    public class field {
        @AuraEnabled public string label;
        @AuraEnabled public string fieldName;
        @AuraEnabled public string type;
        @AuraEnabled public Boolean sortable;
        @AuraEnabled public Object typeAttributes;
        @AuraEnabled public Object cellAttributes;
        public field(string label, string fieldName, string type, Boolean sortable, Object typeAttributes, Object cellAttributes){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.sortable = sortable;
            this.typeAttributes = typeAttributes;
            this.cellAttributes = cellAttributes;
        }
        public field(string label, string fieldName, string type){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
        }
        public field(DescribeFieldResult fieldDescribe){
            this.label = fieldDescribe.getLabel();
            this.fieldName = fieldDescribe.getName();
            this.type = fieldDescribe.getType().name();
            this.sortable = fieldDescribe.isSortable();
        }
    }

    public class record {
        @AuraEnabled public string fieldName;
        @AuraEnabled public string value;
        public record(string fieldName, string value){
            this.fieldName = fieldName;
            this.value = value;
        }
    }

}