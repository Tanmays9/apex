@isTest
public class Box_Integration_controller_test {
    
    @TestSetup
    static void makeData(){
        // Box_Auth__c user = new Box_Auth__c();
        // user.refresh_token__c = 'refreshTokenCode';
        // user.access_token__c = 'accessTokenCode';
        // user.expires_in__c = Datetime.now().addHours(1);
        // user.User_Email__c = 'email@test.com';
        // insert user;

        
    }
    public static Box_Integration_controller  init(){
        Box_Integration_controller testObj = new Box_Integration_controller();
        Box_Auth__c user = new Box_Auth__c();
        user.access_token__c = 'access_token_value';
        user.refresh_token__c = 'refresh_token_value';
        testObj.user = user;
        return testObj;
    }

    public static Box_Integration_Keys__mdt createCustomMetadata(){
        Box_Integration_Keys__mdt dataKeys = new Box_Integration_Keys__mdt();
        dataKeys.client_id__c = 'clientidstring';
        dataKeys.client_secret__c = 'clientsecretstring';
        dataKeys.redirect_uri__c = 'https://briskminds9-dev-ed--c.visualforce.com/apex/Box_Integration';
        return dataKeys;
    }

    @isTest
    public static void authCodeRequest(){
        Box_Integration_controller testObj = new Box_Integration_controller();
        Box_Integration_Keys__mdt dataKeys = [SELECT id, client_id__c, client_secret__c, redirect_uri__c FROM Box_Integration_Keys__mdt where MasterLabel = 'Box App keys'];
        Pagereference pr = testObj.checkExistingUsers();
        Map<String,String> urlParse = pr.getParameters();

        system.assertEquals(urlParse.get('client_id'), dataKeys.client_id__c, 'invalid client ID');
        system.assertEquals(urlParse.get('redirect_uri'), dataKeys.redirect_uri__c, 'invalid redirect uri');   
    }

