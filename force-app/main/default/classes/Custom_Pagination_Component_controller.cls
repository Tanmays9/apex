/* ----------------------------------------------------------------------------
Class Name     :  Custom_Pagination_Component_controller
Purpose        :  Controller for custom pagination component VF Component of custom pagination VF Page
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

@Testsuite:  
----------------------------------------------------------------------------*/
public class Custom_Pagination_Component_controller {
    public static final Integer PAGE_SIZE = 5;
    
    public Integer size{get;set;}
    public Integer noOfRecords{get;set;}
    public Integer totalPages{get; set;}
    public Integer pageNumber{get; set;}
    public Integer varOffset{get; set;}
    public Integer varLimit{get;set;}
    public Integer noOfSelected{get; set;}
    public String objectName{get;set;}
    public String objectNameHeading{get; set;}
    public String sortField {get; set;}
    public String prevSortField {get; set;}
    public string selectedSobject{get; set;}
    public string csvFile{get; set;}
    public string keyPrefix{get;set;}
    public string lastIdInTable{get;set;}
    public string firstIdInTable{get;set;}
    public String charLike{get; set;}
    public string oldOperation{get; set;}
    public Boolean assendingOrder{get; set;}
    public boolean previous{get;set;}
    public boolean hasNext{get;set;}
    public boolean hasPrevious{get;set;}
    public Boolean processComplete{get; set;}
    
    public List<Wrapper> records{get; set;}
    public List<Sobject> recordList{get;set;}
    public List<String> listofFields{get;set;}
    public List<String> listofFieldsDisplay{get; set;}
    public List<SelectOption> paginationSizeOptions {get; set;}
    public set<String> characterFilter {get; set;}
    public  Map<ID, Wrapper> mapRecordList{get; set;}
    public  Map<String, Schema.SObjectType> mapContainingObjects {get; set;}
    public  Map<String, Schema.SObjectField> mapContainingFields {get; set;}
    public  Map<String, String> mapContainingFieldslabels {get; set;}
    public  Map<Id, sObject> objectshere {get;set;}
 
    
    /*
    * Constructor 
    * Description: initializes values of class.
    * Parameters: --
    */ 

    public Custom_Pagination_Component_controller() {
        init();
        characterFilter = new set<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','Other','All'};
        mapContainingObjects = Schema.getGlobalDescribe();
        previous = false;
    }

    /*
    * Method Name: init
    * Description: function containing initialization code for constructor
    * Parameters: --
    * Returns:  void
    */

    public void init(){
        records = new List<Wrapper>();
        selectOptions();        
        varOffset = 0;
        varLimit = size;
        mapRecordList = new Map<ID, Wrapper>();
        noOfSelected = 0;
    }
    /*
    * Method Name: processQuery
    * Description: Executed when process button is clicked to query records
    * Parameters: --
    * Returns:  void
    */


    public void processQuery(){
        init();
        records = new List<Wrapper>();
        records = null;
        charLike = null;
        sortField = null;
        first();
        objectNameHeading = mapContainingObjects.get(objectName).getDescribe().getLabel().toUpperCase();
        keyPrefix = Schema.getGlobalDescribe().get(objectName).getDescribe().getKeyPrefix();
         processComplete = false;
         mapContainingFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
         mapContainingFieldslabels = new Map<String, String>();
        for(string f : listofFields){
            mapContainingFieldslabels.put(f, mapContainingFields.get(f).getDescribe().getLabel());
        }
         listofFieldsDisplay= listofFields;
    }
    /*
    * Method Name: wrapperListAndMap
    * Description: Creating records from sobject records in wrapper class
    * Parameters: --
    * Returns:  void
    */
 
 
    public void wrapperListAndMap(){
        records = new List<Wrapper>();
        for(Sobject r : recordList){
            if(mapRecordList != null && mapRecordList.containsKey(r.ID) ){
                records.add(new Wrapper (r,objectName, listofFields, mapRecordList.get(r.ID).isSelected ));
            }else{
                records.add(new Wrapper(r,objectName, listofFields , false));
            }
        }
    }
     /*
    * Method Name: validatePage
    * Description: Validated all the stats of the page on query
    * Parameters: --
    * Returns:  void
    */
    public void validatePage(){
        calculateTotalNoOfRecords();
        totalPagecal();
        
        if(hasNext == null || hasPrevious == null ){
            hasNext = false;
            hasPrevious =false;
            
        }
        hasNext = (pageNumber < totalPages )? true:false;
        hasPrevious =  (pageNumber != 1 )? true: false;   
        if(noOfRecords==0){
            hasNext = false;
            hasPrevious =false; 
            pageNumber = 0;
        } 
    }
     /*
    * Method Name: calculateTotalNoOfRecords
    * Description: Gives the count of records in database of particular objecttype
    * Parameters: --
    * Returns:  void
    */

