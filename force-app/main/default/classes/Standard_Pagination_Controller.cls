/* ----------------------------------------------------------------------------
Class Name     :  Standard_Pagination_Controller
Purpose        :  Controller for standard pagination VF Page
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/

public class Standard_Pagination_Controller {
    public static final Integer QUERY_LIMIT = 10000;
    public static final Integer PAGE_SIZE = 5;
    public Integer totalPages{get; set;}
    public Integer size{get; set;}
    public Integer pageNumber {get; set;}
    public Integer noOfRecords {get; set;}
    public Integer noOfSelected {get; set;}
    public string query;
    public String selectedContact {get; set;}
    public String sortField {get; set;}
    public String prevSortField {get; set;}
    public String doctyper{get; set;}
    public string csvFile{get;set;}
    public String charLike{get; set;}
    public Boolean hasNext{get; set;}
    public Boolean hasPrevious{get; set;}
    public Boolean assendingOrder{get; set;}
    public List<Contact> contacts {get;set;}
    public List<SelectOption> paginationSizeOptions {get; set;}
    public List<Wrapper> recordList{get; set;}
    public List<string> listofFieldsDisplay{get;set;}
    public set<String> characterFilter {get; set;}
    public Map<ID, Wrapper> mapRecordList{get; set;}
    public  Map<String, Schema.SObjectField> mapContainingFields {get; set;}
    public Map<String,string> mapContainingFieldslabels{get;set;}
    public ApexPages.StandardSetController setCon {get;set;}

    /*
    * Constructor 
    * Description: initializes values and call to init.
    * Parameters: --
    */ 
    
    public Standard_Pagination_Controller(){
        doctyper = 'html-5.0';
        mapRecordList = new Map<ID, Wrapper>();
        init(); 
        characterFilter = new set<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','Other','All'};
         listofFieldsDisplay = new List<String>{'ID','Name','FirstName','LastName','Email'};
         mapContainingFields = Schema.getGlobalDescribe().get('contact').getDescribe().fields.getMap();
         mapContainingFieldslabels = new Map<String, String>();        
    }
    /*
    * Method Name: universalQuery
    * Description: Function to handle any form of requirement by forming optimal query in form of string.
    * Parameters: --
    * Returns:  void
    */ 
    
    public void universalQuery(){
        string querySOQL = 'SELECT ID, name, FirstName, LastName, Email,Account.name FROM contact ';
        
        if(charLike !='null' && charLike != 'Other' && charLike != 'All' ){ //SELECT ID, Name FROM Account WHERE (NOT name LIKE 'E%') OR name LIKE 'P%'
            system.debug(charLike);
            querySOQL += ' Where Name' +' Like \''+charLike+'%\'';
        }
        if(sortField != null){
            querySOQL += 'ORDER BY '+sortField +' '+ ((assendingOrder)?'ASC':'DESC NULLS LAST');
        }
        querySOQL += ' LIMIT ' + QUERY_LIMIT ;

        if(charLike == 'other'){
            otherFilter();  
        }else{
            List<Contact> con = Database.query(querySOQL);
            setCon = new ApexPages.StandardSetController(con);
            query = querySOQL;
        }
        
        system.debug(querySOQL);
        
        setCon.setPageSize(PAGE_SIZE);
        noOfRecords = setCon.getResultSize();
        size = setCon.getPageSize();
        selectOptions();
        validatePage();
        totalPagecal();
        
    }
    /*
    * Method Name: otherFilter
    * Description: Function to handle filter by name not starting with alphabet (Other).
    * Parameters: --
    * Returns:  void
    */ 
    public void otherFilter(){
        List<contact> contactRec = [SELECT ID, name, FirstName, LastName, Email,Account.name FROM contact];
        List<contact> contactOther = new List<Contact>();
        //Pattern specialCharacter = Pattern.compile('[^a-z0-9]',Pattern.CASE_INSENSITIVE);
        for(contact c: contactRec){
            if(c.name == null || !c.name.substring(0, 1).isAlpha() ){
        
                contactOther.add(c);
            }
        }
        setCon = new ApexPages.StandardSetController(contactOther);
    }
    /*
    * Method Name: init
    * Description: To initialize the page with initial records.
    * Parameters: --
    * Returns:  void
    */ 
    
    public void init(){
        
        charLike='null';
       universalQuery();
    } 
    /*
    * Method Name: selectOptions
    * Description: Inserts options to the select list of no of records to retrive in page.
    * Parameters: --
    * Returns:  void
    */

    public void selectOptions(){
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
    }
    /*
    * Method Name: pageSizeChange
    * Description: Used to handle the event when no of records to retrive on page is changed.
    * Parameters: --
    * Returns:  void
    */

    public void pageSizeChange(){
        setCon.setPageSize(size);
        validatePage();
        totalPagecal();
    }
    /*
    * Method Name: first
    * Description: Basic Record retrive operation of initial records.
    * Parameters: --
    * Returns:  void
    */
    public void first(){
        setCon.first();
        validatePage();
        

    }
    /*
    * Method Name: previous
    * Description: Basic Record retrive operation of previous records.
    * Parameters: --
    * Returns:  void
    */
    public void previous(){
        setCon.previous();
        validatePage();
        
        
    }
    /*
    * Method Name: next
    * Description: Basic Record retrive operation of next records.
    * Parameters: --
    * Returns:  void
    */

    public void next(){
        setCon.next();
        validatePage();
        
    }
    /*
    * Method Name: last
    * Description: Basic Record retrive operation of records from the last of list in database.
    * Parameters: --
    * Returns:  void
    */
    public void last(){
        setCon.last();
        validatePage();
        
    }
    /*
    * Method Name: pageNoChanged
    * Description: Validates the page no of page.
    * Parameters: --
    * Returns:  void
    */
    public void pageNoChanged(){
        if(pageNumber <= totalPages){
            setCon.setPageNumber(pageNumber);
            validatePage();
        }else{
            pageNumber = setCon.getPageNumber();
        }
    }
    /*
    * Method Name: validatePage
    * Description: Validated all the stats of the page on query
    * Parameters: --
    * Returns:  void
    */

    public void validatePage(){
        wrapperListAndMap();
       hasNext = setCon.getHasNext();
       hasPrevious = setcon.getHasPrevious();
        pagenumber = setCon.getPageNumber();
                
    }  
    /*
    * Method Name: totalPagecal
    * Description: Calculates to total no of pages on the basis of records.
    * Parameters: --
    * Returns:  void
    */ 
    public void totalPagecal(){
        decimal recordsno =setCon.getResultSize();
        decimal pagesize = setCon.getPageSize();
        decimal pages = recordsno/pagesize;
        totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
    }
    /*
    * Method Name: singledelete
    * Description: delete operation on single record.
    * Parameters: --
    * Returns:  void
    */
    public void singledelete(){
        system.debug('In single delete' + selectedContact);
        for(Integer i = 0 ; i < recordList.size(); i++){            
            if(recordList[i].contactRecord.id == selectedContact ){
                
                Database.DeleteResult result =  Database.delete(recordList[i].contactRecord,false);
                if(!result.isSuccess()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,result.getErrors()[0].getMessage()));   
                }else{
                    if(mapRecordList.containsKey(recordList[i].contactRecord.id)){
                    mapRecordList.get(recordList[i].contactRecord.id).isSelected = false;
                    addWrapperToMap();
                    }
                }
                deleteValidate();
            }
        }
        
    }
    /*
    * Method Name: deleteValidate
    * Description:validates Delete operations on multiple as well as single records.
    * Parameters: --
    * Returns:  void
    */

    public void deleteValidate(){
        List<Contact> con = Database.query(query);
        setCon = new ApexPages.StandardSetController(con);
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
        totalPagecal();
        while(pageNumber > totalPages){
            pageNumber--;
        }
        setCon.setPageNumber(pageNumber);
        wrapperListAndMap();
        hasNext = setCon.getHasNext();
        hasPrevious = setcon.getHasPrevious();
    }
    
    /*
    * Method Name: deleteSelected
    * Description: Delete operation on multiple selected records.
    * Parameters: --
    * Returns:  void
    */

    public void deleteSelected(){
        List<Contact> contacts = new List<Contact>();
        for( ID I: mapRecordList.keySet() ){
            contacts.add(mapRecordList.get(i).contactRecord);
        } 
        Database.DeleteResult[] results =   Database.delete(contacts, false);
        for(Database.DeleteResult r :results){
            if(!r.isSuccess()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,r.getErrors()[0].getMessage())); 
            }else{
                if(mapRecordList.containsKey(r.id)){
                    mapRecordList.get(r.id).isSelected = false;
                    addWrapperToMap();
                }
            }
        }
        deleteValidate(); 
    }
    /*
    * Method Name: wrapperListAndMap
    * Description: Creating records from sobject records in wrapper class
    * Parameters: --
    * Returns:  void
    */
 
    
    public void wrapperListAndMap(){
        contacts = setCon.getRecords();
        recordList = new List<Wrapper>();
        for(contact c : contacts){
            if(mapRecordList != null && mapRecordList.containsKey(c.ID) ){
                recordList.add(new Wrapper (c,mapRecordList.get(c.id).isSelected ));
            }else{
                recordList.add(new Wrapper(c, false));
            }
        }   
    }
    /*
    * Method Name: addWrapperToMap
    * Description: Maintains Collection(MAP) of selected records.
    * Parameters: --
    * Returns:  void
    */
    public void addWrapperToMap(){
        
        for(Wrapper w: recordList){
            if( w.isSelected == true){
                mapRecordList.put(W.contactRecord.Id, w);
            }
            if(W.isSelected == false){
                mapRecordList.remove(w.contactRecord.Id);
            }
        }
        noOfSelected = mapRecordList.size();
    }
    /*
    * Method Name: sortInit
    * Description: Sorting on the basis of field to define the sort order.
    * Parameters: --
    * Returns:  void
    */
    
    
    public void sortInit(){
        
        if(assendingOrder == null || prevSortField !=sortField ){
            assendingOrder = true;
            prevSortField = sortField;
        }else{
            assendingOrder = !assendingOrder;
        }
         universalQuery();
    }
    
    /*
    * Class Name: Wrapper
    * Description: Wrapper class used to store sobject records with its attributes.
    */
    public class Wrapper{
        public Boolean isSelected{get; set;}
        public contact contactRecord{get; set;}
        public Wrapper(Contact contactRecord,Boolean isSelected){
            this.contactRecord = contactRecord;
            this.isSelected = isSelected;
        }
    }
    /*
    * Method Name: createCSV
    * Description: Creates a string from the selected records to be used to make csv file.
    * Parameters: --
    * Returns:  void
    */
    public void createCSV(){
            csvFile = 'Contact Object Records\\r\\n';
            for(String s : listofFieldsDisplay){
                csvFile+='"';
                csvFile += s +'",';
            }
        	csvFile += '"Account Name"';
            csvFile += '\\r\\n';
            for( string k: mapRecordList.keySet()  ){
                Wrapper w =  mapRecordList.get(k);
                if(w.isSelected){
                    csvFile += '"';
                    for(String s : listofFieldsDisplay){
                        csvFile += w.contactRecord.get(s)+'","';
                    }
                    csvFile += w.contactRecord.Account.name+'","';
                    csvFile = csvFile.substring(0,csvFile.length()-2);
                    csvFile += '\\r\\n';
                }
            }
    }
           
}