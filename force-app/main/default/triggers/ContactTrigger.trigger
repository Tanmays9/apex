/* ----------------------------------------------------------------------------
Trigger Name     :  ContactTrigger
Purpose        :    Trigger for handeling various DML Operations on contact To specify sequence of 
                    contact for its parent account.
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/


trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    if(Trigger.isBefore && ! contactTriggerHelper.isExecuting){
        if(Trigger.isInsert){
           ContactTriggerHandler.beforeContactInsert(Trigger.new);
           
        }
        if(Trigger.isUpdate){
            if(contactTriggerHelper.isInsertSeq){
                contactTriggerHelper.seqRedundent = new List<Decimal>();
                contactTriggerHelper.contactCollection = new Map<Id,Contact>();
            }
            ContactTriggerHandler.beforeContactUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            ContactTriggerHandler.beforeContactDelete(Trigger.old);
        }
    }
    if(Trigger.isAfter && ! contactTriggerHelper.isExecuting){
        if(Trigger.isInsert){
            List<Contact> contactsCreated = [SELECT ID, Seq__c, AccountId, Lastname FROM Contact WHERE ID IN :Trigger.newMap.keySet() order by id];
            contactTriggerHelper.contactCollection.putAll(contactsCreated);
            contactTriggerHelper.changeSequence();
            contactTriggerHelper.isInsertSeq = true;
        }
        if(Trigger.isUpdate){
            List<Contact> contactsCreated = [SELECT ID, Seq__c, AccountId, LastName FROM Contact WHERE ID IN :Trigger.newMap.keySet() Order by Id];
            contactTriggerHelper.contactCollection.putAll(contactsCreated);
            contactTriggerHelper.changeSequence();
            contactTriggerHelper.isInsertSeq = false;
        }
        if(Trigger.isDelete){
        }
        if(Trigger.isUndelete){
            ContactTriggerHandler.afterContactUndelete(Trigger.newMap);
        }
    }
}