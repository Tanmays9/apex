@isTest
public class Custom_Pagination_Controller_TestClass {

    @TestSetup
     static void dataGen() {
        contactDataFactory.contactCreate(50);
    }

    @isTest
     static void resetTest() {
        system.test.startTest();
        Custom_Pagination_Controller testObject = new  Custom_Pagination_Controller();
        testObject.objectName = 'contact';
        testObject.retriveFields();
        testObject.selectedFieldsOption = null;
        testObject.selectedFields = new List<String>();
        for(Integer i = 0 ; i < testObject.allFields.size() ; i += 2){
            testObject.selectedFields.add(testObject.allFields[i].getValue());
        }
        PageReference pageRef = Page.Custom_Pagination;
        system.Test.setCurrentPage(pageRef);
        testObject.reset();
        system.test.stopTest();
        system.assertEquals(null , testObject.objectName, 'object not null');
        system.assertEquals(null, testObject.allFields, 'Field list not null');
        system.assertEquals(null, testObject.selectedFields, 'selected fields not null');
        system.assertEquals(null, testObject.objectNameOutput, 'output object name not null');
        system.assertEquals(null, testObject.fieldListOutput, 'output field list not null');
    }

    @isTest
     static void objectSelectList() {
        system.test.startTest();
        Custom_Pagination_Controller testObject = new  Custom_Pagination_Controller();
        Integer Ittr = 0;
        for(SelectOption s: testObject.allObjects){
            testObject.allFields = null;
            testObject.objectName = s.getValue();
            testObject.retriveFields();
            System.assertEquals(TRUE, testObject.allFields.size() >0 , ' ZERO FIELDS OR ERROR IN FIELDS RETRIVE :' + testObject.objectName +' ' );
            Ittr++;
        }
        system.test.stopTest();
        system.assertEquals(testObject.allObjects.size(), ittr, 'No of objects and itterarion does not match');
        System.assertEquals(testObject.allObjects.get(testObject.allObjects.size()-1).getValue(), testObject.objectName, ' Object last does not match ');
    }

    @isTest
     static void fieldSelectList() {
        system.test.startTest();
        Custom_Pagination_Controller testObject = new  Custom_Pagination_Controller();
        testObject.objectName = 'contact';
        testObject.retriveFields();
        testObject.selectedFieldsOption = null;
        testObject.selectedFields = new List<String>();
        Integer ittr = 0;
        for(Integer i = 0 ; i < testObject.allFields.size() ; i += 2){
            testObject.selectedFields.add(testObject.allFields[i].getValue());
            ittr++;
        }
        testObject.selectFields();
        testObject.deselectedFields = new List<String>();
        testObject.deselectedFields.add(testObject.selectedFieldsOption[0].getValue());
        ittr--;
        testObject.deselectFields();
        system.test.stopTest();
        System.assertEquals(TRUE, testObject.selectedFieldsOption.size() == ittr , ' All Fields not inserted in select option');
        for(Integer j = 0  ; j < testObject.selectedFieldsOption.size(); j++ ){
            for(Integer i = 0  ; i < testObject.allFields.size(); i++ ){
                System.assertEquals(TRUE, testObject.selectedFieldsOption[j].getValue() != testObject.allFields[i].getValue() , ' Field matched b/w lists of selected');
            }
        }
    }


    @isTest
     static void outputFieldsAndObject_Test() {
        system.test.startTest();
        Custom_Pagination_Controller testObject = new  Custom_Pagination_Controller();
        testObject.objectName = 'contact';
        testObject.retriveFields();
        testObject.selectedFields = new List<String>{'LastName'};
        testObject.selectFields();
        testObject.outputFieldsAndObject();
        system.test.stopTest();
        System.assertEquals('contact', testObject.objectNameOutput, 'Wrong object name output');
        System.assertEquals('LastName', testObject.fieldListOutput[0], 'Wrong field list output');
        
    }

    @isTest
     static void processQuery_Test() {
         system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName'};
        testObject.size = 5;
        testObject.processQuery();
        Integer recordsCount = [SELECT count() FROM Contact];
        system.test.stopTest();
        system.assertEquals(recordsCount, testObject.noOfRecords, 'Invalied no of records value');
        if(testObject.noOfRecords == 0){
            system.assertEquals( 0, testObject.pageNumber, 'Page no invalid');
            system.assertEquals(0, testObject.totalPages, 'Total pages count invalid');
        }else{
            system.assertEquals( 1, testObject.pageNumber, 'Page no invalid');
            system.assertEquals(TRUE, testObject.totalPages != 0, 'Total pages count invalid');
            system.assertEquals((testObject.noOfRecords < testObject.size? testObject.noOfRecords:testObject.size ), testObject.records.size(),'Improper amount of records of wrapper class' );
        }
    }
    
    @isTest
     static void addWrapperToMap_Test() {
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.records[1].isSelected = true;
        testObject.addWrapperToMap();
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        testObject.records[1].isSelected = false;
        testObject.addWrapperToMap();
        system.assertEquals(testObject.records[0].sobjectRecord, testObject.mapRecordList.get(new List<ID>(testObject.mapRecordList.keySet())[0]).sobjectRecord, 'invalid map of selected records');
        system.assertEquals(1, testObject.mapRecordList.size(),'Record not selected');
        
    }


    @isTest
     static void next_Method_test() {
        Id recordId;
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.records[1].isSelected = true;
        testObject.addWrapperToMap();
        recordId = testObject.records[4].sobjectRecord.Id;
        system.test.stopTest(); 
        testObject.next();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        system.assertEquals(True, testObject.records[0].sobjectRecord.Id < recordId, 'Invalid retrival by Id of records');
        system.assertEquals(True, testObject.hasNext && testObject.hasPrevious, 'Invalid hasNext and has previous after next');
        system.assertEquals(2, testObject.pageNumber, 'Invalid page no after next');
    }

