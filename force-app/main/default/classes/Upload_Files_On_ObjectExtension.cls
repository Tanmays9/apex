/* ----------------------------------------------------------------------------
Class Name     :  Upload_Files_On_ObjectExtension
Purpose        :  Extension for Upload_Files_On_Object VF Page to modify standard functionality of the page
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/

global with sharing class Upload_Files_On_ObjectExtension {
    private final Account acct;
    /*
    * Constructor 
    * Description: Passes the value of account from the current page to a member variable.
    * Parameters: stdController (ApexPages.StandardController)
    */ 
    public Upload_Files_On_ObjectExtension(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }

     /*
    * Method Name: upload
    * Description: inserts attachment to the current page account.
    * Parameters: accountId (string), attachmentBody (string), attachmentName (string)
    * Returns:  String
    */ 

    @RemoteAction
    global static String upload(string accountId ,string attachmentBody, String attachmentName){

        Attachment att = new Attachment();
        att.body = EncodingUtil.base64Decode(attachmentBody);
        att.Name = attachmentName;
        att.ParentId = accountId;
        system.debug(att);
        insert att;
        return att.Id;
    
    }

    /*
    * Method Name: pageReload
    * Description: provides page reload functionality.
    * Parameters: --
    * Returns:  Pagereference
    */ 
    

    global Pagereference pageReload(){
        PageReference tempPage = ApexPages.currentPage();            
        tempPage.setRedirect(false);
        return null;
    }


    
}