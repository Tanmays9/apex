function checkOP(that){
         
                var check = document.getElementsByClassName("checks");
                var option = that.checked;
                var point = 0;
				
                   if(option){
                       for(var i = 0; i< check.length ;i++){
                       		(document.getElementsByClassName("checks")[i].checked)? point++:point--;
                       }
                       if(point == check.length){
                       		document.getElementsByClassName("selectAll")[0].checked = option;
                       }
                       
                   } else{
                       for(var i = 0; i< check.length ;i++){
                   		(document.getElementsByClassName("checks")[i].checked)? point++:point--;
                           }
                       if(point == check.length-2){
                       		document.getElementsByClassName("selectAll")[0].checked = option;

                       }
                   }
    
                }
			function checkPage(){
                var check = document.getElementsByClassName("checks");
                var point = 0;
    			for(var i = 0; i< check.length ;i++){
                       		(document.getElementsByClassName("checks")[i].checked)? point++:point--;
                       }
                       if(point == check.length){
                       		document.getElementsByClassName("selectAll")[0].checked = true;
                       }else{
                           document.getElementsByClassName("selectAll")[0].checked = false;
                       }
					}
               
        
            function selectAll(that,nameofclass){
                var check = document.getElementsByClassName(nameofclass);
                if(that.checked){
                    
                    for(var i = 0 ; i< check.length ; i++){
                        document.getElementsByClassName("checks")[i].checked = true;
                    }
                }else{
                    for(var i = 0 ; i< check.length ; i++){
                        document.getElementsByClassName("checks")[i].checked = false;
                    }
                }
                addWrapperToMap();
            }

            function pagenochange(ev){
                jQuery('[id$=Hinput]').val(jQuery('#inputno').val());
                if(ev.charCode >= 48 && ev.charCode<=57 || ev.charCode ==13){
                    if(ev.charCode == 13){
                        pageNoChanged();
                        return false;
                    }
                }else{
                    return false;
                }
                return true;

            }

            function downloadCsv( inputer, filename){
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(inputer);
                hiddenElement.target = '_blank';
                hiddenElement.download = filename + ' RECORDS.csv';
                hiddenElement.click();
            }
            function confirmationMessage(){
                var retVal = confirm("Are you sure?");
                if( retVal == true ) {
                    singledelete();
                  return true;
               }
            }
            function confirmationMessageMass(){
                var retVal = confirm("Are you sure?");
                if( retVal == true ) {
                    deleteSelected();
                  return true;
               }
            }
    