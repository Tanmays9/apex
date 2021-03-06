trigger CaseTrigger on Case (before insert, after insert) {

    if(Trigger.isBefore){
        // if(Trigger.isInsert){
        //     for(case c : trigger.new){
        //         if(c.Origin == 'email'){
        //         }
        //     }
        // }
    }else if(Trigger.isAfter){
        if(Trigger.isInsert){
            List<ID> emailCases = new List<ID>();
            for(case c: trigger.new){
                if(c.Origin == 'Email'){
                    emailCases.add(c.Id);
                }
            }
            caseDelete.deleteEmailCase(emailCases);
        }
    }
    
   
}