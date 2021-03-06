/* ----------------------------------------------------------------------------
Class Name     :  Contact_Status_Update
Purpose        :  Batched Processing Data Of Multiple Records Inserted Yesterday
Interfaces : 
Database.Batchable<SObject> : For the purpose of processing records in the form of batches asynchronous.
Database.Stateful : For maintaining the state of the member variables of the class to count records
                     processed and store their data for future use.
Schedulable : For scheduling batch processing of records over a specific periods of time.
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/
global class Contact_Status_Update implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    public Integer recordsProcessed = 0;
    public String csvDoc ='';
    public Map<String,string> fieldNameByLable = new Map<String,String>();

     /*
    * Method Name: start
    * Description: Batchable interface implementation method for initilaization of batch of records
    * Parameters: bc (Database.BatchableContext)
    * Returns:  Database.QueryLocator
    */ 

    global Database.QueryLocator start(Database.BatchableContext bc){
        map<String, Schema.SObjectField> contactFields = schema.getGlobalDescribe().get('contact').getDescribe().fields.getMap();
        for(string str : contactFields.keySet()){
            fieldNameByLable.put(contactFields.get(str).getDescribe().getLabel(), str );
        }
        String query = 'SELECT ';
        query += string.join( new List<String>(fieldNameByLable.values()), ', ');
        query += ' FROM Contact Where createddate = YESTERDAY ';
        return Database.getQueryLocator(query);
    }

     /*
    * Method Name: execute
    * Description: Batchable interface implementation method for processing of batch of records
    * Parameters: bc (Database.BatchableContext), contactList (List<Contact>)
    * Returns:  void
    */ 

    global void execute (Database.BatchableContext bc, List<Contact> contactList){
        Boolean first = true;
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact cnt : contactList){
            if(cnt.Status__c != 'Ready for Approval'){
                cnt.Status__c = 'Ready for Approval';
                contactsToUpdate.add(cnt);
            }
            if(first && recordsProcessed == 0){
                for(String str: fieldNameByLable.keySet()){
                    csvDoc += str.escapeCsv() + ',';
                }
                csvDoc = csvDoc.removeEnd(',');
                first = false;
                csvDoc += '\n';
            }
            for(string fieldName : fieldNameByLable.values()){
                string value = '';
                if(cnt.get(fieldName) instanceof Date ){
                    Date dateVal = (Date)cnt.get(fieldName);
                    value += dateVal.day() + '/' +dateVal.month()+'/'+dateVal.year();
                }else if(cnt.get(fieldName) instanceof Datetime ){
                    Datetime dateTimeVal = (Datetime)cnt.get(fieldName);
                    value += dateTimeVal.day()+'/'+dateTimeVal.month()+'/'+dateTimeVal.year() +' '+dateTimeVal.hour()+':'+dateTimeVal.minute()+':'+dateTimeVal.second();
                }else if(cnt.get(fieldname) != null){
                    value += cnt.get(fieldname);
                }
                csvDoc += value.escapeCsv() + ',';
            }
            csvDoc = csvDoc.removeEnd(',');
            csvDoc +='\n';
        }
        recordsProcessed += contactList.size();
        update contactsToUpdate;
    }

      /*
    * Method Name: finish
    * Description: Batchable interface implementation method for executing functionality after batch processing is finished
    * Parameters: bc (Database.BatchableContext)
    * Returns:  void
    */ 

    global void finish (Database.BatchableContext bc){
        if(recordsProcessed == 0){
            return;
        }
        Datetime today = Datetime.now();
        String todayString = today.day() +'/'+today.month()+'/'+today.year() + ' ' + today.hour()+':'+today.minute()+':'+today.second() ;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        for(user usr : [SELECT ID FROM User WHERE Profile.Name = 'System Administrator' AND name = 'Tanmay Sharma']){
            email.setTargetObjectId(usr.Id); 
        }
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        blob csvBlob = blob.valueOf(csvDoc);
        csvAttachment.setFileName(' New Contacts ' + todayString.substringBefore(' ') +'.csv');
        csvAttachment.setBody(csvBlob);
        email.setPlainTextBody('Contacts Ready For Approval as of '+ todayString );
        email.setSubject( recordsProcessed + ' Contacts Ready For Approval As Of Today ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        email.setSaveAsActivity(false);
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email} );
        for (Database.Error e : r[0].errors) {
            system.debug(e);
        }
    }

     /*
    * Method Name: execute
    * Description: Schedulable interface implementation method to execute batch over a period of time
    * Parameters: ctx (SchedulableContext)
    * Returns:  void
    */ 

    global void execute(SchedulableContext ctx){
        Contact_Status_Update c = new Contact_Status_Update();
        Database.executeBatch(c);
    }
}