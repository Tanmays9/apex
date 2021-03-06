@isTest
public with sharing class Inbound_Email_Test {
    @TestSetup
    static void makeData(){
        contactDataFactory.contactAndAccountCreate(1, 0);
    }
    
    public static Messaging.InboundEmailResult initialize(string message) {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Create Draft';
        email.fromAddress = 'tanmays040@gmail.com';
        email.plainTextBody = message;
        Inbound_Email_Handler inb = new Inbound_Email_Handler();
        return inb.handleInboundEmail(email, env);
    }

    @isTest
     static void invalidObjectTest() {
        String message = 'asdf';
        Messaging.InboundEmailResult result = initialize(message);
        system.assertEquals(false, result.success, 'Result not valid');
        system.assertEquals('Incorrect Object Name Or Lable :'+message+'\n', result.message, 'Incorrect Message Response');
    }
    @isTest
     static void caseSensitivityTest() {
        String message = 'conTACT';
        Messaging.InboundEmailResult result = initialize(message);
        system.assertEquals(false, result.success, 'Result not valid');
        system.assert(result.message.contains(' Did You Mean ? \nContact - Lable OR contact - Name '), 'Invalid message');

    }

    @isTest
     static void noFieldTest() {
        String message = 'contact';
        Messaging.InboundEmailResult result = initialize(message);
        system.assertEquals(false, result.success, 'Result not valid');
        system.assert(result.message.contains('Required fields are missing: [LastName]'), 'Invalid message');
    }

    @isTest
     static void invalidFieldWithoutValueTest() {
        String message = 'contact#name';
        Messaging.InboundEmailResult result = initialize(message);
        system.assertEquals(false, result.success, 'Result not valid');
        system.assert(result.message.contains('field received name without value specified '), 'Invalid message');
    }

    @isTest
     static void invalidFieldNameTest() {
        String message = 'contact#nam#testname';
        Messaging.InboundEmailResult result = initialize(message);
        system.assertEquals(false, result.success, 'Result not valid');
        system.assert(result.message.contains('Did You Mean ? \nLast Name - Lable OR lastname - Name'), 'Invalid message');
    }
    

    @isTest
     static void invalidFieldValueTest() {
        String message = 'Account#inbBooleanTest#1234';
        Messaging.InboundEmailResult result = initialize(message);
        system.assertEquals(false, result.success, 'Result not valid');
        system.assert(result.message.contains('Invalid input expected BOOLEAN : 1234 For Field inbBooleanTest'), 'Invalid message');
    }

    @isTest
     static void validMultipleInsertOperation() {
        String message = 'Contact#Last Name#TestContact#Birthdate#22/02/2021#Email#tanmaytest@gmail.com';
        message += '##Account#name#TestAccount#inbBooleanTest#true#inbDateTime#19/01/2021 11:49:22#Annual Revenue#200000#type#Customer - Direct';
        Messaging.InboundEmailResult result = initialize(message);
        system.assertEquals(true, result.success, 'Result not valid');
        message = result.message;
        List<string> createdId = new List<String>();
         createdId.add(message.substringBetween('Contact  ID: ', '\n'));
         createdId.add(message.substringBetween('Account  ID: ', '\n'));
         contact contactTest = [SELECT ID,LastName,Account.name,BirthDate,Email FROM CONTACT WHERE ID IN :createdId ];
         system.assertEquals('TestContact',contactTest.LastName , 'Wrong Last Name for created Contact');
         system.assertEquals('tanmaytest@gmail.com', contactTest.Email, 'Wrong Email for contact');
         system.assertEquals(date.newInstance(2021, 02, 22), contactTest.Birthdate, 'Wrong Birth Date Entered');
         Account accountTest = [SELECT ID, name, inbBooleanTest__c, inbDateTime__c, AnnualRevenue, Type FROM Account WHERE ID IN :createdId ];
         system.assertEquals('TestAccount',accountTest.Name , 'Wrong Name for created Account');
         system.assertEquals(true, accountTest.inbBooleanTest__c, 'wrong Boolean Field for created Account');
         system.assertEquals(Datetime.newInstance(2021, 01, 19, 17, 19, 22), accountTest.inbDateTime__c, 'wrong Date\Time Field for created Account');
         system.assertEquals(200000, accountTest.AnnualRevenue, 'wrong Integer Field for created Account');
         system.assertEquals('Customer - Direct', accountTest.Type, 'wrong Picklist Field for created Account');

    }

    @isTest
     static void invalidMultipleInsertOperation() {
        String message = 'Contact#Last Name#TestContact#Birthdate#22-1-2001#Email#12345';
        message += '##Account#name#TestAccount#inbDateTime#datehere#Annual Revenue#none#type#retarded';
        Messaging.InboundEmailResult result = initialize(message);
        system.assertEquals(false, result.success, 'Result not valid');
        message = result.message;
        system.assert(result.message.contains('In Object contact \nInvalid input expected DATE : 22-1-2001 For Field Birthdate'), 'Invalid message');
        system.assert(result.message.contains('Please Enter Date Info In Format : DD/MM/YYYY'), 'Recommendation Not Exist For Date');
        system.assert(result.message.contains('In Object account \nInvalid input expected DATETIME : datehere For Field inbDateTime'), 'Invalid message');
        system.assert(result.message.contains('Please Enter Date Info In Format : DD/MM/YYYY hh:mm:ss'), 'Recommendation Not Exist For Date/Time');
    }
    

    @isTest
     static void validObjectWithParentFields() {
         String message = 'Contact#Last Name#TestContact#(Account$Name&Account 1)';
         Messaging.InboundEmailResult result = initialize(message);
         system.debug(result.message);
         system.assertEquals(true, result.success, 'Result not valid');
         message = result.message;
         List<string> createdId = new List<String>();
         createdId.add(message.substringBetween('Contact  ID: ', '\n'));
         List<Contact> contacts = [SELECT ID,LastName,Account.name FROM CONTACT WHERE ID IN :createdId ];
         System.assertEquals(1, contacts.size(), 'Invaid result from query');
         system.assertEquals('TestContact',contacts[0].LastName , 'Wrong Last Name for created Contact');
         system.assertEquals('Account 1', contacts[0].account.name, 'Wrong or error in Parenting ');
    }

    @isTest
     static void objectWithInvalidParentFields() {
         String message = 'Contact#Last Name#TestContact#(Account$name$Account 1$Employee$wrong)';
         Messaging.InboundEmailResult result = initialize(message);
         system.debug(result.message);
         system.assertEquals(false, result.success, 'Result not valid');
         system.assert(result.message.contains('Did You Mean ? \nEmployees - Lable OR numberofemployees - Name'), 'Invalid message');
    }

    @isTest
     static void opportunitySupportedTest() {
        String message = 'opportunity#name#testOpp#(Account$Name&Account 1)#Close Date#19/1/2021#Stage#Qualification';
        Messaging.InboundEmailResult result = initialize(message);
        system.assertEquals(true, result.success, 'Result not valid');
        List<string> createdId = new List<String>();
        createdId.add(result.message.substringBetween('Opportunity  ID: ', '\n'));
        List<Opportunity> opportunities = [SELECT ID, name, Account.name, closedate FROM Opportunity WHERE ID IN :createdId ];
        system.assertEquals('testOpp', opportunities[0].name, 'Invalid opportunity name ');
        System.assertEquals(date.newInstance(2021, 1, 19), opportunities[0].CloseDate , 'Invalid opportunity clasedate');
        system.assertEquals('Account 1', opportunities[0].account.name, 'Wrong or error in Parenting ');
    }

    
}