    public void calculateTotalNoOfRecords(){
        String query = 'SELECT count() ' ;
        query += ' FROM ' + objectName;
        if(charLike != null && charLike != 'Other' && charLike != 'All' ){ 
           query  += ' Where Name' +' Like \''+charLike+'%\'';
        }else if(charLike == 'Other'){
            query += ' Where Id != null ';
            query += ' AND (NOT name LIKE \'' ;
            query +=  String.join(new List<String>(characterFilter),'%\')  AND (NOT name LIKE \'');
            query += '%\')';
        }
        system.debug(query);
        noOfRecords = Database.countQuery(query);
                                          
    }
    /*
    * Method Name: queryById
    * Description: Gives list of records on the basis of operation.
    * Parameters: lastIdI(String), comparingSign( String ), order(String ), newLimit( Integer)
    * Returns:  void
    */

    public void queryById(String lastIdI, String comparingSign, String order, Integer newLimit){
        validatePage();

        String query='SELECT ' ;
        query += String.join(listofFields,', ');
        query += ' FROM '+ objectName + ' ';
        query += ' Where Id != null ';

        if(lastIdI != null && comparingSign != null){
            query += ' AND Id '+ comparingSign + '\''+ lastIdI +'\'';
        }

        if(charLike != null && charLike != 'All' && charLike != 'Other'){
            query += ' AND name LIKE \'' + charLike + '%\'';
        }else if(charLike == 'Other'){
            query += ' AND (NOT name LIKE \'' ;
            query +=  String.join(new List<String>(characterFilter),'%\')  AND (NOT name LIKE \'');
            query += '%\')';
        }
        if(sortField == null || !mapContainingFields.get(sortField).getDescribe().isSortable()){
            query += ' ORDER BY Id ' + order + ' LIMIT ' + newLimit;
            sortField = '';
            
        }else{
            query += ' ORDER BY '+sortField +' '+ ((assendingOrder)?'ASC':'DESC NULLS LAST') ;
            query += ', ID ' + order + ' LIMIT ' + newLimit;
        }
        
        system.debug(query);
        objectshere = new Map<Id, sObject>(Database.query(query));
        recordList = objectshere.values();
        

        Boolean markFirstId = true;
        for (sObject obj : objectshere.values()) {
            lastIdInTable = obj.Id;
            if (markFirstId) {
                firstIdInTable = obj.Id;
                markFirstId = false;
            }
        }
        
        if(order == 'ASC'){
            reverseRecords();
        }
        wrapperListAndMap();
    }
    /*
    * Method Name: first
    * Description: Basic Record retrive operation of initial records.
    * Parameters: --
    * Returns:  void
    */
    public void first(){
        oldOperation = 'DESC';
        pageNumber = 1;
        queryById( null, null, 'DESC',size );
        
    }
    /*
    * Method Name: previous
    * Description: Basic Record retrive operation of previous records.
    * Parameters: --
    * Returns:  void
    */

    public void previous(){
        if(oldOperation != 'ASC' && oldOperation != null ){
            String temp = lastIdInTable;
            lastIdInTable = firstIdInTable;
            firstIdInTable = lastIdInTable;
        }
        oldOperation = 'ASC';
        pageNumber -=1;
        queryById( lastIdInTable, '>', 'ASC',size );
    }
    /*
    * Method Name: next
    * Description: Basic Record retrive operation of next records.
    * Parameters: --
    * Returns:  void
    */

    public void next(){
        if(oldOperation != 'DESC' && oldOperation != null ){
            String temp = lastIdInTable;
            lastIdInTable = firstIdInTable;
            firstIdInTable = lastIdInTable;
        }
        oldOperation = 'DESC';
        pageNumber += 1;
        queryById( lastIdInTable, '<', 'DESC', size );
    }
    /*
    * Method Name: last
    * Description: Basic Record retrive operation of records from the last of list in database.
    * Parameters: --
    * Returns:  void
    */
    public void last(){
        oldOperation = 'ASC';
        pageNumber = totalPages;
        Integer queryLimit = noOfRecords - ((totalPages - 1) * size);
        queryById(null, null, 'ASC', queryLimit);
    }
    /*
    * Method Name: reverseRecords
    * Description: To reverse the order of list of records retrived.
    * Parameters: --
    * Returns:  void
    */

