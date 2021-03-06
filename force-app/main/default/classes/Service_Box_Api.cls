/* ----------------------------------------------------------------------------
Class Name     :  Service_Box_Api
Purpose        :  Service Class For Integration with Box.com
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/
public with sharing class Service_Box_Api {
    public Box_Response_Wrapper response;
    
    /*
    * Constructor 
    * Description: public constructor with no parameters.
    * Parameters: --
    */ 
    public Service_Box_Api(){}

    /*
    * Method Name: makeHttpRequest
    * Description: Generic Method for making Http request
    * Parameters: req (HttpRequest)
    * Returns:  Box_Response_Wrapper
    */ 

    public Box_Response_Wrapper makeHttpRequest(HttpRequest req){
        Http http = new Http();
        HttpResponse res = http.send(req);
        response = new Box_Response_Wrapper(res.getStatusCode(), res.getBody());
        return response;
    }

    /*
    * Method Name: requestAuthCode
    * Description: Generate url for authentication page
    * Parameters: client_id (string), redirect_uri (String)
    * Returns:  string
    */ 

    public string requestAuthCode(string client_id, String redirect_uri){
        string authorizeUrl = 'https://account.box.com/api/oauth2/authorize?';
        authorizeUrl += 'client_id=' +client_id+ '&response_type=code' ;
        authorizeUrl += '&redirect_uri=' +redirect_uri;
        system.debug(authorizeUrl);
        return authorizeUrl;
    }

    /*
    * Method Name: requestAccessToken
    * Description: callout to get access token from box key server
    * Parameters: code (string), client_id (string), client_secret(string), redirect_uri (String)
    * Returns:  Box_Response_Wrapper
    */ 

    public Box_Response_Wrapper requestAccessToken(string code, string client_Id, string client_secret, String redirectUrl){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.box.com/oauth2/token/');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        String messageBody = 'code='+code+'&client_id='+client_Id+'&client_secret='+client_secret+'&redirect_uri='+redirectUrl+'&grant_type=authorization_code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        System.debug(' Response :: ' + response);
        response = makeHttpRequest(req);
        return response;
    }

    /*
    * Method Name: fetchFolderInformation
    * Description: callout to get the folder info with its contents 
    * Parameters: folderID (string), accessToken (string)
    * Returns:  Box_Response_Wrapper
    */ 


    
    public Box_Response_Wrapper fetchFolderInformation(string folderID, string accessToken){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://api.box.com/2.0/folders/'+ folderID);
        req.setHeader('Authorization', 'Bearer '+ accessToken);
        req.setTimeout(60*1000);
        system.debug(req);
        system.debug(req.getHeader('Authorization') );
        response = makeHttpRequest(req);
        if(response.status_Code == 200){
            response.folderDetails = (Box_Response_Wrapper.FoldersInfo) JSON.deserialize(response.body, Box_Response_Wrapper.FoldersInfo.class);
        }
        return response;
    }

    /*
    * Method Name: refreshAccessToken
    * Description: callout to regenrate access token by using refresh token 
                    after previous token has expired.
    * Parameters: client_id (string), client_secret(string), redirect_uri (String), refresh_token (String)
    * Returns:  Box_Response_Wrapper
    */ 
    
    public Box_Response_Wrapper refreshAccessToken(string client_Id, string client_secret, String redirectUrl, string refresh_token){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.box.com/oauth2/token/');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        String messageBody = '&client_id='+client_Id+'&client_secret='+client_secret+'&refresh_token='+refresh_token+'&redirect_uri='+redirectUrl+'&grant_type=refresh_token';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        response = makeHttpRequest(req);
        return response;
    }

    /*
    * Method Name: postNewFolder
    * Description: making a POST request to create a new folder in 
                    specified parent folder with provided name
    * Parameters: access_token (string), name(string), parent (String)
    * Returns:  Box_Response_Wrapper
    */ 
    
    public Box_Response_Wrapper postNewFolder(string access_token, string name, string parent){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.box.com/2.0/folders');
        req.setHeader('Authorization', 'Bearer '+ access_token);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60*1000);
        String requestBody = '{"name": "'+name+'","parent": {"id": "'+parent+'"}}';
        req.setBody(requestBody);
        response = makeHttpRequest(req);
        return response;
    }

    /*
    * Method Name: deleteFolderService
    * Description: Delete request to the server for specified folder.
    * Parameters: access_token (string), selectedFolder(string)
    * Returns:  Box_Response_Wrapper
    */ 

    public Box_Response_Wrapper deleteFolderService(string access_token, String selectedFolder){
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        req.setEndpoint('https://api.box.com/2.0/folders/'+ selectedFolder);
        req.setHeader('Authorization', 'Bearer '+ access_token);
        req.setTimeout(60*1000);
        response = makeHttpRequest(req);
        return response;
    }

    /*
    * Method Name: deleteFileService
    * Description: Delete request to the server for specified file.
    * Parameters: access_token (string), selectedFile(string)
    * Returns:  Box_Response_Wrapper
    */ 


    public Box_Response_Wrapper deleteFileService(string access_token, String selectedFile){
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        req.setEndpoint('https://api.box.com/2.0/files/'+ selectedFile);
        req.setHeader('Authorization', 'Bearer '+ access_token);
        req.setTimeout(60*1000);
        response = makeHttpRequest(req);
        return response;
    }

     /*
    * Method Name: uploadFileService
    * Description: Post request to the server to upload file to server of specified name and content.
    * Parameters: access_token (string), uploadContent (string), uploadFilename (string) , selectedFolder(string)
    * Returns:  Box_Response_Wrapper
    */ 

    public Box_Response_Wrapper uploadFileService(string access_token, Blob uploadContent, string uploadFilename, string selectedFolder){
        blob base64EncodeFile = base64EncodeFileContent(uploadContent, uploadFilename);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://upload.box.com/api/2.0/files/content?parent_id=' +selectedFolder);
            String boundary = '----------------------------741e90d31eff';
            req.setBodyAsBlob(base64EncodeFile);
            req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
            req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setMethod('POST');
            req.setTimeout(120000);
            response = makeHttpRequest(req);
            return response;
    }

    /*
    * Method Name: downloadFileService
    * Description: Make callout to get the download url for the provided file id.
    * Parameters: access_token (string), selectedFile(string)
    * Returns:  String
    */ 

    public String downloadFileService(string access_token, string selectedFile){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.box.com/2.0/files/'+selectedFile+'/content');
        req.setHeader('Authorization', 'Bearer ' + access_token);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setMethod('GET');
        req.setTimeout(120000);
        Http http = new Http();
        HttpResponse res = http.send(req);
        system.debug(res.getHeader('Location'));
        return res.getHeader('Location');
    }

    /*
    * Method Name: base64EncodeFileContent
    * Description: Make adjustments and properly base encode file contents to be sent to server.
    * Parameters: file_body (Blob), file_name(string)
    * Returns:  Blob
    */ 


    public Blob base64EncodeFileContent(Blob file_body, string file_name ){
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('=')){
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else{
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
        return bodyBlob;
    }

    

}