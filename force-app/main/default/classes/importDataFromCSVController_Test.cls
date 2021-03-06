@isTest
public class importDataFromCSVController_Test {

    @isTest
     static void simpleValidInput() {
        String input = 'Last Name,Description,Active,Birthdate,Connected On\r\n';
        input += 'Test User 1,Description,TRUE,1-2-2021 8:02,1-2-2021 05:06\r\n';
        input += 'Test User 2,Description,FALSE,1-2-2021 8:02,1-2-2021 05:06\r\n';
        importDataFromCSVController csvController = new importDataFromCSVController();
        system.Test.startTest();
        csvController.csvFileContents = blob.valueOf(input);
        csvController.importCSVFile();
        List<Contact> conList = [SELECT ID, Lastname, Description, Active__c, Birthdate, Connected_On__c FROM Contact];
        system.Test.stopTest();
        system.assertEquals(2, conList.size(), 'contacts failed to insert');
        system.assertEquals('Test User 1', conList[0].Lastname, 'Invalid Last name for 0');
        system.assertEquals('Test User 2', conList[1].Lastname, 'Invalid Last name for 1');
        system.assertEquals('Description', conList[0].Description, 'Invalid Description');
        system.assertEquals(true, conList[0].Active__c, 'Invalid boolean field value Active__c');
        System.assertEquals(date.newInstance(2021, 02, 01), conList[0].Birthdate, 'Invalid Date field value Birthdate');
        System.assertEquals(Datetime.newInstance(2021, 02, 01, 05, 06, 00), conList[0].Connected_On__c, 'Invalid Datetime field value Connected_On__c');
    }

    @isTest
     static void simpleInValidInput() {
        String input = 'Last Name,Description,Active,Birthdate,Connected On\r\n';
        input += ',Description,TRUE,1-2-2021 8:02,1-2-2021 05:06\r\n';
        input += 'Test User 2,Description,FALSE,1-2-2021 8:02,1-2-2021 05:06\r\n';
        importDataFromCSVController csvController = new importDataFromCSVController();
        system.Test.startTest();
        csvController.csvFileContents = blob.valueOf(input);
        csvController.importCSVFile();
        List<Contact> conList = [SELECT ID, Lastname, Description, Active__c, Birthdate, Connected_On__c FROM Contact];
        system.Test.stopTest();
        system.assertEquals(0, conList.size(), 'contacts failed to insert');
        
    }

    @isTest
     static void simpleValidEmptyInputs() {
        String input = 'Last Name,Description,Active,Birthdate,Connected On\r\n';
        input += 'Test User 1,,,,\r\n';
        input += 'Test User 2,Description,FALSE,1-2-2021 8:02,1-2-2021 05:06\r\n';
        importDataFromCSVController csvController = new importDataFromCSVController();
        system.Test.startTest();
        csvController.csvFileContents = blob.valueOf(input);
        csvController.importCSVFile();
        List<Contact> conList = [SELECT ID, Lastname, Description, Active__c, Birthdate, Connected_On__c FROM Contact];
        system.Test.stopTest();
        system.assertEquals(2, conList.size(), 'contacts failed to insert');
        system.assertEquals('Test User 1', conList[0].Lastname, 'Invalid Last name for 0');
        system.assertEquals(null, conList[0].Description, 'Invalid Description');
        system.assertEquals(false, conList[0].Active__c, 'Invalid boolean field value Active__c');
        System.assertEquals(null, conList[0].Birthdate, 'Invalid Date field value Birthdate');
        System.assertEquals(null, conList[0].Connected_On__c, 'Invalid Datetime field value Connected_On__c');
    }

    @isTest
     static void complexTextAreaField() {
        String input = 'Last Name,Description,Active,Birthdate,Connected On\r\n';
        input += 'Test User 1,"""D\nes\nc,,ri"",""pt\nion""",TRUE,1-2-2021 8:02,1-2-2021 05:06\r\n';
        input += 'Test User 2,Description,FALSE,1-2-2021 8:02,1-2-2021 05:06\r\n';
        importDataFromCSVController csvController = new importDataFromCSVController();
        system.Test.startTest();
        csvController.csvFileContents = blob.valueOf(input);
        csvController.importCSVFile();
        List<Contact> conList = [SELECT ID, Lastname, Description, Active__c, Birthdate, Connected_On__c FROM Contact];
        system.Test.stopTest();
        system.assertEquals(2, conList.size(), 'contacts failed to insert');
        system.assertEquals('"D\nes\nc,,ri","pt\nion"', conList[0].Description, 'Invalid Description');
    }

}