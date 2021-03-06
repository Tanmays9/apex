@isTest
public with sharing class TypeAhead_Controller_Test {
    
    @TestSetup
    static void makeData(){
        contactDataFactory.contactAndAccountCreate(10, 5);
    }

    @isTest
     static void searchSuggestionTest() {
        Id [] fixedSearchResults = new Id[10];
        integer index =0;
         for(Account acc : [select id,name from account]){
            fixedSearchResults[index++] = acc.Id;
         }
        system.Test.setFixedSearchResults(fixedSearchResults);
        TypeAhead_Controller testObj = new TypeAhead_Controller();
        List<TypeAhead_Controller.SobjectWrapper> testWrapperObjList  = new list<TypeAhead_Controller.SobjectWrapper>();
        system.Test.startTest();
        testWrapperObjList  = TypeAhead_Controller.searchSuggestion('Ac', 'Account', 'Name');
        system.Test.stopTest();
        system.assertEquals(10, testWrapperObjList .size(), 'Improper suggestion records');
        integer i = 0;
        for(TypeAhead_Controller.SobjectWrapper  singleSuggestion : testWrapperObjList ){
            system.assert( testWrapperObjList[i++].label.contains('Ac'), 'Invalid retrived records');
        }
    }

    @isTest
     static void searchSuggestionTestNegative() {
        Id [] fixedSearchResults = new Id[10];
        integer index =0;
         for(Account acc : [select id,name from account]){
            fixedSearchResults[index++] = acc.Id;
         }
        system.Test.setFixedSearchResults(fixedSearchResults);
        TypeAhead_Controller testObj = new TypeAhead_Controller();
        List<TypeAhead_Controller.SobjectWrapper> testWrapperObjList  = new list<TypeAhead_Controller.SobjectWrapper>();
        system.Test.startTest();
        testWrapperObjList  = TypeAhead_Controller.searchSuggestion('con', 'Account', 'Name');
        system.Test.stopTest();
        system.assertEquals(0, testWrapperObjList .size(), 'Improper suggestion records');
        
    }
    
    @isTest
     static void retriveRecordTest() {
        TypeAhead_Controller testObj = new TypeAhead_Controller();
        testObj.recordID = [select id from account WHERE NAME = 'Account 1' Limit 1].id;
        testObj.retriveRecord();
        system.assertEquals('Account 1', testObj.recordValues.get(0), 'invalid Records Retrived');
    }

    @isTest
     static void retriveRecordDuplicateTest() {
        TypeAhead_Controller testObj = new TypeAhead_Controller();
        testObj.recordID = [select id from account WHERE NAME = 'Account 1' Limit 1].id;
        testObj.retriveRecord();
        testObj.retriveRecord();
        system.assertEquals('<duplicate>', testObj.recordValues.get(0), 'invalid Records Retrived');
    }

    @isTest
     static void saveRecordsTest() {
        TypeAhead_Controller testObj = new TypeAhead_Controller();
        testObj.recordID = [select id from account WHERE NAME = 'Account 1' Limit 1].id;
        testObj.retriveRecord();
        testObj.updateRecordsValues = '0#Account Name#UpdatedAccount#Website#Weblink#Employees#90#Industry#production#Account Type#customer#Active#Yes##';
        testObj.saveRecords();
        Account Acc = [select Name, Website, NumberOfEmployees, Industry, Type, Active__c  from account WHERE Id = :testObj.recordID Limit 1];
        system.assertEquals('UpdatedAccount', Acc.Name, 'Record Name Not updated');
        system.assertEquals('Weblink', acc.Website, 'Record website Not updated');
        system.assertEquals(90, acc.NumberOfEmployees, 'Record employees No Not updated');
        system.assertEquals('production', acc.Industry  , 'Record industry not updated');
        system.assertEquals('Yes', acc.Active__c, ' Record Boolean Fields not updated');
    }

    @isTest
     static void saveRecordsInvalidTest() {
        TypeAhead_Controller testObj = new TypeAhead_Controller();
        testObj.recordID = [select id from account WHERE NAME = 'Account 1' Limit 1].id;
        testObj.retriveRecord();
        testObj.updateRecordsValues = '0#Account Name#UpdatedAccount#Website#Weblink#Employees#wrongInput##';
        testObj.saveRecords();
        Account Acc = [select Name, Website, NumberOfEmployees, Industry, Type, Active__c  from account WHERE Id = :testObj.recordID Limit 1];
        system.assertEquals('Account 1', Acc.Name, 'Record invalid data updated');
    }

}