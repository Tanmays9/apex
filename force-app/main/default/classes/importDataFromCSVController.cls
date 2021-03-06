/* ----------------------------------------------------------------------------
Class Name     :  importDataFromCSVController
Purpose        :  Process data from the csv file to be commit to database
History:                                                            
-------                                                            
VERSION   DATE        Developer                          DETAIL                             
1.        27-12-2020  Tanmay Sharma                Original Version            

----------------------------------------------------------------------------*/

public with sharing class importDataFromCSVController {
    public Blob csvFileContents {get;set;}
    public string csvFileName{get;set;}
    public string csvString{get;set;}
    public List<Contact> cntList{get;set;}

     /*
    * Constructor 
    * Description: initializes values of member variable cntList.
    * Parameters: --
    */ 
    public importDataFromCSVController(){
        cntList = new List<Contact>();
    }

    /*
    * Method Name: importCSVFile
    * Description: Assigns values to the various fields of the object on basis of parsed list of string 
    * Parameters: --
    * Returns:  void
    */ 
    
    public void importCSVFile(){
        try {
            List<Contact> contacts = new List<Contact>();
            system.debug(csvFileContents);
            system.debug(csvFileName);
            csvString = csvFileContents.toString();
            for(List<String> strList : parseCsv(csvString)){
                system.debug(strList + ' : '+strlist.size());
                contact contactRecord = new Contact();
                contactRecord.LastName =  strList[0] == null ?  null:strList[0];
                contactRecord.Description  = strList[1] == null ?  null: strList[1];
                contactRecord.Active__c = strList[2] == null ?  false:boolean.valueOf(strList[2]);
                contactRecord.Birthdate =  strList[3] == null ?  null:date.valueOf(validateDateAndTime(strList[3]));
                contactRecord.Connected_On__c = strList[4] == null ?  null:validateDateAndTime(strList[4]);
                contacts.add(contactRecord);
            }
            insert contacts;
            system.debug(cntList);
            cntList.addAll(contacts);

            
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct \n' + e);
            ApexPages.addMessage(errorMessage);
            system.debug(e.getLineNumber());
            
            System.debug(e);
        } 
    }

      /*
    * Method Name: validateDateAndTime
    * Description: parse the provided date time string to actual date time data type
    * Parameters: dateTimeString  (string)
    * Returns:  Datetime
    */ 
    
    public Datetime validateDateAndTime(string dateTimeString){
        system.debug(dateTimeString);
            List<String> dateTimeVar = (dateTimeString.substringBefore(' ')).split('-');
            dateTimeVar.addAll((dateTimeString.substringAfter(' ')).split(':'));
            while(dateTimeVar.size() < 6){
                dateTimeVar.add('00');
            }
            system.debug(dateTimeVar);
            system.debug(dateTimeVar[4].getChars()  );
            Datetime output = Datetime.newInstanceGmt(Integer.valueOf(dateTimeVar[2]), Integer.valueOf(dateTimeVar[1]), Integer.valueOf(dateTimeVar[0]), Integer.valueOf(dateTimeVar[3]), Integer.valueOf(dateTimeVar[4]), Integer.valueOf(dateTimeVar[5]));
            system.debug(Datetime.newInstanceGmt(Integer.valueOf(dateTimeVar[2]), Integer.valueOf(dateTimeVar[1]), Integer.valueOf(dateTimeVar[0]), Integer.valueOf(dateTimeVar[3]), Integer.valueOf(dateTimeVar[4]), Integer.valueOf(dateTimeVar[5])));
            return Datetime.newInstance(output.yearGmt(),output.monthGmt(),output.dayGmt(),output.hourGmt(),output.minuteGmt(),output.secondGmt());
    }

      /*
    * Method Name: parseCsv
    * Description: Parsing csv content string from input file to field values of the object records to insert.
    * Handled Cases : Comma in field value,
                        DoubleQuote in field value,
                        \n in field value.
    * Parameters: csvContent (string)
    * Returns:  list<list<string>
    */ 

    public list<list<string>> parseCsv(string csvContent){
        List<List<string>> parsedCsv = new List<List<string>>();
        list<string> row  = new List<String>();
        string data = '';
        integer stringStart;
        integer stringEnd;
        csvContent = csvContent.replace('""""', '<DQUOTE>');
        csvContent = csvContent.replace(',"""', ',"<DQUOTE>');
        csvContent = csvContent.replace('""",', '<DQUOTE>",');
        csvContent = csvContent.replace('""', '<DQUOTE>');
        csvContent = csvContent.removeEnd('\r\n');
        integer[] characters = csvContent.getChars();
        system.debug('char start');
        for(integer inte : characters){
            system.debug(inte +' refers to ' + string.fromCharArray(new list<integer>{inte}));
        }
        system.debug('char end');

        for(integer i = 0 ;i < characters.size(); i++){
            system.debug(i +' is going to be ' + string.fromCharArray(new list<integer>{characters[i]}));
            if(characters[i] == ('"').getChars()[0]){
                stringStart = i;
                stringEnd = csvContent.indexOfChar(('"').getChars()[0], i+1);
                data = csvContent.substring(stringStart+1, stringEnd);
                data = data.replace('<DQUOTE>', '"');
                row.add(data);
                system.debug(data +' quotes' + string.fromCharArray(new list<integer>{characters[stringEnd+1]}));
                i = stringEnd+1;
            }else if(characters[i] == ('\r').getChars()[0] || characters[i] == ('\n').getChars()[0]){
                if(parsedCsv.size() > 0 && row.size() == parsedCsv.get(0).size()-1){
                    row.add(null);
                }else if(row.size() == 0){
                    continue;
                }
                parsedCsv.add(row);
                system.debug(row +' cariage return' + string.fromCharArray(new list<integer>{characters[i]}));
                row = new List<String>();
            }else{
                stringStart = i;
                stringEnd = csvContent.indexOfChar((',').getChars()[0], i);
                if(stringEnd == -1){
                    stringEnd = characters.size();
                }
                data = csvContent.substring(stringStart, stringEnd);
                if(data.contains('\r\n')){
                    stringEnd = csvContent.indexOfChar(('\r').getChars()[0], i+1);
                    data = csvContent.substring(stringStart, stringEnd);
                }
                data = data.replace('<DQUOTE>', '"');
               if(data == ''){
                   data = null;
               }
                row.add(data);
                system.debug(data +' simple' + string.fromCharArray(new list<integer>{characters[stringEnd-1]}));
                i = stringEnd;
            }

        }
        parsedCsv.add(row);
        System.debug(parsedCsv);
        parsedCsv.remove(0);

        return parsedCsv;
    }
}