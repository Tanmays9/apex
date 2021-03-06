@isTest
public inherited sharing class client_side_paginationLC_test {
    @TestSetup
    static void makeData(){
        contactDataFactory.contactAndAccountCreate(10, 0);
    }


    @isTest
     static void queryRecords() {
        List<Account> accList = new List<Account>();
        accList = client_Side_Pagination_Controller.retriveAccounts();
        system.assertEquals(10, accList.size(), 'Data Retrive Failed');
        
    }
}