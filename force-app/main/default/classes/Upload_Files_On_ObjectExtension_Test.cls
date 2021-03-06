@isTest
public class Upload_Files_On_ObjectExtension_Test {
    
    @TestSetup
    static void makeData(){
        contactDataFactory.contactAndAccountCreate(1, 0);
    }

    @isTest
     static void insertAttachmnetPositive() {
        String accountId = [SELECT ID FROM ACCOUNT].ID + '';
        Blob body = Blob.valueOf('File body contents test');
        String attachmentBody = EncodingUtil.base64Encode(body);
        String attachmentName = 'Test File.txt';
        String output = '';
        system.test.startTest();
        ApexPages.StandardController str = new ApexPages.StandardController([SELECT ID FROM ACCOUNT]);
        Upload_Files_On_ObjectExtension out = new Upload_Files_On_ObjectExtension(str);
        output = Upload_Files_On_ObjectExtension.run( accountId , attachmentBody, attachmentName);

        system.test.stopTest();
        ID attId = Id.valueOf(output);
        attachment att = [SELECT ID, ParentId, Name, Body FROM Attachment WHERE ID = :attId];
        system.assertEquals(true, (accountId).containsIgnoreCase(str.getId()+'') , 'Invalid Id in standard controller');

        system.assertEquals(accountId, att.parentid   , 'Invalid Parent Id');
        system.assertEquals(attachmentName, att.Name, 'Invalid name of attachmnet');
        system.assertEquals(body, att.body , 'Invalid body of attachmnet');

    }

    

}