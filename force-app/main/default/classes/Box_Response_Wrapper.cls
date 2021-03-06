/* ----------------------------------------------------------------------------
Class Name     :  Box_Response_Wrapper
Purpose        :  Wrapper class for parsing response from box.com
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/
public class Box_Response_Wrapper {
    public integer status_Code;
    public string body;
    public FoldersInfo folderDetails;

    /*
    * Constructor 
    * Description: no argument constructor to initilize object.
    * Parameters: --
    */ 

    public Box_Response_Wrapper(){}

    /*
    * Constructor 
    * Description: constructor to initilize with the response status code.
    * Parameters: status_Code (integer) 
    */ 

    public Box_Response_Wrapper(integer status_Code){
        this.status_Code = status_Code;
    }

    /*
    * Constructor 
    * Description: constructor to initilize with the response status code argument and body.
    * Parameters: status_Code (integer), body (string)
    */

    public Box_Response_Wrapper(integer status_Code, string body) {
        this.status_Code = status_Code;
        this.body = body;
        system.debug(status_Code);
        system.debug(body);
    }
    /*
    * Class Name: FoldersInfo
    * Purpose: Base Parsing by value of the response from folder information callout.
    */ 


    public class FoldersInfo{
        public String type{get;set;}
        public String id{get;set;}
        public String sequence_id{get;set;}
        public String etag{get;set;}
        public String name{get;set;}
        public String created_at{get;set;}
        public String modified_at{get;set;}
        public String item_status{get;set;}
        public String description{get;set;}
        public ItemCollections item_collection{get;set;}
        public FoldersInfo(){}
        public FoldersInfo(string type, string id, string sequence_id, string etag, string name,string created_at, string modified_at, string item_status, string description){
            this.type=type;
            this.id=id;
            this.sequence_id=sequence_id;
            this.etag=etag;
            this.created_at=created_at;
            this.modified_at=modified_at;
            this.description=description;
            this.item_status=item_status;
            this.item_collection=new itemCollections();
        }
    }

    /*
    * Class Name: ItemCollections
    * Purpose: Items Parsing by value of the response from folder information callout.
    */ 


    public class ItemCollections{
        public String total_count{get;set;}
        public List<entry> entries{get;set;}
        public ItemCollections(){}
        public ItemCollections(String count){
            this.total_count=count;
            this.entries=new list<entry>(); 
        }
    }

    /*
    * Class Name: entry
    * Purpose: Item Parsing by value of the response from folder information callout.
    */ 

    public class entry{
        public String type{get;set;}
        public String id{get;set;}
        public String name{get;set;}
        public entry(String type,String id,String name){
            this.type=type;
            this.id=id;
            this.name=name;
        }   
    }
}