     static String jsonGenerateAccessToken() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('access_token', 'access_token_value');
        gen.writeNumberField('expires_in', 3600);
        gen.writeStringField('refresh_token', 'refresh_token_value');
        gen.writeEndObject();
        return gen.getAsString();
    }

     static String jsonGenerateFolderData() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('item_collection');
        List<Box_Response_Wrapper.entry> entrys = new list<Box_Response_Wrapper.entry>();
        entrys.add(new Box_Response_Wrapper.entry('file', 'entry Id 1','entry 1'));
        entrys.add(new Box_Response_Wrapper.entry('folder','entry Id 2','entry 2'));
        Box_Response_Wrapper.ItemCollections itemCollectionObj= new Box_Response_Wrapper.ItemCollections('2');
        itemCollectionObj.entries = entrys;
        gen.writeObject(itemCollectionObj);
        gen.writeEndObject();
        return gen.getAsString();
    }

    @isTest
     static void accessTokenRequest() {
         string responseBody = jsonGenerateAccessToken();
        SingleRequestMock fakeResponseAccessToken = new SingleRequestMock(200, 'complete', responseBody, null );
        responseBody = jsonGenerateFolderData();
        SingleRequestMock fakeResponseRootFolder = new SingleRequestMock(200, 'complete', responseBody, null );
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://api.box.com/oauth2/token/', fakeResponseAccessToken);
        endpoint2TestResp.put('https://api.box.com/2.0/folders/0', fakeResponseRootFolder);
        HttpMock multiCalloutMock = new HttpMock(endpoint2TestResp);        
        system.test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Pagereference pr = new Pagereference('https://testurl?code=authcode');
        system.test.setCurrentPage(pr);
        Box_Integration_controller testObj =  init();
        testObj.checkExistingUsers();
        system.assertEquals(1, testObj.fileList.size(), 'incorrect file data parse');
        system.assertEquals('entry 1', testObj.fileList[0].name, 'Incorrect name identified');
        system.assertEquals(1, testObj.folderIdToNameMap.size(), 'incorrect folder data parse');
        system.assertEquals('entry 2', testObj.folderIdToNameMap.get('entry Id 2'), 'invlid folder details');
    }

    @isTest
     static void refreshTokenRequest() {
        SingleRequestMock fakeResponseAccessToken = new SingleRequestMock(401, 'complete', 'refresh token expired', null );
        string responseBody = jsonGenerateAccessToken();
        SingleRequestMock fakeResponseRefreshToken = new SingleRequestMock(200, 'complete', responseBody, null );
        responseBody = jsonGenerateFolderData();
        SingleRequestMock fakeResponseRootFolder = new SingleRequestMock(200, 'complete', responseBody, null );
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://api.box.com/2.0/folders/0', fakeResponseAccessToken);
        endpoint2TestResp.put('https://api.box.com/oauth2/token/', fakeResponseRefreshToken);
        endpoint2TestResp.put('https://api.box.com/2.0/folders/0'+'second', fakeResponseRootFolder);
        HttpMock multiCalloutMock = new HttpMock(endpoint2TestResp);
        system.Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        system.Test.startTest();
        Box_Integration_controller testObj =  init();
        testObj.retriveData('0');
        system.Test.stopTest();
        system.assertEquals(1, testObj.fileList.size(), 'incorrect file data parse');
        system.assertEquals('entry 1', testObj.fileList[0].name, 'Incorrect name identified');
        system.assertEquals(1, testObj.folderIdToNameMap.size(), 'incorrect folder data parse');
        system.assertEquals('entry 2', testObj.folderIdToNameMap.get('entry Id 2'), 'invlid folder details');
    }


    @isTest
     static void createFolderRequest(){
        SingleRequestMock fakeResponseFolderCreated = new SingleRequestMock(201, 'complete', 'new folder created', null );
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://api.box.com/2.0/folders', fakeResponseFolderCreated);
        string response = jsonGenerateFolderData();
        SingleRequestMock fakeResponseFolderData = new SingleRequestMock(200, 'complete', response, null );
        endpoint2TestResp.put('https://api.box.com/2.0/folders/0', fakeResponseFolderData);
        HttpMock multiCalloutMock = new HttpMock(endpoint2TestResp);
        system.Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Box_Integration_controller testObj =  init();
        testObj.folderName = 'new_folder';
        testObj.createFolder();
        system.assertEquals(1, testObj.fileList.size(), 'incorrect file data parse');
        system.assertEquals('entry 1', testObj.fileList[0].name, 'Incorrect name identified');
        system.assertEquals(1, testObj.folderIdToNameMap.size(), 'incorrect folder data parse');
        system.assertEquals('entry 2', testObj.folderIdToNameMap.get('entry Id 2'), 'invlid folder details');
    }

    @isTest
     static void downloadFileRequest() {
        map<string,string> responseHeader = new Map<string, string>();
        responseHeader.put('Location', 'www.testURL.com');
        SingleRequestMock fakeResponseFileDownlod = new SingleRequestMock(201, 'complete', 'download sucessfull', responseHeader );
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://api.box.com/2.0/files/fileid/content', fakeResponseFileDownlod);
        HttpMock multiCalloutMock = new HttpMock(endpoint2TestResp);
        system.Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Box_Integration_controller testObj =  init();
        testObj.selectedFile = 'fileid';
        Pagereference pr = testObj.downloadFile();
        system.assertEquals('www.testURL.com', pr.getURL(), 'Invalid download URl');
    }

    @isTest
     static void deleteFileRequest() {
        SingleRequestMock fakeResponseFileDelete = new SingleRequestMock(204, 'complete', 'delete file sucessfull', null );
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://api.box.com/2.0/files/fileid', fakeResponseFileDelete);
        string response = jsonGenerateFolderData();
        SingleRequestMock fakeResponseFolderData = new SingleRequestMock(200, 'complete', response, null );
        endpoint2TestResp.put('https://api.box.com/2.0/folders/0', fakeResponseFolderData);
        HttpMock multiCalloutMock = new HttpMock(endpoint2TestResp);
        system.Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Box_Integration_controller testObj =  init();
        testObj.selectedFile = 'fileid';
        testObj.deleteFile();
        system.assertEquals(1, testObj.fileList.size(), 'incorrect file data parse');
        system.assertEquals('entry 1', testObj.fileList[0].name, 'Incorrect name identified');
        system.assertEquals(1, testObj.folderIdToNameMap.size(), 'incorrect folder data parse');
        system.assertEquals('entry 2', testObj.folderIdToNameMap.get('entry Id 2'), 'invlid folder details');
    }

    @isTest
     static void deleteFolderRequest() {
        SingleRequestMock fakeResponseFileDelete = new SingleRequestMock(204, 'complete', 'delete folder sucessfull', null );
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://api.box.com/2.0/folders/folderID', fakeResponseFileDelete);
        string response = jsonGenerateFolderData();
        SingleRequestMock fakeResponseFolderData = new SingleRequestMock(200, 'complete', response, null );
        endpoint2TestResp.put('https://api.box.com/2.0/folders/0', fakeResponseFolderData);
        HttpMock multiCalloutMock = new HttpMock(endpoint2TestResp);
        system.Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Box_Integration_controller testObj =  init();
        testObj.selectedFolder = 'folderID';
        testObj.deleteFolder();
        system.assertEquals(1, testObj.fileList.size(), 'incorrect file data parse');
        system.assertEquals('entry 1', testObj.fileList[0].name, 'Incorrect name identified');
        system.assertEquals(1, testObj.folderIdToNameMap.size(), 'incorrect folder data parse');
        system.assertEquals('entry 2', testObj.folderIdToNameMap.get('entry Id 2'), 'invlid folder details');
    }

    @isTest
     static void uploadFileRequest() {
        SingleRequestMock fakeResponseFileUpload = new SingleRequestMock(201, 'complete', 'upload folder sucessfull', null );
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://upload.box.com/api/2.0/files/content?parent_id=0', fakeResponseFileUpload);
        string response = jsonGenerateFolderData();
        SingleRequestMock fakeResponseFolderData = new SingleRequestMock(200, 'complete', response, null );
        endpoint2TestResp.put('https://api.box.com/2.0/folders/0', fakeResponseFolderData);
        HttpMock multiCalloutMock = new HttpMock(endpoint2TestResp);
        system.Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Box_Integration_controller testObj =  init();
        testObj.uploadFileName = 'newfile.txt';
        testObj.uploadContent = Blob.valueOf('data here');
        testObj.uploadFileToBox();
        system.assertEquals(1, testObj.fileList.size(), 'incorrect file data parse');
        system.assertEquals('entry 1', testObj.fileList[0].name, 'Incorrect name identified');
        system.assertEquals(1, testObj.folderIdToNameMap.size(), 'incorrect folder data parse');
        system.assertEquals('entry 2', testObj.folderIdToNameMap.get('entry Id 2'), 'invlid folder details');
    }
}