trigger AccountTrigger on Account (before insert, After Update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.beforeAccountInsert(Trigger.new);
            
        }
        
    }
    if(Trigger.isAfter){
        if (Trigger.isUpdate) {
            AccountTriggerHandler.afterAccountUpdate(Trigger.new,Trigger.oldMap);
        }
    }
}