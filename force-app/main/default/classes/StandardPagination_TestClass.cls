@isTest
public class StandardPagination_TestClass {
    
    @TestSetup
    static void makeData(){
        contactDataFactory.contactCreate(50);

    }

    @isTest
     static void init_Test() {
         system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        Integer recordsCount = [SELECT count() FROM Contact];
        system.test.stopTest();
        system.assertEquals(recordsCount, testObject.noOfRecords, 'Invalied no of recordList value');
        if(testObject.noOfRecords == 0){
            system.assertEquals( 0, testObject.pageNumber, 'Page no invalid');
            system.assertEquals(0, testObject.totalPages, 'Total pages count invalid');
        }else{
            system.assertEquals( 1, testObject.pageNumber, 'Page no invalid');
            system.assertEquals(TRUE, testObject.totalPages != 0, 'Total pages count invalid');
            system.assertEquals((testObject.noOfRecords < testObject.size? testObject.noOfRecords:testObject.size ), testObject.recordList.size(),'Improper amount of recordList of wrapper class' );
        }    
    }

    @isTest
     static void orderByCharacter_Test_positive() {
        Id recordId;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap();
        recordId = new list<contact>([SELECT ID FROM Contact WHERE NAME LIKE 'c%' LIMIT 1])[0].Id;
        testObject.charLike = 'c';
        testObject.universalQuery();
        system.test.stopTest(); 
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        system.assertEquals(50, testObject.noOfRecords, 'Invalid sort by character');
        system.assertEquals(True, testObject.recordList[0].contactRecord.Id == recordId, 'Invalid retrival by Id of recordList');

    }

