public inherited sharing class client_Side_Pagination_Controller {
    @AuraEnabled
    public static List<Account> retriveAccounts(){
            List<Account> accList = new List<Account>();
            accList = [SELECT id, name, description, phone, AnnualRevenue FROM Account];
            return accList;
    }
}