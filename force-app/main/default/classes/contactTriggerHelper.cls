/* ----------------------------------------------------------------------------
Class Name     :  contactTriggerHelper
Purpose        :  Helper class for contact trigger to handle execution 
                  In the form of chunks of 200 and maintain state of previously 
                  processed contacts in an transection.
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/
public with sharing class contactTriggerHelper {
   public static Boolean isExecuting = false;
   public static Boolean isInsertSeq = false;
   public static Map<Id,Contact> contactCollection = new Map<Id,Contact>();
   public static List<Decimal> seqRedundent = new List<Decimal> ();

   /*
    * Method Name: changeSequence
    * Description: Resets the sequence of contacts to the previous state 
                     and use them in further processing of chunks.
    * Parameters: --
    * Returns:  void
    */ 

   public static void changeSequence(){
      system.debug(seqRedundent.size());
      system.debug(contactCollection.size());
      integer index = 0;
      for(contact cnt : contactCollection.values()){
         cnt.Seq__c = seqRedundent.get(index++);
         system.debug(cnt.LastName + ' :: '+ cnt.Seq__c);
      }
      system.debug(seqRedundent);
   }
}