public with sharing class contactDataFactory {
    
    public static void contactCreate(){
        List<Contact> con = new List<Contact>();
        for(Integer i = 1 ; i <= 5 ; i++){
            con.add(new Contact(lastname = 'contact '+i));
        }
        insert con;
    }

    
    public static void contactCreate(Integer noOfContact) {
        List<Contact> con = new List<Contact>();
        for(Integer i = 1 ; i <= noOfContact ; i++){
            con.add(new Contact(lastname = 'contact '+i));
        }
        insert con;

    }

    public static Set<Id> contactCreate(Integer noOfContact, Boolean returnID) {
        Integer databaseContacts = [SELECT COUNT() FROM contact];
        databaseContacts++;
        List<Contact> con = new List<Contact>();
        for(Integer i = 1 ; i <= noOfContact ; i++){
            con.add(new Contact(lastname = 'contact '+databaseContacts++));
        }
        insert con;
        map<Id, contact> contactId = new Map<Id,Contact>(con);
        if(returnID){
            return contactId.keySet();
        }else{
            return null;
        }

    }
    
    
    public static List<contact> contactCreate( ID idAccount, Integer noOfContact ) {
        List<Contact> con = new List<Contact>();
        for(Integer i = 1 ; i <= noOfContact ; i++){
            con.add(new Contact(lastname = 'contact '+i, AccountId = idAccount));
        }
        return con;
    }

    public static void contactAndAccountCreate( Integer noOfAccount, Integer noOfContact){
        List<Account> insertObjectsAcc = new List<Account>();
        for(Integer i = 1 ; i <= noOfAccount ; i++){
            insertObjectsAcc.add(new Account(Name = 'Account '+i));
        }
        insert insertObjectsAcc;
        List<Contact> insertObjectsCnt = new List<Contact>();
        for(Integer i = 1 ; i <= noOfContact ; i++){
            insertObjectsCnt.add(new Contact(lastname = 'contact '+i, AccountId = insertObjectsAcc[0].Id));
        }
        insert insertObjectsCnt;
    }

    public static List<Contact> ContactsWithSeqNo( Id accountIdInput, Integer seqOfContact) {
        List<Contact> insertObjectsCnt = new List<Contact>();
        for(Integer i = 1 ; i <= seqOfContact ; i++){
                insertObjectsCnt.add(new Contact(lastname = 'Cnt '+i, AccountId = accountIdInput, Seq__c = i));
        }
        return insertObjectsCnt;
    }

    public static List<Contact> ContactsWithSingleSeqNo( Id accountIdInput, Integer seqOfContact, Integer seqNo) {
        List<Contact> insertObjectsCnt = new List<Contact>();
        for(Integer i = 1 ; i <= seqOfContact ; i++){
                insertObjectsCnt.add(new Contact(lastname = 'Cnt '+i, AccountId = accountIdInput, Seq__c = seqNo));
        }
        return insertObjectsCnt;
    }

    public static List<Contact> ContactsWithSeqNo( Id accountIdInput, Integer startSeq, Integer endSeq) {
        List<Contact> insertObjectsCnt = new List<Contact>();
        Integer j=1;
        if(startSeq > endSeq){
            for (Integer i = startSeq ; i >= endSeq ; i--) {
                insertObjectsCnt.add(new Contact(lastname = 'Cnt '+ j++, AccountId = accountIdInput, Seq__c = i));
            }
        }else{
            for (Integer i = startSeq; i <= endSeq; i++) {
                insertObjectsCnt.add(new Contact(lastname = 'Cnt '+ j++ , AccountId = accountIdInput, Seq__c = i));
            }
        }
        return insertObjectsCnt;
    }
    
}