    public void reverseRecords(){
        List<sObject> revRecordList = new list<sObject>();
        for(integer i = recordList.size()-1 ; i >= 0 ; i--){
            revRecordList.add(recordList[i]);
        }
        recordList = revRecordList;
    }
    /*
    * Method Name: totalPagecal
    * Description: Calculates to total no of pages on the basis of records.
    * Parameters: --
    * Returns:  void
    */

    public void totalPagecal(){
        system.debug(noOfRecords);
        system.debug(size);
        decimal recordsno = noOfRecords;
        decimal pagesize = size;
        decimal pages = recordsno/pagesize;
        totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
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
        first();
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
    * Method Name: singledelete
    * Description: delete operation on single record.
    * Parameters: --
    * Returns:  void
    */

    public void singledelete(){
       

        for(Integer i = 0 ; i < records.size(); i++){
            if(records[i].SobjectRecord.id == selectedSobject ){
                Database.DeleteResult result =  Database.delete(records[i].SobjectRecord,false);
                if(!result.isSuccess()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,result.getErrors()[0].getMessage()));   
                }else{
                    processQuery();
                }
            }
        }
        
    }
    /*
    * Method Name: deleteSelected
    * Description: Delete operation on multiple selected records.
    * Parameters: --
    * Returns:  void
    */

    public void deleteSelected(){
        List<SObject> SObjects = new List<SObject>();
        for( ID I: mapRecordList.keySet() ){
            SObjects.add(mapRecordList.get(i).SobjectRecord);
            mapRecordList.get(i).isSelected = false;
        }
        addWrapperToMap();
 
        Database.DeleteResult[] results =   Database.delete(SObjects, false);
        for(Database.DeleteResult r :results){
            if(!r.isSuccess()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,r.getErrors()[0].getMessage()));   
               }
        }
                    processQuery();
    }
    /*
    * Method Name: addWrapperToMap
    * Description: Maintains Collection(MAP) of selected records.
    * Parameters: --
    * Returns:  void
    */
    
    public void addWrapperToMap(){
        for(Wrapper w: records){
            if( w.isSelected == true){
                mapRecordList.put(W.sobjectRecord.Id, w);
            }
            if(W.isSelected == false){
                mapRecordList.remove(w.sobjectRecord.Id);
            }
        }
        noOfSelected = mapRecordList.size();
    }

    /*
    * Class Name: Wrapper
    * Description: Wrapper class used to store sobject records with its attributes.
    */

    public class Wrapper{
        public Boolean isSelected{get; set;}
        public Sobject sobjectRecord{get; set;}
        public String nameOfObject{get;set;}
        public list<String> listofFieldsRec{get;set;}
        public Wrapper(Sobject sobjectRecord,String nameOfObject,list<String> listofFieldsRec  ,Boolean isSelected){
            this.SobjectRecord = SobjectRecord;
            this.isSelected = isSelected;
            this.nameOfObject = nameOfObject;
            this.listofFieldsRec = listofFieldsRec;
            
        }
    }
    /*
    * Method Name: createCSV
    * Description: Creates a string from the selected records to be used to make csv file.
    * Parameters: --
    * Returns:  void
    */

    
    public void createCSV(){
        csvFile = objectName.toUpperCase() + ' Object Records\\r\\n';
        for(String s : listofFieldsDisplay){
            csvFile+='"';
            csvFile += mapContainingFieldslabels.get(s)+'",';
        }
        csvFile = csvFile.substring(0,csvFile.length()-2);
        csvFile += '"\\r\\n';
        for( string k: mapRecordList.keySet()  ){
            Wrapper w =  mapRecordList.get(k);
            if(w.isSelected){
                csvFile += '"';
                for(String s : listofFieldsDisplay){
                    csvFile += w.sobjectRecord.get(s)+'","';
                }
                csvFile = csvFile.substring(0,csvFile.length()-2);
                csvFile += '\\r\\n';
            }
        }
        system.debug(csvFile);
    }

}