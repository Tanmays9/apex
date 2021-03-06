@isTest
public class Contact_Status_Update_Test {

    @TestSetup
    static void makeData(){
        contactDataFactory.contactCreate(10,false);
       Datetime yesterday = Datetime.now().addDays(-1);
       for(Id cntId : contactDataFactory.contactCreate(10,true)){
            system.test.setCreatedDate(cntId, yesterday);
       }
    }

    public static Contact_Status_Update initialize() {
        Contact_Status_Update c = new Contact_Status_Update();
        Database.executeBatch(c);
        return c;
    }

    @isTest
     static void testBatch() {
         system.test.startTest();
         Contact_Status_Update output = initialize();
        system.test.stopTest();
        for ( contact cnt : [SELECT ID, Status__c, LastName FROM Contact WHERE createddate = YESTERDAY ]) {
            System.assertEquals('Ready for Approval', cnt.Status__c, 'Invalid Status Of Contacts Created Yesterday'+ cnt.LastName);
        }
        for ( contact cnt : [SELECT ID, Status__c, LastName FROM Contact WHERE createddate  = TODAY ]) {
            system.assertNotEquals('Ready for Approval', cnt.Status__c, 'Invalid Status Of Contacts Created Today' + cnt.LastName);
        }
        
    }

    @isTest
     static void testBatchEmpty() {
         List<Contact> updateCon = new List<Contact>();
        for ( contact cnt : [SELECT ID, Status__c, LastName FROM Contact ]) {
            cnt.Status__c = null;
            system.test.setCreatedDate(cnt.Id, Datetime.now().addDays(-5));
            updateCon.add(cnt);
        }
        update updateCon;
        system.test.startTest();
        Contact_Status_Update output = initialize();
        system.test.stopTest();
        for ( contact cnt : [SELECT ID, Status__c, LastName FROM Contact ]) {
            System.assertNotEquals('Ready for Approval', cnt.Status__c, 'Invalid Status Of Contacts Created 5 Days ago '+ cnt.LastName);
        }
    }

    @isTest
     static void schedularMethodTest() {
        system.test.startTest();
        Contact_Status_Update batcher = new Contact_Status_Update();
        String sch = '0 0 2 * * ?'; 
        String jobId = system.schedule('Test_scheduler',sch,batcher);
        system.test.stopTest();
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(sch, ct.CronExpression );
    }
}