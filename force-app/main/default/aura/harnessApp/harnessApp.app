<aura:application extends="force:slds">
    <c:server_side_pagination objectName="Account" fieldsList="Name,AnnualRevenue,Description,Phone"/>
    <hr/>
    <c:client_side_pagination/> 
    
</aura:application>