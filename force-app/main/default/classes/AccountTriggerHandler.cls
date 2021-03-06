public class AccountTriggerHandler {

    public static void beforeAccountInsert(List<Account> newList){
        List<String> names = new List<String>();
        
        for(Account Accer: newList){
            names.add(Accer.Name);
        }
        
       	for(Account Acc : ([SELECT Name FROM Account WHERE Name IN :names])){ //Retiriving recorrds with similar names
            for(Account AccTr : newList){
                if(Acc.name == AccTr.name){
                    AccTr.addError('Duplicate Account Record All Ready Exists In Database With Name : ' + Acc.Name);
                }
            }
            
            
        }

    }

    public static void afterAccountUpdate(List<Account> newList, Map<ID,Account> oldMap){
        List<Case> caseUpdate = new List<Case>();

        for(Case caseRecord : ([SELECT ID,Status,AccountID,Account.Case_Status__c FROM Case WHERE AccountID IN :newList])){

            if(caseRecord.Account.Case_Status__c != null && oldMap.get(caseRecord.AccountID).Case_Status__c != caseRecord.Account.Case_Status__c ){ // Comparing old account status to new Account status
                if(caseRecord.Status != caseRecord.Account.Case_Status__c ){
                    caseRecord.Status = caseRecord.Account.Case_Status__c;
                	caseUpdate.add(caseRecord);
                }
            }
        }

        if(caseUpdate.size() >0){
            Database.update(caseUpdate,false);
        }

    }



}