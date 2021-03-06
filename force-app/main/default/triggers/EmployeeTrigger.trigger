trigger EmployeeTrigger on Employee__c (before insert, before update) {
    
    if(Trigger.isBefore){
        
        if(Trigger.isInsert){
            EmployeeTriggerHandler.beforeEmployeeInsert(Trigger.new);
        }
        
        if(Trigger.isUpdate){
            EmployeeTriggerHandler.beforeEmployeeUpdate(Trigger.new, Trigger.oldMap);
        }
        
    }

}