    @isTest
     static void previous_Method_test() {
        Id recordId;
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.records[1].isSelected = true;
        testObject.addWrapperToMap();
        testObject.next();
        recordId = testObject.records[4].sobjectRecord.Id;
        system.test.stopTest(); 
        testObject.previous();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        system.assertEquals(True, testObject.records[0].sobjectRecord.Id > recordId, 'Invalid retrival by Id of records');
        system.assertEquals(false, testObject.hasPrevious, 'Invalid previous after previous');
        system.assertEquals(true, testObject.hasNext, 'Invalid hasNext  after previous');
        system.assertEquals(1, testObject.pageNumber, 'Invalid page no after next');
    }

    @isTest
     static void last_Method_test() {
        Id recordId;
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.records[1].isSelected = true;
        testObject.addWrapperToMap();
        testObject.next();
        testObject.previous();
        testObject.next();
        recordId = new list<contact>([SELECT ID FROM Contact  Order by Id ASC LIMIT 1])[0].Id;
        testObject.last();
        system.test.stopTest(); 
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        system.assertEquals(True, testObject.records[4].sobjectRecord.Id == recordId, 'Invalid retrival by Id of records');
        system.assertEquals(true, testObject.hasPrevious, 'Invalid previous after previous');
        system.assertEquals(false, testObject.hasNext, 'Invalid hasNext  after previous');
        system.assertEquals(testObject.totalPages, testObject.pageNumber, 'Invalid page no after next');
    }

    @isTest
     static void orderByCharacter_Test_positive() {
        Id recordId;
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.records[1].isSelected = true;
        testObject.addWrapperToMap();
        recordId = new list<contact>([SELECT ID FROM Contact WHERE NAME LIKE 'c%' order by Id DESC  LIMIT 1])[0].Id;
        testObject.charLike = 'c';
        testObject.first();
        system.test.stopTest(); 
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        system.assertEquals(50, testObject.noOfRecords, 'Invalid sort by character');
        system.assertEquals(True, testObject.records[0].sobjectRecord.Id == recordId, 'Invalid retrival by Id of records');

    }

    @isTest
     static void orderByCharacter_Test_negative() {
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName','FirstName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.records[1].isSelected = true;
        testObject.addWrapperToMap();
        testObject.charLike = 'other';
        testObject.first();
        system.test.stopTest(); 
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        system.assertEquals(0, testObject.noOfRecords, 'Invalid sort by character');
    }
    @isTest
     static void sortInit_Test_ascending() {
        Id recordId;
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName','FirstName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.records[1].isSelected = true;
        testObject.addWrapperToMap();
        testObject.sortField='LastName';
        recordId = new list<contact>([SELECT ID FROM Contact  Order by LastName ASC , ID DESC LIMIT 1])[0].Id;
        testObject.sortInit();
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.records[0].sobjectRecord.Id, 'INVALID FIELD SORT');
    }

    @isTest
     static void sortInit_Test_descending() {
        Id recordId ;
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName','FirstName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.records[1].isSelected = true;
        testObject.addWrapperToMap();
        testObject.sortField='LastName';
        testObject.sortInit();
        testObject.assendingOrder = true;
        testObject.sortInit();
        recordId = new list<contact>([SELECT ID FROM Contact  Order by LastName DESC , ID DESC LIMIT 1])[0].Id;
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.records[0].sobjectRecord.Id, 'INVALID FIELD SORT');
    }

    @isTest
     static void singleDelete_Test() {
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName','FirstName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.addWrapperToMap();
        testObject.selectedSobject = testObject.records[0].sobjectRecord.Id;
        testObject.singledelete();
        system.test.stopTest(); 
        system.assertEquals(49, testObject.noOfRecords, 'Invalid value of records count');

    }

    
    @isTest
     static void singleDelete_Test_failed() {
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName','FirstName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.addWrapperToMap();
        testObject.selectedSobject = testObject.records[0].sobjectRecord.Id;
        case c = new case(Origin = 'Phone',ContactId = testObject.selectedSobject);
        insert c;
        testObject.singledelete();
        system.test.stopTest(); 
        system.assertEquals(50, testObject.noOfRecords, 'Invalid value of records count');
    }

    @isTest
     static void deleteSelected_Test() {
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName','FirstName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.records[1].isSelected = true;
        case c = new case(Origin = 'Phone',ContactId = testObject.records[0].sobjectRecord.Id);
        insert c;
        testObject.addWrapperToMap();
        testObject.deleteSelected();
        system.test.stopTest(); 
        system.assertEquals(49, testObject.noOfRecords, 'Invalid value of records count');
    }

    @isTest
     static void createCSV_Test() {
        system.test.startTest();
        Custom_Pagination_Component_controller testObject = new Custom_Pagination_Component_controller();
        testObject.objectName = 'contact';
        testObject.listofFields = new List<String>{'LastName','FirstName'};
        testObject.size = 5;
        testObject.processQuery();
        testObject.records[0].isSelected = true;
        testObject.addWrapperToMap();
        testObject.createCSV();
        system.test.stopTest(); 
        Contact c = (contact)testObject.records[0].sobjectRecord;
        system.assertEquals(TRUE, testObject.csvFile.contains(''+c.LastName) && testObject.csvFile.contains(''+c.FirstName), 'Wrong data in csv file  ');
        c = (contact)testObject.records[1].sobjectRecord;
        system.assertEquals(FALSE, testObject.csvFile.contains(''+c.LastName) && testObject.csvFile.contains(''+c.FirstName), 'Wrong data in csv file  '); 
    }


    

    
}