    @isTest
     static void orderByCharacter_Test_negative() {
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap();
        testObject.charLike = 'other';
        insert new contact (LastName = '53test');
        testObject.universalQuery();
        system.test.stopTest(); 
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        system.assertEquals(1, testObject.noOfRecords, 'Invalid sort by character');
    }
    @isTest
     static void sortInit_Test_ascending() {
        Id recordId;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap();
        testObject.sortField='LastName';
        recordId = new list<contact>([SELECT ID FROM Contact  Order by LastName ASC LIMIT 1])[0].Id;
        testObject.sortInit();
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.recordList[0].contactRecord.Id, 'INVALID FIELD SORT');
    }

    @isTest
     static void sortInit_Test_descending() {
        Id recordId ;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap();
        testObject.sortField='LastName';
        testObject.sortInit();
        testObject.assendingOrder = true;
        testObject.sortInit();
        recordId = new list<contact>([SELECT ID FROM Contact  Order by LastName DESC LIMIT 1])[0].Id;
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.recordList[0].contactRecord.Id, 'INVALID FIELD SORT');
    }

    @isTest
     static void pageNoChanged_Test_positive() {
        Id recordId ;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap(); 
        testObject.pageNumber = 2;
        testObject.pageNoChanged();
        recordId = new list<contact>([SELECT ID FROM Contact  LIMIT 1  OFFSET 5])[0].Id;
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.recordList[0].contactRecord.Id, 'INVALID FIELD SORT');
        system.assertEquals(True, testObject.hasNext && testObject.hasPrevious, 'Invalid hasNext and has previous after next');
    }
    @isTest
     static void pageNoChanged_Test_negative() {
        Id recordId ;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap(); 
        testObject.next();
        testObject.pageNumber = testObject.totalPages + 1;
        testObject.pageNoChanged();
        recordId = new list<contact>([SELECT ID FROM Contact  LIMIT 1  OFFSET 5])[0].Id;
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.recordList[0].contactRecord.Id, 'INVALID FIELD SORT');
        system.assertEquals(True, testObject.hasNext , 'Invalid hasNext ');
        system.assertNotEquals(testObject.totalPages + 1, testObject.pageNumber, 'Invalid page number');
    }
    @isTest
     static void pageSizeChanged_Test() {
        Id recordId ;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap(); 
        testObject.next();
        testObject.size = 10;
        testObject.pageSizeChange();
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        system.assertEquals(True, testObject.hasNext , 'Invalid hasNext ');
        System.assertEquals(10, testObject.recordList.size(), 'Invalid list retrived');
    }

    @isTest
     static void next_Test() {
        Id recordId ;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap(); 
        testObject.next();
        testObject.next();
        recordId = new list<contact>([SELECT ID FROM Contact  LIMIT 1  OFFSET 10])[0].Id;
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.recordList[0].contactRecord.Id, 'INVALID FIELD SORT');
        system.assertEquals(True, testObject.hasNext && testObject.hasPrevious, 'Invalid hasNext and has previous after next');
    }

    @isTest
     static void previous_Test() {
        Id recordId ;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap(); 
        testObject.next();
        testObject.next();
        testObject.previous();
        recordId = new list<contact>([SELECT ID FROM Contact  LIMIT 1  OFFSET 5])[0].Id;
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.recordList[0].contactRecord.Id, 'INVALID FIELD SORT');
        system.assertEquals(True, testObject.hasNext && testObject.hasPrevious, 'Invalid hasNext and has previous after next');
    }
    @isTest
     static void first_Test() {
        Id recordId ;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap(); 
        testObject.next();
        testObject.last();
        testObject.first();
        recordId = new list<contact>([SELECT ID FROM Contact  LIMIT 1])[0].Id;
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.recordList[0].contactRecord.Id, 'INVALID FIELD SORT');
        system.assertEquals(True, testObject.hasNext , 'Invalid hasNext');
    }

    @isTest
     static void last_Test() {
        Id recordId ;
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        testObject.addWrapperToMap(); 
        testObject.last();
        recordId = new list<contact>([SELECT ID FROM Contact  LIMIT 1 OFFSET 45 ])[0].Id;
        system.test.stopTest();
        system.assertEquals(2, testObject.mapRecordList.size(),'Record not selected');
        System.assertEquals(recordId, testObject.recordList[0].contactRecord.Id, 'INVALID FIELD SORT');
        system.assertEquals(True, testObject.hasPrevious, 'Invalid has previous');
    }




    @isTest
     static void singleDelete_Test_passed() {
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.selectedContact = testObject.recordList[0].contactRecord.Id;
        testObject.singledelete();
        system.test.stopTest(); 
        system.assertEquals(49, testObject.noOfRecords, 'Invalid value of recordList count');
    }

    @isTest
     static void singleDelete_Test_failed() {
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.selectedContact = testObject.recordList[0].contactRecord.Id;
        case c = new case(Origin = 'Phone',ContactId = testObject.selectedContact);
        insert c;
        testObject.singledelete();
        system.test.stopTest(); 
        system.assertEquals(50, testObject.noOfRecords, 'Invalid value of recordList count');
    }

    @isTest
     static void deleteSelected_Test() {
        system.test.startTest();
        Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
        testObject.recordList[0].isSelected = true;
        testObject.recordList[1].isSelected = true;
        case c = new case(Origin = 'Phone',ContactId = testObject.recordList[0].contactRecord.Id);
        insert c;
        testObject.addWrapperToMap();
        testObject.deleteSelected();
        system.test.stopTest(); 
        system.assertEquals(49, testObject.noOfRecords, 'Invalid value of recordList count');
    }


    @isTest
    static void createCSV_Test() {
       system.test.startTest();
       Standard_Pagination_Controller testObject = new Standard_Pagination_Controller();
       testObject.recordList[0].isSelected = true;
       testObject.addWrapperToMap();
       testObject.createCSV();
       system.test.stopTest(); 
       system.assertEquals(TRUE, testObject.csvFile.contains(''+testObject.recordList[0].contactRecord.LastName) && testObject.csvFile.contains(''+testObject.recordList[0].contactRecord.FirstName), 'Wrong data in csv file  ');
       system.assertEquals(FALSE, testObject.csvFile.contains(''+testObject.recordList[1].contactRecord.LastName) && testObject.csvFile.contains(''+testObject.recordList[1].contactRecord.FirstName), 'Wrong data in csv file  '); 
   }

}