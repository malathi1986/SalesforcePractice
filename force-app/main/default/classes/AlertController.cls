public with sharing class AlertController {
    public AlertController() {

    }
    @AuraEnabled(cacheable=false)
    public static String insertAlertRecord(String alert){
       try{
        Alert__c alertRecord = (Alert__c)JSON.deserialize(
                alert, Alert__c.class);

       /* Map<String, Object> alertObject = (Map<String, Object>) JSON.deserializeUntyped(alert);
        System.debug('Alert_Type: ' + alertObject.get('Alert_Type__c'));  
        Alert__c alertObj=new Alert__c();
        alertObj.Alert_Type__c=(String)alertObject.get('Alert_Type__c');*/
        insert alertRecord;
        }
        
        catch(Exception e){
            System.debug('Record insertion is unsuccessful=====>'+e.getMessage());
        }
        return alert;
    }

}