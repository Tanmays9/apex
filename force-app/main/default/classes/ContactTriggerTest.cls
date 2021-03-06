@isTest
public class ContactTriggerTest {
    
    @TestSetup
    static void makeData(){
        contactDataFactory.contactAndAccountCreate(2, 10);
        //sequenceval([SELECT ID, Lastname,AccountId, Seq__c FROM Contact WHERE AccountId != null]);
    }
    
    public static Id Initialize() {
        List<Contact> contactsfirst = [SELECT ID,AccountId, Account.name  FROM Contact WHERE AccountId != null];
        system.assertEquals(10, contactsfirst.size(), 'Not Matched' + contactsfirst[0].AccountId );  
        return contactsfirst[0].AccountId;
    }


    @isTest
     static void singleContactInsert() {
        Id accountId = Initialize();
        List<Contact> cntList = contactDataFactory.ContactsWithSeqNo(accountId, 3, 3);
        insert cntList;
        sequenceval(cntList);
        List<contact> contacts = [SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId ORDER BY Seq__c];
        sequenceval(contacts);
        System.assertEquals(cntList[0].Seq__c, contacts.get(2).Seq__c, 'Failed single insert with sequence');
    }

    @isTest
     static void singleContactUpdate() {
        Id accountId = Initialize();
        List<Contact> contactsfirst = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ORDER BY Seq__c LIMIT 5];
        sequenceval([SELECT ID, Lastname,AccountId, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId]);
        Contact contactToUpdate = contactsfirst[contactsfirst.size()-1];
        contactToUpdate.Seq__c = 2;
        update contactToUpdate;
        sequenceval([SELECT ID, Lastname,AccountId, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId]);
        Contact contactCheck = [SELECT ID,Seq__c,LastName, Account.name FROM contact WHERE ID = :contactToUpdate.Id];
        System.assertEquals(2, contactCheck.Seq__c, 'Failed Single Update Operation at ' + contactCheck.LastName );
        List<Contact> contactsCheck = [SELECT ID, Seq__c, LastName, Account.name FROM Contact WHERE AccountId = :accountId AND ID IN :contactsfirst ORDER BY Seq__c ];
        for(Integer i = 1 ; i <= contactsCheck.size(); i++){
            System.assertEquals(i, contactsCheck[i-1].Seq__c, 'Failed Single Update Operation at'+ contactsCheck[i-1].LastName);
        }
    }

    @isTest
     static void singleDeleteContactTest() {
        Id accountId = Initialize();
        List<Contact> contactsfirst = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ];
        List<Contact> cont = new List<Contact>();
        cont.add(contactsfirst.get(2));
        delete cont;
        List<Contact> contactslast = [SELECT ID,AccountId, Seq__c, LastName, Account.name  FROM Contact WHERE AccountId = :accountId];
        sequenceval(contactslast);
        for(Integer i = 0 ; i < contactslast.size(); i++){
            system.assertEquals(i+1,contactslast[i].Seq__c , ' Error on contact with name ' + contactslast[i].lastname);
        }
        system.assertEquals(9, contactslast.size() , 'Mismatch account no and contact no');
    }

    @isTest
    public static void singleUndeleteTest() {
        Id accountId = Initialize();
        List<Contact> contactsfirst = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ];
        List<Contact> cont = new List<Contact>();
        cont.add(contactsfirst.get(2));
        delete cont;
        sequenceval([SELECT ID, Lastname,AccountId, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId]);
        undelete cont;
        List<Contact> contactsLast = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ORDER BY Seq__c ];
        sequenceval(contactsLast);
        contact contUndeleted = [SELECT Id, accountId, Seq__c, Lastname, Account.name FROM Contact WHERE AccountId = :accountId AND ID IN :cont ORDER BY Seq__c ];
        system.assertEquals(contactsfirst.size(), contUndeleted.Seq__c, 'Undelete failed');
    }

    @isTest
    static void testInsertNull(){
        Id accountId = Initialize();
        List<Contact> cntList = contactDataFactory.contactCreate(accountId, 10);
        insert cntList;
        sequenceval(cntList);
        List<contact> contacts = [SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId AND ID IN :cntList ORDER BY Seq__c];
        sequenceval(contacts);
        for(Integer i = 1 ; i <= 10 ; i++){
            system.assertEquals(10+i, contacts[i-1].Seq__c, 'Not Matched' + contacts[i-1].LastName );
        }
    }

    @isTest
     static void testUpdateNull() {
        Id accountId = Initialize();
        List<Contact> contactsfirst = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ORDER BY Seq__c];
        List<Contact> contactsRetrive = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ORDER BY Seq__c];
        sequenceval(contactsRetrive);
        for(contact cnt: contactsRetrive){
            cnt.Seq__c = null;
        }
        update contactsRetrive;
        List<Contact> contactsCheck = [SELECT ID, AccountId, Seq__c, LastName, Account.name FROM Contact WHERE AccountId = :accountId AND ID IN :contactsfirst ];
        sequenceval(contactsCheck);
        for(Integer i = 1 ; i <= contactsCheck.size(); i++){
            System.assertEquals(contactsfirst[i-1].Seq__c, contactsCheck[i-1].Seq__c, 'Failed Single Update Operation at'+ contactsCheck[i-1].LastName);
        }
    }

    @isTest
     static void testInsertAscending() {
        Id accountId = Initialize();
        List<Contact> cntList = contactDataFactory.ContactsWithSeqNo(accountId, 10);
        insert cntList;
        sequenceval(cntList);
        List<contact> contacts = [SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId AND ID IN :cntList ORDER BY Seq__c];
        sequenceval(contacts);
        for(Integer i = 1 ; i <= 10 ; i++){
            system.assertEquals(i, contacts[i-1].Seq__c, 'Not Matched' + contacts[i-1].LastName );
        }
    }
    @isTest
     static void testUpdateAscending() {
        Id accountId = Initialize();
        List<Contact> contactsRetrive = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ORDER BY Seq__c LIMIT 5 OFFSET 5];
        sequenceval(contactsRetrive);
        Integer seq = 1;
        for(contact cnt: contactsRetrive){
            cnt.Seq__c = seq++;
        }
        update contactsRetrive;
        List<Contact> contactsCheck = [SELECT ID, Seq__c, LastName, Account.name FROM Contact WHERE AccountId = :accountId AND ID IN :contactsRetrive ];
        sequenceval(contactsCheck);
        for(Integer i = 1 ; i <= contactsCheck.size(); i++){
            System.assertEquals(i, contactsCheck[i-1].Seq__c, 'Failed Single Update Operation at'+ contactsCheck[i-1].LastName);
        }
    }

    @isTest
     static void testInsertDescending() {
        Id accountId = Initialize();
        List<Contact> cntList = contactDataFactory.ContactsWithSeqNo(accountId, 10, 1);
        insert cntList;
        sequenceval(cntList);
        List<contact> contacts = [SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId AND ID IN :cntList ORDER BY Seq__c];
        sequenceval(contacts);
        for(Integer i = 1 ; i <= 10 ; i++){
            system.assertEquals(i, contacts[i-1].Seq__c, 'Not Matched' + contacts[i-1].LastName );
        }
    }

    @isTest
     static void testUpdateDescending() {
        Id accountId = Initialize();
        List<Contact> contactsfirst = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ORDER BY Seq__c LIMIT 5 OFFSET 5];
        List<Contact> contactsRetrive = contactsfirst;
        Integer seq = 5;
        for(contact cnt: contactsRetrive){
            cnt.Seq__c = seq--;
        }
        update contactsRetrive;
        
        List<Contact> contactsCheck = [SELECT ID, Seq__c, LastName, Account.name FROM Contact WHERE AccountId = :accountId AND ID IN :contactsfirst ];
        for(Integer i = 1 ; i <= contactsCheck.size(); i++){
            System.assertEquals(contactsfirst[i-1].Seq__c, contactsCheck[i-1].Seq__c, 'Failed Single Update Operation at'+ contactsCheck[i-1].LastName);
        }
    }

    @isTest
     static void testInsertUnique() {
        Id accountId = Initialize();
        List<Integer> sequenceNos = new List<Integer>{null, 1,5, -10 ,100,200, 0};
        List<Contact> cntList = contactDataFactory.contactCreate(accountId, 7);
        for(Integer i = 1 ; i <= sequenceNos.size() ; i++){
            cntList[i-1].Seq__c = sequenceNos[i-1];
        }
        insert cntList;
        sequenceval(cntList);
        Map<Id,contact> contactsMap = new Map<Id,Contact>([SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId AND ID IN :cntList ORDER BY Seq__c]);
        sequenceval(contactsMap.values());
        system.assertEquals(15, contactsMap.get(cntList[0].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(cntList[0].Id).LastName );
        system.assertEquals(1, contactsMap.get(cntList[1].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(cntList[1].Id).LastName );
        system.assertEquals(5, contactsMap.get(cntList[2].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(cntList[2].Id).LastName );
        system.assertEquals(16, contactsMap.get(cntList[3].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(cntList[3].Id).LastName );
        system.assertEquals(13, contactsMap.get(cntList[4].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(cntList[4].Id).LastName );
        system.assertEquals(14, contactsMap.get(cntList[5].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(cntList[5].Id).LastName );
        system.assertEquals(17, contactsMap.get(cntList[6].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(cntList[6].Id).LastName );
    }
    
    @isTest
     static void testUpdateUnique() {
        Id accountId = Initialize();
        List<Integer> sequenceNos = new List<Integer>{null, 1,5, -10 ,100,200, 0};
        List<Contact> contactsRetrive = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId LIMIT 7];
        for(Integer i = 1 ; i <= sequenceNos.size() ; i++){
            contactsRetrive[i-1].Seq__c = sequenceNos[i-1];
        }
        update contactsRetrive;
        sequenceval(contactsRetrive);
        Map<Id,contact> contactsMap = new Map<Id,Contact>([SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId ORDER BY Seq__c]);
        sequenceval(contactsMap.values());
        system.assertEquals(10, contactsMap.get(contactsRetrive[0].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(contactsRetrive[0].Id).LastName );
        system.assertEquals(1, contactsMap.get(contactsRetrive[1].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(contactsRetrive[1].Id).LastName );
        system.assertEquals(5, contactsMap.get(contactsRetrive[2].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(contactsRetrive[2].Id).LastName );
        system.assertEquals(4, contactsMap.get(contactsRetrive[3].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(contactsRetrive[3].Id).LastName );
        system.assertEquals(8, contactsMap.get(contactsRetrive[4].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(contactsRetrive[4].Id).LastName );
        system.assertEquals(9, contactsMap.get(contactsRetrive[5].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(contactsRetrive[5].Id).LastName );
        system.assertEquals(7, contactsMap.get(contactsRetrive[6].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(contactsRetrive[6].Id).LastName );
    }

    
    @isTest
     static void testInsertSame() {
        Id accountId = Initialize();
        List<Contact> cntList = contactDataFactory.ContactsWithSingleSeqNo(accountId, 10, 5);
        insert cntList;
        sequenceval(cntList);
        Map<Id,contact> contactsMap = new Map<Id,Contact>([SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId AND ID IN :cntList ORDER BY Seq__c]);
        sequenceval(contactsMap.values());
        for(Integer i = 1 ; i <= 9 ; i++){
            system.assertNotEquals(5, contactsMap.get(cntList[i-1].Id).Seq__c, 'Not Matched' + contactsMap.get(cntList[i-1].Id).LastName );
        }
        system.assertEquals(5, contactsMap.get(cntList[cntList.size()-1].Id).Seq__c , 'Wrong seqno for :' + contactsMap.get(cntList[cntList.size()-1].Id).LastName );
    }

    @isTest
     static void testUpdateSame() {
        Id accountId = Initialize();
        List<Contact> contactsRetrive = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId LIMIT 5 OFFSET 5];
        for(Contact cnt : contactsRetrive){
            cnt.Seq__c = 8;
        }
        update contactsRetrive;
        List<Contact> contactsCheck = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId AND ID IN : contactsRetrive];
        system.assertEquals( 6, contactsCheck[0].Seq__C, 'iNVALID SEQUENCE FOR SAME SEQUENCE UPDATE');
        system.assertEquals( 7, contactsCheck[1].Seq__C, 'iNVALID SEQUENCE FOR SAME SEQUENCE UPDATE');
        system.assertEquals( 10, contactsCheck[2].Seq__C, 'iNVALID SEQUENCE FOR SAME SEQUENCE UPDATE');
        system.assertEquals( 9, contactsCheck[3].Seq__C, 'iNVALID SEQUENCE FOR SAME SEQUENCE UPDATE');
        system.assertEquals( 8, contactsCheck[4].Seq__C, 'iNVALID SEQUENCE FOR SAME SEQUENCE UPDATE');

    }

    @isTest
     static void testUpdateParent() {
        Id accountId = Initialize();
        List<Contact> contactsRetrive = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId LIMIT 5 OFFSET 5];
        Account accountSecond = [SELECT ID FROM Account WHERE ID != :accountId];
        for(Contact cnt : contactsRetrive){
            cnt.AccountId = accountSecond.ID;
        }
        update contactsRetrive;
        List<Contact> contactsCheck = [SELECT ID, Seq__c FROM Contact WHERE AccountId = :accountSecond.Id Order by Seq__c];
        system.assertEquals(5, contactsCheck.size(), 'invalid update operation in account change');
        Integer i =1;
        for(contact cnt : contactsCheck){
            system.assertEquals(i++, cnt.Seq__c, 'invalid seq for account change');
        }
    }

    


    @isTest
     static void bulkdeleteContactTest() {
        Id accountId = Initialize();
        List<Contact> contactsfirst = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ];
        List<Integer> delI = new List<Integer>{0,1,2,3,4,7,9};
        List<Contact> cont = new List<Contact>();
        for(Integer i = 0 ; i < contactsfirst.size(); i++){
            if(delI.contains(i)){
                cont.add(contactsfirst.get(i));
            }
        }
        delete cont;
        List<Contact> contactslast = [SELECT ID,AccountId, Seq__c, LastName, Account.name  FROM Contact WHERE AccountId != null];
        sequenceval(contactslast);
        for(Integer i = 0 ; i < contactslast.size(); i++){
            system.assertEquals(i+1,contactslast[i].Seq__c , ' Error on contact with name ' + contactslast[i].lastname);
        }
        system.assertEquals(3, contactslast.size() , 'Mismatch account no and contact no');
    }

    

    @isTest
    public static void bulkUndeleteTest() {
        Id accountId = Initialize();
        List<Contact> contactsfirst = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ];
        List<Integer> delI = new List<Integer>{0,1,2,3,4,7,9};
        List<Contact> cont = new List<Contact>();
        for(Integer i = 0 ; i < contactsfirst.size(); i++){
            if(delI.contains(i)){
                cont.add(contactsfirst.get(i));
            }
        }
        delete cont;
        sequenceval([SELECT ID, Lastname,AccountId, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId]);
        undelete cont;
        List<Contact> contactsLast = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId ORDER BY Seq__c ];
        sequenceval(contactsLast);  
        List<Contact> contUndeleted = [SELECT Id, accountId, Seq__c, Lastname, Account.name FROM Contact WHERE AccountId = :accountId AND ID IN :cont ORDER BY Seq__c ];
        Integer j = 0;
        sequenceval(contUndeleted);
        for(Integer i = contactsfirst.size() - cont.size() +1  ; i < contactsfirst.size(); i++ ){
            system.assertEquals(i, contUndeleted[j++].Seq__c, 'Undelete failed');
        }
             
    }
    

    public Static void sequenceval(list<contact> contacts){
        Integer i = 1;
        System.debug('Print : '+ contacts.size() );
        for(contact c: contacts){
            system.debug('Index :'+ i++ +' Lastname : '+ c.LastName + ' Sequenceno : '+ c.Seq__c + ' Account :' + c.Account.Name);
        }
    }

    @isTest
     static void testMassInsert() {
        Id accountId = Initialize();
        List<Contact> cntList = contactDataFactory.ContactsWithSeqNo(accountId, 400, 1);
        insert cntList;
        sequenceval(cntList);
        Map<Id,contact> contacts = new Map<Id,Contact>( [SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId AND ID IN :cntList ORDER BY Seq__c]);
        sequenceval(contacts.values());
        for(Integer i = 1 ; i <= 400 ; i++){
            system.assertEquals(cntList[i-1].Seq__c, contacts.get(cntList[i-1].Id).Seq__c, 'invalid sequence for'+ contacts.get(cntList[i-1].Id).Lastname);
        }
        List<contact> contactsLeft = [SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId AND ID NOT IN :cntList ORDER BY Seq__c];
        Integer seq = 401;
        for(Integer i = 1 ; i <= contactsLeft.size() ; i++){
            system.assertEquals(seq++, contactsLeft[i-1].Seq__c, 'Not Matched' + contactsLeft[i-1].LastName );
            system.debug(contactsLeft[i-1].LastName + ' : ' + contactsLeft[i-1].Seq__c);
        }
    }
    @isTest
     static void testMassUpdate() {
        Id accountId = Initialize();
        List<Contact> cntList = contactDataFactory.contactCreate(accountId, 400);
        insert cntList;
        List<Contact> contactsfirst = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId AND ID IN :cntList ORDER BY Seq__c ];
        List<Contact> contactsRetrive = [SELECT ID,AccountId, LastName, Seq__c, Account.name FROM Contact WHERE AccountId = :accountId And ID IN :cntList ORDER BY Seq__c ];
        Integer seq = 400;
        for(contact cnt: contactsRetrive){
            cnt.Seq__c = seq--;
        }
        update contactsRetrive;
        Map<Id,contact> contactsCheck = new Map<Id,Contact>( [SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId AND ID IN :cntList ORDER BY Seq__c]);
        sequenceval(contactsCheck.values());
        for(Integer i = 1 ; i <= 400; i++){
            System.assertEquals(contactsRetrive[i-1].Seq__c, contactsCheck.get(contactsRetrive[i-1].Id).Seq__c, 'Failed Single Update Operation at'+ contactsCheck.get(contactsRetrive[i-1].Id).LastName);
        }
        List<contact> contactsLeft = [SELECT ID, Lastname,AccountId, Seq__c, Account.name  FROM Contact WHERE AccountId = :accountId AND ID NOT IN :cntList ORDER BY Seq__c];
        sequenceval(contactsLeft);
        Integer sequence = 401;
        for(Integer i = 1 ; i <= contactsLeft.size() ; i++){
            system.assertEquals(sequence++, contactsLeft[i-1].Seq__c, 'Not Matched' + contactsLeft[i-1].LastName );
            system.debug(contactsLeft[i-1].LastName + ' : ' + contactsLeft[i-1].Seq__c);
        }
    }

}