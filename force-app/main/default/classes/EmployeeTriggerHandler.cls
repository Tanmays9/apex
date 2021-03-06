public class EmployeeTriggerHandler {
    
    public static void beforeEmployeeInsert(List<Employee__c> newList){
       // List<Employee__c> empl = new List<Employee__c>();
        for( Employee__c emp : newList){
            emp.Status__c = 'Joined';
            emp.Joining_Date__c = System.today();
           // empl.add(emp);
        }
      // Employee__c emp = new Employee__c(name ='Clone ' + newList[0].name);
        //empl.add(emp);
        //Database.insert(emp,false); error
        
        
    }
    
    public static void beforeEmployeeUpdate(List<Employee__c> newList, Map<ID,Employee__c> oldMap){
        
        for( Employee__c emp: newList){
            if(oldMap.get(emp.Id).Status__c != 'Resigned' && emp.Status__c == 'Resigned'){
                emp.Status__c = 'Resigned';
                emp.Resign_Date__c =  System.today();
            }
        }
        Employee__c emp = new Employee__c(name ='Clone ' + newList[0].name);
        insert emp;	
        
    }


}