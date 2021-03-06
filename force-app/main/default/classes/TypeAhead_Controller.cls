/* ----------------------------------------------------------------------------
Class Name     :  TypeAhead_Controller
Purpose        :  To retrive records from database to be passed to the view 
                    and further processing changes to the database.
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/

global with sharing class TypeAhead_Controller {
    public string log{get;set;}
    public List<sobject> records{get;set;}
    public SObject record{get;set;}
    public string searchText{get;set;}
    public String objectName{get;set;}
    public string inputobjectName{get;set;}
    public String objectNameHeading{get; set;}
    public List<string> recordValues{get;set;}
    public List<String> listofFields{get;set;}
    public List<String> listofFieldLabels{get;set;}
    public List<String> inputlistofFields{get;set;}
    public  Map<String, Schema.SObjectType> mapContainingObjects;
    public  Map<String, Schema.SObjectField> mapContainingFields;
    public  Map<String, String> mapContainingFieldslNames{get;set;}
    public String placeholderText{get; set;} 
    public Boolean processComplete {get;set;}
    global static String objectNameHere{get;set;}
    public string recordID{get;set;}
    public string updateRecordsValues {get;set;}

    /*
    * Constructor 
    * Description: initialize member variables and add initial data input.
    * Parameters: --
    */ 

    public TypeAhead_Controller() {        
        processComplete = false;
        mapContainingFieldslNames = new Map<String, String>();
        records = new List<sobject>();
        mapContainingObjects = Schema.getGlobalDescribe();
        input();
        processInput();
    }

    /*
    * Method Name: input
    * Description: Setting object and fields to display to view
    * Parameters: --
    * Returns:  void
    */ 

    public void input(){
        objectName = 'Account';
        listofFields = new List<String>();
        listofFields.add('Name');
        listofFields.add('Website');
        listofFields.add('NumberOfEmployees');
        listofFields.add('Industry');
        listofFields.add('Type');
        listofFields.add('Active__c');
        system.debug('input complete');
    }
    
    /*
    * Method Name: processInput
    * Description: To retrive the label of object and store name and lables of fields of object
    * Parameters: --
    * Returns:  void
    */ 


    public void processInput(){
        system.debug('great');
        objectNameHeading = mapContainingObjects.get(objectName).getDescribe().getLabel();
        mapContainingFields = mapContainingObjects.get(objectName).getDescribe().fields.getMap();
        List<String> first3Fields = new List<String>();
        for(string str : listofFields){
            string lable = mapContainingFields.get(str).getDescribe().getLabel();
            mapContainingFieldslNames.put(lable, str);
        }
        listofFieldLabels = new list<string>(mapContainingFieldslNames.keySet());
        processComplete = true;
    }

    /*
    * Method Name: retriveRecord
    * Description: SOQL Query record based on supplied record Id
    * Parameters: --
    * Returns:  void
    */ 


    public void retriveRecord(){
        system.debug(recordID);
        recordValues = new List<String>();
            String query = 'SELECT ';
            query += string.join(listofFields, ', ');
            query += ' FROM '+ objectName;
            query += ' WHERE ID NOT IN :records And ID = \''+ recordID+'\'';
            system.debug(query);
            list<SObject> queryResult = Database.query(query);
            if(queryResult.size() > 0 ){
                record = queryResult[0]; 
                records.add(record);
                for(string field : listofFields){
                    if(record.get(field) == null){
                        recordValues.add('<null>');
                    }else{
                        recordValues.add(string.valueOf(record.get(field)));
                    }
                }
            }else{
                recordValues.add('<duplicate>');
            }
            
        system.debug(records);

    }
   /*
    * Method Name: saveRecords
    * Description: Commit changes to the data in the view to the database and display error message 
                    for invalid input string.
    * Parameters: --
    * Returns:  void
    */ 


    public void saveRecords(){
        List<sobject> recordList = new List<SObject>();
        system.debug(updateRecordsValues );
        List<string> recordListString = updateRecordsValues .split('##');
        system.debug(recordList);
        boolean failed = false;

        for(string singleRecord : recordListString){
            List<String> recordDataList = singleRecord.split('#');
            system.debug('value' + recordDataList);
            SObject record = records[Integer.valueOf(recordDataList[0])];
            for(Integer i = 1; i< recordDataList.size(); i += 2){
                string fieldApiName = mapContainingFieldslNames.get(recordDataList[i]);
                string fieldType = mapContainingFields.get(fieldApiName).getDescribe().getType().name();
                string fieldValue = recordDataList[i+1];
                try {
                    if(fieldType == 'currency' || fieldType == 'double' || fieldType == 'percent' || fieldType == 'decimal' ){
                        record.put(fieldApiName, Decimal.valueOf(fieldValue));
                    }else if (fieldType == 'boolean') {
                        if(Boolean.valueOf(fieldValue) == false && fieldValue.containsIgnoreCase('false')){
                            record.put(fieldApiName, Boolean.valueOf(fieldValue));
                        }else if(Boolean.valueOf(fieldValue) != false){
                            record.put(fieldApiName, Boolean.valueOf(fieldValue));
                        }
                    }else if(fieldType == 'date'){
                        List<String> dateVar = (fieldValue.substringBefore(' ')).split('/');
                        system.debug(dateVar);
                        record.put(fieldApiName,date.newInstance(Integer.valueOf(dateVar[2]), Integer.valueOf(dateVar[1]), Integer.valueOf(dateVar[0])));
                    }else if(fieldType == 'datetime'){
                        List<String> dateTimeVar = (fieldValue.substringBefore(' ')).split('/');
                        dateTimeVar.addAll((fieldValue.substringAfter(' ')).split(':'));
                        system.debug(dateTimeVar);
                        record.put(fieldApiName,Datetime.newInstanceGmt(Integer.valueOf(dateTimeVar[2]), Integer.valueOf(dateTimeVar[1]), Integer.valueOf(dateTimeVar[0]), Integer.valueOf(dateTimeVar[3]), Integer.valueOf(dateTimeVar[4]), Integer.valueOf(dateTimeVar[5])));
                    }else if (fieldType == 'integer' ) {
                        record.put(fieldApiName, Integer.valueOf(fieldValue));
                    }else{
                        record.put(fieldApiName, fieldValue);
                    }
                } catch (Exception e) {
                    system.debug(e);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                    failed = true;
                    continue;
                }
            }
            system.debug(record);
            if(!failed){
                recordList.add(record);
            }else{
                failed = false;
            }
        }

        update recordList;

    }

    /*
    * Method Name: searchSuggestion
    * Description: SOSL Query records based on the specified search string from view
    * Parameters: searchString (string), objName (string), fieldApiName (string)
    * Returns:  List<SobjectWrapper>
    */ 


    @RemoteAction
    public static List<SobjectWrapper> searchSuggestion(String searchString, string objName, string fieldApiName){
        System.debug(objName +' : '+ fieldApiName);
        List<SobjectWrapper> sobjWrapperList = new List<SobjectWrapper>();
        string query = 'find \'*'+searchString+'*\' IN ALL FIELDS RETURNING ';
        query += objName + ' (id, '+fieldApiName+'  WHERE '+fieldApiName+' Like \'%'+searchString+'%\' )';
        system.debug(query);
        List<List<sObject>> searchResults = Search.query(query);
        for(List<SObject> objects : searchResults){  
            for(SObject obj : objects){
                sobjWrapperList.add(new SobjectWrapper(string.valueOf(obj.get(fieldApiName)),string.valueOf(obj.Id)));  
            }  
       }  
        system.debug(Search.query(query));
        return sobjWrapperList;
    }

    /*
    * Class Name: SobjectWrapper
    * Description: provides basic layout to javascript response from apex
    */ 


    public class SobjectWrapper {  
        public String label { get; set; }  
        public String value { get; set; }  
        public SobjectWrapper (String label, String value){  
             this.label = label;  
             this.value = value;  
        }  
    }

}