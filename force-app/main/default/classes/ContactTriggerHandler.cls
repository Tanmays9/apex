/* ----------------------------------------------------------------------------
Class Name     :  ContactTriggerHandler
Purpose        :  Manipulate Data Of Modified Contacts And Contacts In Database.
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/

public class ContactTriggerHandler {
    /*
    * Method Name: beforeContactDelete
    * Description: Assigns sequence to the remaining contacts in database 
                    before delete operation is commited.
    * Parameters: newList (List<Contact>)
    * Returns: void  
    */ 

    public static void beforeContactDelete(List<Contact> newList) {
        contactTriggerHelper.isExecuting = true;
        list<ID> listAccountId = new List<Id>();
        for(Contact c: newList){
            if( !listAccountId.contains(c.AccountId)){ 
                listAccountId.add(c.AccountId);
            }
        }
        Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT ID, (SELECT Id, LastName, Seq__c, AccountId FROM Contacts WHERE Id NOT IN :newList ORDER BY Seq__c ) FROM Account WHERE Id IN :listAccountId]);
        List<contact> listContact = new List<Contact>(); 
        for(Account a: mapAccount.values()){
            Integer index = 1;
            for(Contact c: mapAccount.get(a.Id).Contacts){
                if(c.Seq__c != index){
                    c.Seq__c = index;
                    listContact.add(c);
                }
                index++;
            }
        }
        if(listContact.size() > 0 ){
            update listContact;
        }
        contactTriggerHelper.isExecuting = false;
    }

    /*
    * Method Name: afterContactUndelete
    * Description: Assigns sequence to the contacts which are undeleted from recyclebin.
    * Parameters: newMap (Map<Id, Contact>)
    * Returns: void  
    */ 


    public static void afterContactUndelete(Map<Id, Contact> newMap) {
        contactTriggerHelper.isExecuting = true;
        list<ID> listAccountId = new List<Id>();
        for(Contact c: newMap.values()){
            if(c.AccountId == null){
                continue;
            }
            if( !listAccountId.contains(c.AccountId)){ 
                listAccountId.add(c.AccountId);
            }
        }
        Map<Id,Account> accountMap = new map<Id,Account>([SELECT Id,(SELECT ID,SEQ__C FROM contacts WHERE ID NOT IN :newMap.keySet() ORDER BY SEQ__C DESC LIMIT 1) FROM Account WHERE ID IN :listAccountId]);
        List<Contact> contactsList = [SELECT ID, AccountId, Seq__c FROM Contact WHERE AccountID IN :listAccountId AND ID IN :newMap.keySet() ];
        
        for(Contact c: contactsList){
            Decimal val = accountMap.get(c.AccountId).Contacts[0].Seq__c + 1;
            c.Seq__c = val;
            accountMap.get(c.AccountId).Contacts[0].Seq__c = val;
        }
        if(contactsList.size() > 0){
            update contactsList;
        }
        contactTriggerHelper.isExecuting = false;
    }

    /*
    * Method Name: beforeContactInsert
    * Description: Assigns sequence to the contacts which are inserted in Database according to their sequence nos.
                    Also assign sequence to database contacts based on their old sequence no.
    * Parameters: newList (List<Contact>)
    * Returns: void  
    */ 

    public static void beforeContactInsert(List<Contact> newList){
        contactTriggerHelper.isExecuting = true;
        List<Id> accountID = new List<Id>();
        List<Decimal> seqList = new List<Decimal>();
        Map<Decimal, List<Contact>> mapbySequence = new Map<Decimal, List<Contact>>();// sorting by SEQ
        for(contact cnt : contactTriggerHelper.contactCollection.values()){
            if(mapbySequence.containsKey(cnt.Seq__c)){
                mapbySequence.get(cnt.Seq__c).add(cnt);
            }else{
                mapbySequence.put(cnt.Seq__c, new List<Contact> {cnt});
                seqList.add(cnt.Seq__c);
            }
        }
        for(Contact c: newList){
            contactTriggerHelper.seqRedundent.add(c.Seq__c);
            if(c.AccountId == null){
                continue;
            }else if(!accountID.contains(c.AccountId)){
                accountID.add(c.AccountId);
            }
            if(c.Seq__c < 1){
                c.Seq__c = null;
            }
            if(mapbySequence.containsKey(c.Seq__c)){
                mapbySequence.get(c.Seq__c).add(c);
            }else{
                mapbySequence.put(c.Seq__c, new List<Contact> {c});
                seqList.add(c.Seq__c);
            }
        }
        seqList.sort();
        if(seqList.contains(null)){
            seqList.remove(0);
            seqList.add(null);
        }
        Map<Id, List<Contact>> contactByAccount = new Map<Id,List<Contact>>(); // 
        List<Contact> listOfContacts = new List<Contact>();
        Map<Id,Contact> mapDbContact = new Map<Id,Contact>();
       
        mapDbContact = new Map<Id,Contact>([SELECT Id, AccountId, Seq__c FROM Contact WHERE AccountId IN :accountID AND ID NOT IN :contactTriggerHelper.contactCollection.keySet()  ORDER BY Seq__c]);
        for (Contact c : mapDbContact.values()) {
            if(contactByAccount.containsKey(c.AccountId)){
                contactByAccount.get(c.AccountId).add(c);
            }else{
                contactByAccount.put(c.AccountId, new List<Contact>{c}); 
            }
        }
        for (Decimal D : seqList) {
            system.debug(D + ' : '+mapbySequence.get(D).size());
            for (contact c : mapbySequence.get(D)) {
                if(!contactByAccount.containsKey(c.AccountId)){
                    contactByAccount.put(c.AccountId, new List<Contact>()); 
                }
                if(d != null && d <= contactByAccount.get(c.AccountId).size() && d > 0 ){
                    contactByAccount.get(c.AccountId).add((Integer)c.Seq__c - 1, c );
                }else {
                    contactByAccount.get(c.AccountId).add(c);
                }
            }
        }
        List<Contact> updateContact = new List<Contact>();
        for(ID AccId : contactByAccount.keySet()){
            Integer index = 1; 
            for(contact cnt : contactByAccount.get(AccId)){
                cnt.Seq__c = index++;
                if(mapDbContact.containsKey(cnt.Id) && mapDbContact.get(cnt.Id).Seq__c != index){
                    updateContact.add(cnt);
                    system.debug(cnt.Id);
                }else if(contactTriggerHelper.contactCollection.containsKey(cnt.Id) && contactTriggerHelper.contactCollection.get(cnt.Id).Seq__c != index){
                    updateContact.add(cnt);
                }
            }
        }
        if(updateContact != null && updateContact.size() > 0 ){
            update updateContact;
        }
        contactTriggerHelper.isExecuting = false;
    }  
    /*
    * Method Name: beforeContactUpdate
    * Description: Assigns sequence to the contacts which are Updated in Database according to their sequence nos.
                    Also assign sequence to database contacts based on their old sequence no.
    * Parameters: newMap (Map<Id,Contact>), oldMap (Map<Id,Contact>)
    * Returns: void  
    */  

    public static void beforeContactUpdate(Map<Id,Contact> newMap, Map<Id,Contact> oldMap ) {
        contactTriggerHelper.isExecuting = true; 
        system.debug('update start');
        List<Id> accountId = new List<Id>();
        Map<Decimal, List<Contact>> mapbySequence = new Map<Decimal, List<Contact>>();// sorting by SEQ
        Map<Id, List<Contact>> contactByAccountDb = new map<ID,List<Contact>>();
        List<Decimal> seqList = new List<Decimal>();
        for(contact cnt : contactTriggerHelper.contactCollection.values()){
            if(mapbySequence.containsKey(cnt.Seq__c)){
                mapbySequence.get(cnt.Seq__c).add(cnt);
            }else{
                mapbySequence.put(cnt.Seq__c, new List<Contact> {cnt});
                seqList.add(cnt.Seq__c);
            }
        }
        for(contact cnt : oldMap.values()){
            if(!accountId.contains(cnt.AccountId)){
                accountId.add(cnt.AccountId);
            }
        }
        
        for(contact cnt :newMap.values()){
            system.debug(contactTriggerHelper.seqRedundent.size());
            system.debug(contactTriggerHelper.seqRedundent);
            contactTriggerHelper.seqRedundent.add(cnt.Seq__c);
            if(!accountId.contains(cnt.AccountId)){
                accountId.add(cnt.AccountId);
            }
            if(cnt.AccountId == null ){
                cnt.Seq__c = null;
                continue;
            }else if(cnt.Seq__c < 1){
                cnt.Seq__c = oldMap.get(cnt.Id).Seq__c;
            }
            if(cnt.AccountId != oldMap.get(cnt.Id).AccountId){
                cnt.Seq__c = null;
            }
            if(mapbySequence.containsKey(cnt.Seq__c)){
                mapbySequence.get(cnt.Seq__c).add(cnt);
            }else{
                mapbySequence.put(cnt.Seq__c, new List<Contact> {cnt});
                seqList.add(cnt.Seq__c);
            }
        }
        seqList.sort();
        if(seqList.contains(null)){
            seqList.remove(0);
            seqList.add(null);
        }
        Map<Id,Contact> mapDbContact =new Map<Id,Contact>();
       
        mapDbContact = new Map<Id,Contact>([SELECT Id, AccountId, Seq__c FROM Contact WHERE AccountId IN :accountID AND ID NOT IN :newMap.keySet() AND ID NOT IN :contactTriggerHelper.contactCollection.keySet()  ORDER BY Seq__c]);

        for (contact cnt : mapDbContact.values()) {
            if(contactByAccountDb.containsKey(cnt.AccountId)){
                contactByAccountDb.get(cnt.AccountId).add(cnt);
            }else {
                contactByAccountDb.put(cnt.AccountId, new List<Contact>{cnt});
            }
        }
        for(Decimal dec: seqList){
            for(Contact cnt : mapbySequence.get(dec)){
                if(!contactByAccountDb.containsKey(cnt.AccountId)){
                    contactByAccountDb.put(cnt.AccountId, new List<Contact>()); 
                }
                if(dec != null && dec <= contactByAccountDb.get(cnt.AccountId).size() && dec > 0 ){
                    contactByAccountDb.get(cnt.AccountId).add((Integer)cnt.Seq__c - 1, cnt );
                }else {
                    contactByAccountDb.get(cnt.AccountId).add(cnt);
                }
            }
        }
        List<Contact> updateContact = new List<Contact>();
        for(ID AccId : contactByAccountDb.keySet()){
            Integer index = 1; 
            for(contact cnt : contactByAccountDb.get(AccId)){
                cnt.Seq__c = index++;
                if(mapDbContact.containsKey(cnt.Id) && mapDbContact.get(cnt.Id).Seq__c != index){
                    updateContact.add(cnt);
                }else if(contactTriggerHelper.contactCollection.containsKey(cnt.Id) && contactTriggerHelper.contactCollection.get(cnt.Id).Seq__c != index && !newMap.containsKey(cnt.Id)){
                    updateContact.add(cnt); 
                    system.debug(cnt.LastName+ ' updating to '+ cnt.Seq__c);
                }
            }
        }
        system.debug('update size'+updateContact.size());
        if(updateContact != null && updateContact.size() > 0 ){
            update updateContact;
        }
        system.debug('update end');
        contactTriggerHelper.isExecuting = false;
    }
}