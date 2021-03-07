public inherited sharing class server_side_pagination_controller {
    @AuraEnabled
    public static objectData getObjectData(string objectName ,List<String> fieldNames){
        system.debug(' request  ' + objectName + ' : ' +fieldNames);
        DescribeSObjectResult objectDescribe = ((SObject)(Type.forName(objectName).newInstance())).getSObjectType().getDescribe();
        return new objectData(objectDescribe.getLabel(), getTotalRecords(objectName), fetchfields(objectName ,fieldNames ,objectDescribe) , getRecords(objectName ,fieldNames ,5 , 1,null,null));   
    }

    @AuraEnabled
    public static List<record> getRecords(string objectName ,List<String> fieldNames ,Integer recordsCount ,Integer pageno, String sortBy, String sortDirection){
        system.debug(' Get Records ' + objectName + ' : ' +fieldNames + ' : '+ recordsCount + ' : '+ pageno + ' : '+ sortBy + ' : ' + sortDirection);
        Integer offset = 0;
        if(pageno < 1){
            pageno = 1;
        }else {
            offset = (pageno -1)*recordsCount;
        }
        return universalQuery(objectName, fieldNames, recordsCount, offset, sortBy, sortDirection);
    }

    public static List<record> universalQuery(string objectName ,List<String> fieldNames, Integer recordsCount ,Integer offset ,String sortBy, String sortDirection) {
        string querySOQL = 'SELECT ';
        if(!fieldNames.contains('Id')){
            fieldNames.add(0, 'Id');
        }else if(fieldNames.size() == 0 ){
            fieldNames.add('Id');
        }
        querySOQL += String.join(fieldNames, ' ,');
        querySOQL += ' FROM '+ objectName;
        if(sortBy != null && sortDirection != null){
            querySOQL += ' ORDER BY ' + sortBy + ((sortDirection  == 'asc')? ' ASC NULLS FIRST ': ' DESC NULLS LAST ' );
        }
        querySOQL += ' LIMIT ' + recordsCount;
        querySOQL += ' OFFSET ' + offset;
        system.debug(' Query ' + querySOQL);
        List<SObject> con = Database.query(querySOQL);
        List<record> parsedRecords = parseRecordsToJson(fieldNames, con);
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
    public static List<record> parseRecordsToJson(list<string> fieldNames, List<SObject> records){ 
        system.debug(fieldNames);
        system.debug(records);
        List<record> parsedRecords = new List<record>(); 
        for(Sobject obj : records){

            list<recordField> objRecords = new List<recordField>();
            for(string field : fieldNames){
                string value = string.valueOf(obj.get(field));
                if(value == 'null'){
                    value = '';
                }
                objRecords.add(new recordField(field , value));
            }
            parsedRecords.add(new record(false, objRecords));
        }
        return parsedRecords;
    }

    public class objectData {
        @AuraEnabled public string objectLabel;
        @AuraEnabled public Integer totalRecords;
        @AuraEnabled public List<field> fields;
        @AuraEnabled public List<record> records;
        public objectData(string objectLabel, Integer totalRecords, List<field> fields, List<record> records){
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
        @AuraEnabled public list<recordField> data;
        @AuraEnabled public Boolean isChecked;
        public record( Boolean isChecked, list<recordField> data){
            this.isChecked = isChecked;
            this.data = data;
        }
        
    }

    public class recordField {
        @AuraEnabled public string fieldName;
        @AuraEnabled public string value;
        public recordField(string fieldName, string value){
            this.fieldName = fieldName;
            this.value = value;
        }
    }

}