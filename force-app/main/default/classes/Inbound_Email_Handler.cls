/* ----------------------------------------------------------------------------
Class Name     :  Inbound_Email_Handler
Purpose        :  Handle message from email to insertrecordsalesforce@gmail.com 
                    parses message as string to retrive importent information and 
                    send response with possible suggestion if any Error.
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/

global class Inbound_Email_Handler implements Messaging.InboundEmailHandler {
    private Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    private Map<String,String> objectNamesByLables = new Map<String,String>();
    private Map<String,String> fieldNamesByLables = new Map<String,String>();

    /*
    * Constructor 
    * Description: Retrives all object names and lables from salesforce org.
    * Parameters: --
    */ 
    global Inbound_Email_Handler(){
        objectLablesAndNames();
    }

    /*
    * Method Name: handleInboundEmail
    * Description: Messaging.InboundEmailHandler interface method implementation 
                    to get the message from mail.
    * Parameters: email (Messaging.InboundEmail), envelop (Messaging.InboundEnvelope)
    * Returns:  Messaging.InboundEmailResult
    */ 
    global Messaging.InboundEmailResult handleInboundEmail (Messaging.InboundEmail email, Messaging.InboundEnvelope envelop){
        List<SObject> records = new List<SObject>();
        result.message = '';
        String emailMessage = email.plainTextBody;
        if(emailMessage.contains('\n--')){
            emailMessage = emailMessage.substringBefore('\n--');
        }
        emailMessage = emailMessage.replaceAll('\n', '');
        for(String str : emailMessage.split('##')){
            system.debug(str);
            string objectName = str.substringBefore('#');
            Map<string, string> fieldValuesByNames = new Map<String,String>();
            List<String> fields = str.substringAfter('#').split('#');
            for(Integer i = 0; i <= fields.size()-1; i += 2){
                if(fields[i].contains('(') && fields[i].contains(')') && fields[i].contains('$') ){
                    fieldValuesByNames.put(fields[i], null);
                    i--;
                }else if(fields[i] == ''){
                    continue;
                }else if(i == fields.size()-1){
                    fieldValuesByNames.put(fields[i], null);
                }else{
                    fieldValuesByNames.put(fields[i], fields[i+1]);    
                }
            }
            SObject record = createObject(objectName, fieldValuesByNames);
            if(record != null){
                records.add(record);
            }
        }
        Database.SaveResult[] results = Database.insert(records, false);
        Integer index = 0;
        for(Database.SaveResult res : results){
            if(res.isSuccess()){
                result.message += 'Successfully inserted '+ records[index++].getSObjectType().getDescribe().getLabel()+'  ID: ' + res.getId() +'\n';
            }else{
                for (Database.Error err : res.getErrors()) {
                    result.message += 'In Object '+records[index].getSObjectType().getDescribe().getLabel()+ '\n';
                    result.message += 'The following error has occurred.'+ '\n';                    
                    result.message += err.getStatusCode() + ': ' + err.getMessage()+ '\n';
                    result.message += 'fields that affected this error: ' + err.getFields() + '\n';
                }
                result.success = false;
                index++;
            }
        }
        System.debug(result.message );
        if(!system.test.isRunningTest()){
            createMail();
            if(!result.success){
                return result;
            }
            return null;
        }
        return result;
    }

    /*
    * Method Name: createMail
    * Description: creates single email messages to be sent to the Administrator regarding service status.
    * Parameters: --
    * Returns:  void
    */ 

    private void createMail(){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(!result.success){
            mail.setSubject('Insert Failed');
        }else{
            mail.setSubject('Insert Success');
        }
        mail.setReplyTo('insertrecordsalesforce@gmail.com');
        mail.setSenderDisplayName('Insert Record Server');
        mail.setPlainTextBody(result.message);
        mail.setSaveAsActivity(false);
        for(user usr : [SELECT ID FROM User WHERE Profile.Name = 'System Administrator' AND name = 'Tanmay Sharma']){
            mail.setTargetObjectId(usr.Id); 
        }
        mails.add(mail);
        Messaging.sendEmail(mails);
    }

    /*
    * Method Name: createObject
    * Description: Takes string data to create object from its fields.
    * Parameters: objectName (string), fieldValuesByNames (Map<String,String>)
    * Returns:  SObject
    */ 


    private SObject createObject(String objectName, Map<String,String> fieldValuesByNames){
        if(objectNamesByLables.containsKey(objectName)){
            objectName = objectNamesByLables.get(objectName);
            fieldNamesByLables = fildsLablesAndNames(objectName);
        }
        else if(objectNamesByLables.values().contains(objectName)){
            fieldNamesByLables = fildsLablesAndNames(objectName);
        }else{
            System.debug(objectNamesByLables);
            result.message +=  'Incorrect Object Name Or Lable :' + objectName +'\n';
            for(string s: objectNamesByLables.keySet()){
                if(s.containsIgnoreCase(objectName) || objectNamesByLables.get(s).containsIgnoreCase(objectName)){
                    result.message += ' Did You Mean ? \n';
                    result.message += s + ' - Lable OR ' + objectNamesByLables.get(s) +' - Name'+' \n';
                }
                system.debug(s + ' : ' + objectNamesByLables.get(s) );
            }
            result.success = false;
            return null;
        }
        SObject sObjectRecord;
        try {
            sObjectRecord = (SObject)(Type.forName(objectName).newInstance());
        } catch (Exception e) {
            system.debug(e);
            Result.message += 'Object Not Supported '+ objectName;
            return null;
        }
        for (String field : fieldValuesByNames.keySet() ) {
            string fieldName;
            if(fieldValuesByNames.get(field) == null){
                if(field.contains('(') && field.contains(')') && field.contains('$')){
                    List<String> output = refrenceFields(field.substringBetween('(', ')'));
                    if(output == null){
                        result.success = false;
                        return null;
                    }
                    sObjectRecord.put(output[0], output[1]);
                    continue;
                }else{
                    result.message += objectName+' field received '+field+' without value specified \n';
                    result.success = false;
                    return null;
                }
            }else if(fieldNamesByLables.containsKey(field)){
                fieldName = fieldNamesByLables.get(field);
            }else if(fieldNamesByLables.values().contains(field)){
                fieldName = field;
            }else{
                result.message += objectName + ' Wrong Field Name Or Label : ' + field +'\n';
                result.success = false;
                for(string s: fieldNamesByLables.keySet()){
                    if(s.containsIgnoreCase(field) || fieldNamesByLables.get(s).containsIgnoreCase(field)){
                        result.message += ' Did You Mean ? \n';
                        result.message += s + ' - Lable OR ' + fieldNamesByLables.get(s) +' - Name'+' \n';
                    }
                    system.debug(s + ' : ' + fieldNamesByLables.get(s) );
                }
                return null;
            }
            String fieldType = fieldType(objectName, fieldName);
            try {
                if(fieldType == 'currency' || fieldType == 'double' || fieldType == 'percent' || fieldType == 'decimal' ){
                    sObjectRecord.put(fieldName, Decimal.valueOf(fieldValuesByNames.get(field)));
                }else if (fieldType == 'boolean') {
                    if(Boolean.valueOf(fieldValuesByNames.get(field)) == false && fieldValuesByNames.get(field).containsIgnoreCase('false')){
                        sObjectRecord.put(fieldName, Boolean.valueOf(fieldValuesByNames.get(field)));
                    }else if(Boolean.valueOf(fieldValuesByNames.get(field)) != false){
                        sObjectRecord.put(fieldName, Boolean.valueOf(fieldValuesByNames.get(field)));
                    }else{
                        result.message += 'In Object '+objectName+' \n'; 
                        result.message += 'Invalid input expected '+fieldType +' : '+fieldValuesByNames.get(field)+' For Field '+field +'\n';
                        result.success = false;
                        return null;
                    }
                }else if(fieldType == 'date'){
                    List<String> dateVar = (fieldValuesByNames.get(field).substringBefore(' ')).split('/');
                    system.debug(dateVar);
                    sObjectRecord.put(fieldName,date.newInstance(Integer.valueOf(dateVar[2]), Integer.valueOf(dateVar[1]), Integer.valueOf(dateVar[0])));
                }else if(fieldType == 'datetime'){
                    List<String> dateTimeVar = (fieldValuesByNames.get(field).substringBefore(' ')).split('/');
                    dateTimeVar.addAll((fieldValuesByNames.get(field).substringAfter(' ')).split(':'));
                    system.debug(dateTimeVar);
                    sObjectRecord.put(fieldName,Datetime.newInstanceGmt(Integer.valueOf(dateTimeVar[2]), Integer.valueOf(dateTimeVar[1]), Integer.valueOf(dateTimeVar[0]), Integer.valueOf(dateTimeVar[3]), Integer.valueOf(dateTimeVar[4]), Integer.valueOf(dateTimeVar[5])));
                }else if (fieldType == 'integer' ) {
                    sObjectRecord.put(fieldName, Integer.valueOf(fieldValuesByNames.get(field)));
                }else{
                    sObjectRecord.put(fieldName, fieldValuesByNames.get(field));
                }
            } catch (Exception e) {
                system.debug(e);
                result.message += 'In Object '+objectName+' \n'; 
                result.message += 'Invalid input expected '+fieldType +' : '+fieldValuesByNames.get(field)+' For Field '+field +'\n';
                if(fieldType == 'date'){
                    result.message += ' Please Enter Date Info In Format : DD/MM/YYYY \n';
                }else if(fieldType == 'datetime'){
                    result.message += ' Please Enter Date Info In Format : DD/MM/YYYY hh:mm:ss \n';
                }
                result.success = false;
                return null;
            }
        }
        return sObjectRecord;
    }

    /*
    * Method Name: refrenceFields
    * Description: To handle relational fields of objects via query.
    * Parameters: parentFields (string)
    * Returns:  List<String>
    */ 

    private List<String> refrenceFields(string parentFields){
        List<String> output = new List<String>();
        Map<String,String> fieldsAndValues = new Map<String,String>();
        String parentName = (parentFields.substringBefore('$'));
        List<String> fields = (parentFields.substringAfter('$')).split('\\$');
        system.debug(fields);
        for(Integer i = 0; i < fields.size()-1; i += 2){
            fieldsAndValues.put(fields[i], fields[i+1]);
        }
        if(objectNamesByLables.containsKey(parentName)){
            parentName = objectNamesByLables.get(parentName);
        }else if(objectNamesByLables.values().contains(parentName)){
            parentName = parentName;
        }else{
            result.message += 'Invalid Parent Object Name ' + parentName +'\n';
            return null;
        }
        if(!fieldNamesByLables.values().contains(parentName + 'id')){
            result.message += 'Parent Refrence Field Not Found ' + parentName+'id' +'\n';
            return null;
        }
        Map<String,String> parentFieldsNamesAndValues = fildsLablesAndNames(parentName);
        String query = 'SELECT ID FROM '+ parentName + ' WHERE ID != null ';
        for(string str: fieldsAndValues.keySet()){
            if(parentFieldsNamesAndValues.containsKey(str)){
                query += ' AND '+ parentFieldsNamesAndValues.get(str) +' = '+ fieldsAndValues.get(str);
            }else if(parentFieldsNamesAndValues.values().contains(str)){
                query += ' AND '+ str +' = \''+ fieldsAndValues.get(str)+'\'';
            }else{
                result.message += ' Invalid Field Name '+str+' \n';
                for(string s: parentFieldsNamesAndValues.keySet()){
                    if(s.containsIgnoreCase(str) || parentFieldsNamesAndValues.get(s).containsIgnoreCase(str)){
                        result.message += ' Did You Mean ? \n';
                        result.message += s + ' - Lable OR ' + parentFieldsNamesAndValues.get(s) +' - Name'+' \n';
                    }
                    system.debug(s + ' : ' + parentFieldsNamesAndValues.get(s));
                }
                return null;
            }
        }
        List<sobject> records = Database.query(query);
        if(records.size() != 1 ){
            result.message += ' Invalid Resulting Records Not Unique '+query+' \n';
            return null;
        }
        output.add(parentName+'Id');
        output.add(records[0].Id);
        return output;
    }

    /*
    * Method Name: fieldType
    * Description: used to get the field type value in string to dynamicaly allocate field values of different datatypes.
    * Parameters: objectName (string), fieldName (string)
    * Returns:  String
    */ 

    private String fieldType(string objectName, string fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType().name();
    }

    /*
    * Method Name: objectLablesAndNames
    * Description: Retrives all the object names and lables and stores then in map for data validation.
    * Parameters: --
    * Returns:  void
    */ 

    private void objectLablesAndNames(){
        Map<String,Schema.SObjectType> mapNameAndObjectType =Schema.getGlobalDescribe();
        for(string str :mapNameAndObjectType.keySet()){
            if(validateObjectAndField(mapNameAndObjectType.get(str))){
                objectNamesByLables.put(mapNameAndObjectType.get(str).getDescribe().getLabel(), str);
            }
        }
    }

    /*
    * Method Name: fildsLablesAndNames
    * Description: Retrives all the filed names and lables and stores then in map for field data validation.
    * Parameters: objectName (string)
    * Returns:  Map<String,String>
    */ 
  

    private Map<String,String> fildsLablesAndNames(string objectName){
        Map<string,schema.SObjectField> mapNameAndField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        Map<String,String> fieldsAndLabels = new Map<String,String>();
        for(string str :mapNameAndField.keySet()){
            system.debug(str +' : '+ mapNameAndField.get(str).getDescribe().getLabel());
            if(fieldsAndLabels.containsKey(mapNameAndField.get(str).getDescribe().getLabel())){
                fieldsAndLabels.put(mapNameAndField.get(str).getDescribe().getLabel(), 'Invalid');
            }else if(validateObjectAndField(mapNameAndField.get(str))){
                fieldsAndLabels.put(mapNameAndField.get(str).getDescribe().getLabel(), str);
            }
        }
        return fieldsAndLabels;
    }

     /*
    * Method Name: validateObjectAndField
    * Description: generic validator to validate objects of their creatable property so that there is no issue creating these objects and fields.
    * Parameters: obj (Object)
    * Returns:  Boolean
    */ 

    private Boolean validateObjectAndField(Object obj){
        if(obj instanceof Schema.SObjectType){
            Schema.DescribeSObjectResult objResult = ((Schema.SObjectType)obj).getDescribe();
            if(objResult.isCreateable()){
                return true;
            }
        }else if(obj instanceof Schema.SObjectField){
            Schema.DescribeFieldResult fieldResult = ((Schema.SObjectField)obj).getDescribe();
            if(fieldResult.isCreateable()){
                return true;
            }
        }else{
            result.message += obj + ' Not An Instance OF Either Object, Field \n';
        }
        return false;
    }

}