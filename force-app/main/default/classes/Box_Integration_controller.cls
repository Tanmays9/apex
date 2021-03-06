/* ----------------------------------------------------------------------------
Class Name     :  Box_Integration_controller
Purpose        :  Perform various callouts from service class and processing of data from response
                    To be displayed on view.
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/

public with sharing class Box_Integration_controller {
    public string link = 'response_type=code&client_id=&redirect_uri=';
    public String redirectUrl;
    // public FoldersInfo folderDetails;
    public List<String> items{get;set;}
    public string folderName{get;set;}
    public map<string,string> navigationItems{get;set;}
    public Map<String,String> folderIdToNameMap{get;set;}
    public integer foldersCount{get;set;}
    public String selectedFolder{get;set;}
    public String selectedFile{get;set;}  
    public List<Box_Response_Wrapper.entry> fileList{get;set;}
    public string userMail;
    public Box_Auth__c user{get;set;}
    public string code;
    public Service_Box_Api service;
    public Box_Integration_Keys__mdt oautdata;
    //variables for file upload
    public blob uploadContent{get;set;}
    public string uploadFileName{get;set;}
    public String client_Id;
    public string client_secret;

    /*
    * Constructor 
    * Description: initializes values and set the root folder value as selected folder.
                    And to retrive the custom metadata object.
    * Parameters: --
    */ 

    public Box_Integration_controller() {
        code = ApexPages.currentPage().getParameters().get('code') ;
        navigationItems = new Map<string,string>();
        navigationItems.put('0', 'All Files');
        selectedFolder = '0';
        items = new List<String>();
        items.add('0');
        oautdata = [SELECT id, client_id__c, client_secret__c, redirect_uri__c FROM Box_Integration_Keys__mdt where MasterLabel = 'Box App keys'];
        service = new Service_Box_Api();
    }

    /*
    * Method Name: createFolder
    * Description: Call to service class mthod with folder name and parent folder,
                    next making callout to parent folder to get the newly created folder.
    * Parameters: --
    * Returns:  void
    */ 

    public void createFolder(){
        system.debug(folderName);
        
        Box_Response_Wrapper response = service.postNewFolder(user.access_token__c, folderName, selectedFolder);
        system.debug(response);
        if(response.status_Code == 201){
            system.debug(response.body);
            // Box_Response_Wrapper.entry newFolderentry = response.folderDetails.item_collection.entries.get(0);
            // navigationItems.put(newFolderentry.id, newFolderentry.name);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Folder Created successfully'));

            openFolder();
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Folder creation failed due to duplicate name'));

        }
    }

     /*
    * Method Name: checkExistingUsers
    * Description: Initial processig to find if any user exists in database with the current user mail,
                    Analyzing if Authcode is present in the url, Redirecting for excess permission grant.
    * Parameters: --
    * Returns:  Pagereference
    */ 

    public Pagereference checkExistingUsers(){
        userMail = UserInfo.getUserEmail();
        system.debug(userMail);
        List<Box_Auth__c> Users = [SELECT ID,refresh_token__c, access_token__c, expires_in__c FROM Box_Auth__c where User_Email__c = :userMail];
        system.debug(':'+ code+':');
        if(Users.size() < 1 ){
            if(code== '' || code == null){
                Pagereference pg = new Pagereference(service.requestAuthCode(oautdata.client_id__c, oautdata.redirect_uri__c));
                return pg;
            }else{
                Box_Response_Wrapper response = service.requestAccessToken(code, oautdata.client_id__c, oautdata.client_secret__c, oautdata.redirect_uri__c);
                manageUser(response.body);
                retriveData('0');
                insert user;
            }
        }else if(Users.size() == 1){
            user = Users[0];
            retriveData(selectedFolder);
            // Datetime expiring = user.expires_in__c;
            // Long remaining = expiring.getTime() - Datetime.now().getTime();
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Access Token '+ user.access_token__c + ' Expiring In '+(remaining/1000)/60 + ' Minutes'));
        }

        return null;
    }

     /*
    * Method Name: manageUser
    * Description: Assign values to object based on response from access token callout.
    * Parameters: response (string)
    * Returns:  void
    */ 

    public void manageUser(string response){
        Map<String, Object> parsedRes = (Map<String, Object>) JSON.deserializeUntyped(response);
        Box_Auth__c newUser = new Box_Auth__c();
        newUser.User_Email__c = userMail;
        newUser.access_token__c = string.valueOf(parsedRes.get('access_token'));
        newUser.refresh_token__c = string.valueOf(parsedRes.get('refresh_token'));
        newUser.expires_in__c = Datetime.now().addSeconds((integer)parsedRes.get('expires_in') );
        system.debug(newUser);
        user = newUser;
    }

     /*
    * Method Name: openFolder
    * Description: Get the content of the selected folder containg file names and ID's.
    * Parameters: --
    * Returns:  void
    */ 

    public void openFolder(){

        system.debug(selectedFolder + 'hre is data');
        if(!navigationItems.containsKey(selectedFolder)){
            navigationItems.put(selectedFolder, folderIdToNameMap.get(selectedFolder));
            items.add(selectedFolder);
            system.debug('Add : '+folderIdToNameMap.get(selectedFolder));
        }else{
            // system.debug('Exists : '+folderIdToNameMap.get(selectedFolder));            
            integer i = items.indexOf(selectedFolder) +1;
            while (i < items.size()) {
                navigationItems.remove(items.get(i));
                items.remove(i);
            }
        }
        system.debug(navigationItems);
        retriveData(selectedFolder);
        
    }

     /*
    * Method Name: downloadFile
    * Description: Get the download url from the server by callout.
    * Parameters: --
    * Returns:  Pagereference
    */ 

    public Pagereference downloadFile(){
        string downloadURL = service.downloadFileService(User.access_token__c, selectedFile);
        Pagereference pr = new Pagereference(downloadURL);
        system.debug('response complete');
        pr.setRedirect(true);
        return pr;

    }
   
     /*
    * Method Name: retriveData
    * Description: Get the response from server callout and passing its values to member variables to disply on view.
    * Parameters: folderID (string)
    * Returns:  Pagereference
    */ 

    public Pagereference retriveData(string folderID){
        Box_Response_Wrapper response = service.fetchFolderInformation(folderID, User.access_token__c);
        if(response.status_Code == 200){
            system.debug(response);
            system.debug(response.folderDetails);
            folderIdToNameMap = new Map<string,String>();
            fileList = new List<Box_Response_Wrapper.entry>();
            if(response.folderDetails.item_collection.entries.size()>0){
                for(Box_Response_Wrapper.entry en : response.folderDetails.item_collection.entries){
                    if(en.type.equalsignorecase('folder') ){
                        folderIdToNameMap.put(en.id, en.name);
                    }
                }
                system.debug('******folderIdToNameMap:'+folderIdToNameMap);
                fileListData(response.folderDetails);
            }
            foldersCount = folderIdToNameMap.size();
        }else if(response.status_Code == 401){
            refreshToken();
            retriveData(selectedFolder);
            if(!system.Test.isRunningTest()){
                update User;
            }

        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,string.valueOf(response.status_Code)));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,string.valueOf(response.body)));
            system.debug(response);
        }
        return null;
    }

     /*
    * Method Name: refreshToken
    * Description: Call to webserver for grant of new access token on expiration of previous token.
    * Parameters: --
    * Returns:  void
    */ 

    public void refreshToken(){
        Box_Response_Wrapper response = service.refreshAccessToken(oautdata.client_id__c, oautdata.client_secret__c, oautdata.redirect_uri__c, user.refresh_token__c);
        system.debug('complete' + response);
        if(response.status_Code == 200){
            Map<String, Object> parsedRes = (Map<String, Object>) JSON.deserializeUntyped(response.body);
            User.access_token__c = string.valueOf(parsedRes.get('access_token'));
            User.refresh_token__c = string.valueOf(parsedRes.get('refresh_token'));
            User.expires_in__c = Datetime.now().addSeconds((integer)parsedRes.get('expires_in') );
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Access Tocken Changed to '+ user.access_token__c));   
        }else{
            // delete [SELECT ID ]
        }
    }

     /*
    * Method Name: fileListData
    * Description: Parse all files with their names and ids from response object.
    * Parameters: folderDetails (Box_Response_Wrapper.FoldersInfo)
    * Returns:  void
    */ 

    public void fileListData(Box_Response_Wrapper.FoldersInfo folderDetails){
        if(folderDetails.item_collection.entries.size() > 0){
            for(Box_Response_Wrapper.entry er : folderDetails.item_collection.entries){
                if(er.type.equalsIgnoreCase('file')){
                    fileList.add(er);
                }
            }
        } 
    }

     /*
    * Method Name: deleteFile
    * Description: Callout to delete selected fle from box.com.
    * Parameters: --
    * Returns:  void
    */ 

    public void deleteFile(){
        Box_Response_Wrapper response = service.deleteFileService(user.access_token__c, selectedFile);
        if(response.status_Code == 204){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'File Successfully Deleted'));
            openFolder();
        }else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'File Delete Failed'));

        }
    }

     /*
    * Method Name: deleteFolder
    * Description: Callout to delete selected folder from box.com
    * Parameters: --
    * Returns:  void
    */ 

    public void deleteFolder(){
        Box_Response_Wrapper response = service.deleteFolderService(user.access_token__c, selectedFolder);
        if(response.status_Code == 204){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Folder Successfully Deleted'));
            if(navigationItems.containsKey(selectedFolder)){
                navigationItems.remove(selectedFolder);
            }
            selectedFolder = items.get(items.size()-1);
            openFolder();
        }else {
            system.debug(response.status_Code);
            System.debug(response.body);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,response.status_Code+': Folder Delete Failed As Folder Not Empty'));
        }
    }

     /*
    * Method Name: uploadFileToBox
    * Description: Callout to box.com with blob data and file name.
    * Parameters: f--
    * Returns:  void
    */ 

    public void uploadFileToBox(){
        system.debug('here'+ uploadFilename +'\n : \n'+ uploadContent);
        if(uploadContent!=null){
            Box_Response_Wrapper response = service.uploadFileService(user.access_token__c, uploadContent, uploadFilename, selectedFolder);
            if(response.status_Code==201){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'File Successfully Uploaded'));
                openFolder();
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' File Upload Error encountered File Name all ready exists. Status Code'+response.status_Code));

            }
        }
    }
}