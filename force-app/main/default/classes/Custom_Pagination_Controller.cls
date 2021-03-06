/* ----------------------------------------------------------------------------
Class Name     :  Custom_Pagination_Controller
Purpose        :  Controller for custom pagination VF Page
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/



public class Custom_Pagination_Controller {

    
    public  List<SelectOption> allObjects { get; set; }
    public  List<SelectOption> allFields {get; set;}
    public  List<SelectOption> selectedFieldsOption { get; set;}
    public  List<String> selectedFields{get;set;}
    public  List<String> deselectedFields{get;set;}
    public  list<string> queryFields {get; set;}
    public  List<string> fieldListOutput {get; set;}
    public  List<string> fixedFieldListOutput {get; set;}
    public Boolean renderComponent{get;set;}
    public string objectName {get; set;}
    public string objectNameHeading {get; set;}
    public string objectNameOutput{get; set;}
    public string fixedObjectNameOutput{get; set;}
    public  Map<String, Schema.SObjectType> mapContainingObjects {get; set;}
    public  Map<String, Schema.SObjectField> mapContainingFields {get; set;}
    Map<string, string> fieldMap {get; set;}

    /*
    * Constructor 
    * Description: initializes values and call to retriveObjects.
    * Parameters: --
    */ 
    public Custom_Pagination_Controller(){
        retriveObjects();
        renderComponent = false;
        fieldListOutput = new List<String>();
    }

    /*
    * Method Name: reset
    * Description: Resets value of the object and it's fields to default
    * Parameters: --
    * Returns:  PageReference
    */ 
    
    public PageReference reset() {
        PageReference newpage = new PageReference(System.currentPageReference().getURL());    
        newpage.getParameters().clear();
        newpage.setRedirect(false);
        objectName =null;
        allFields = null;
        selectedFields = null;
        fieldListOutput = null;
        deselectedFields =null;
        retriveObjects();
        return newpage;
      }

      /*
    * Method Name: retriveObjects
    * Description: Retrives list of Object names for picklist 
    * Parameters: --
    * Returns:  void 
    */ 

    public void retriveObjects(){
        mapContainingObjects = Schema.getGlobalDescribe();
        allObjects = new List<SelectOption>();
        Map<string, string> objectMap = new Map<String,String>();
        for(String s : mapContainingObjects.keySet()){
            if(validatorObject(mapContainingObjects.get(s)))  {
                objectMap.put(mapContainingObjects.get(s).getDescribe().getLabel(), s);
            }
        }
        list<String> objectlist = new List<String>(objectMap.keySet());
        objectlist.sort();
        for(String str : objectlist) {
            allObjects.add(new selectOption(mapContainingObjects.get(objectMap.get(str)).getDescribe().getName(), str));
        }
        
    }
    /*
    * Method Name: retriveFields
    * Description: Retrives list of field names from object selected for picklist 
    * Parameters: --
    * Returns:  void 
    */ 

    public void retriveFields(){
        selectedFieldsOption = new List<selectOption>();
        objectNameHeading = mapContainingObjects.get(objectName).getDescribe().getLabel().toUpperCase();

        allFields =  new List<SelectOption>();
        mapContainingFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        fieldMap = new Map<String,String>();
        for(String s : mapContainingFields.keySet()){
            if(validatorField(mapContainingFields.get(s)))  {
                fieldMap.put(mapContainingFields.get(s).getDescribe().getLabel(), s);
            }
        }
        list<String> fieldlist = new List<String>(fieldMap.keySet());
        fieldlist.sort();
        for(Integer i = 0; i < fieldlist.size(); i++){
            allFields.add(new selectOption(mapContainingFields.get(fieldMap.get(fieldlist.get(i))).getDescribe().getName(), fieldlist.get(i)));
        }
        queryFields= new List<String>();

    }

            /*
    * Method Name: validatorObject
    * Description: verify's that the object should be added to the objects list or not
    * Parameters: obj ( SObjectType )
    * Returns:  boolean 
    */ 
    public boolean validatorObject(SObjectType obj){
        
        Schema.DescribeSobjectResult objresult = obj.getDescribe();

        if( objresult.isCreateable() && objresult.isQueryable() && objresult.isUpdateable()  && objresult.isDeletable() && objresult.isAccessible() && objresult.getName() != 'vote'){
            return true;
        }else{
            return false;
        }
    }

    /*
    * Method Name: validatorField
    * Description: verify's that the field should be added to the fields list or not
    * Parameters: field ( SObjectField )
    * Returns:  boolean 
    */ 

    public boolean validatorField(SObjectField field){
        
        
        Schema.DescribeFieldResult fieldresult = field.getDescribe();

        if( fieldresult.isCreateable()){
            return true;
        }else{
            return false;
        }
    }

    /*
    * Method Name: selectFields
    * Description: list of selected fields added from fields list
    * Parameters: --
    * Returns:  void 
    */     

    public void selectFields(){
        fieldListOutput = new List<String>();
        if(selectedFieldsOption==null){
            selectedFieldsOption =new List<SelectOption>();
        }
        
        for(String s: selectedFields){
            selectedFieldsOption.add(new selectOption(s,mapContainingFields.get(s).getDescribe().getLabel()));
            queryFields.add(s);
            SelectOption selectOption = new SelectOption(s,mapContainingFields.get(s).getDescribe().getLabel());
            if(allFields.contains(SelectOption)){
                allFields.remove(allFields.indexOf(SelectOption));
            }
        }
    }

        /*
    * Method Name: deselectFields
    * Description: list of selected fields removed from selected list
    * Parameters: --
    * Returns:  void 
    */ 

    public void deselectFields(){
        fieldListOutput = new List<String>();
        queryFields = new List<String>();
        for(String s : deselectedFields){
        SelectOption deSelectOption = new SelectOption(s,mapContainingFields.get(s).getDescribe().getLabel());
            if(selectedFieldsOption.contains(deSelectOption)){
                allFields.add(selectedFieldsOption.get(selectedFieldsOption.indexOf(deSelectOption)));
                selectedFieldsOption.remove(selectedFieldsOption.indexOf(deSelectOption));
            }
        }
        List<String> selectedFieldslist = new List<String>();
        for(Integer i =0 ; i < allFields.size() ; i++){
            selectedFieldslist.add(allFields[i].getLabel());
        }
        selectedFieldslist.sort();
        allFields = new List<selectOption>();
        for(Integer i = 0; i < selectedFieldslist.size(); i++){
            allFields.add(new selectOption(mapContainingFields.get(fieldMap.get(selectedFieldslist.get(i))).getDescribe().getName(), selectedFieldslist.get(i)));
        }
        for(Integer i = 0 ; i < selectedFieldsOption.size();i++){
            queryFields.add(selectedFieldsOption[i].getValue());
        }
    }

           /*
    * Method Name: outputFieldsAndObject
    * Description: Passing value to component variables on process button press
    * Parameters: --
    * Returns:  void 
    */ 

    public void outputFieldsAndObject(){
        objectNameOutput = objectName;
        Set<String> outputfield = new Set<String>(queryFields);
        fieldListOutput = new List<String>(outputfield);
        renderComponent = true;
        
    }
   
    

    
}