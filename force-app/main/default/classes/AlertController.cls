public with sharing class AlertController {
    public AlertController() {

    }
    @AuraEnabled(cacheable=false)
    public static Alert__c insertAlertRecord(String alert){
        Alert__c alertRecord;
        try{
            alertRecord = (Alert__c)JSON.deserialize(
                alert, Alert__c.class);

        /* Map<String, Object> alertObject = (Map<String, Object>) JSON.deserializeUntyped(alert);
        System.debug('Alert_Type: ' + alertObject.get('Alert_Type__c'));  
        Alert__c alertObj=new Alert__c();
        alertObj.Alert_Type__c=(String)alertObject.get('Alert_Type__c');*/
        insert alertRecord;
        if(alertRecord.EmailRecipients__c!=''&& alertRecord.EmailRecipients__c!=null){
            sendEmailToSubscribers(alertRecord);
        }
        }
        
        catch(Exception e){
            System.debug('Record insertion is unsuccessful=====>'+e.getMessage());
        }
        return alertRecord;
    }
    @AuraEnabled(cacheable=false)
    public static List<Alert__c> getActiveAlertRecords(){
        List<Alert__c> activeAlertRecords= [SELECT Id,Alert_Type__c,Merchant_Type__c,AlertDate__c FROM Alert__c WHERE AlertDate__c>=Today];
        system.debug('activeALERTS====>'+activeAlertRecords);
        return activeAlertRecords;
    }
            
    @AuraEnabled(cacheable=false)
    public static List<Alert__c> getExpiredAlertRecords(){
        List<Alert__c> expiredAlertRecords= [SELECT Id,Alert_Type__c,Merchant_Type__c,AlertDate__c FROM Alert__c WHERE AlertDate__c<Today];
        system.debug('activeALERTS====>'+expiredAlertRecords);
        return expiredAlertRecords;
    }

    @AuraEnabled(cacheable=false)
    public static void sendEmailToSubscribers(Alert__c alert){
        String emailAddress=alert.EmailRecipients__c;
        String[] toAddresses = emailAddress.split(',');
        system.debug('emailAddress====>'+toAddresses);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {address};
        mail.setToAddresses(toAddresses);
        mail.setSubject('New Alert Created : ' + alert.Id);
        mail.setPlainTextBody('Your Alert: ' + alert.Id +' has been created.');
        // Pass this email message to the built-in sendEmail method 
        // of the Messaging class
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
                                 new Messaging.SingleEmailMessage[] { mail });
        // Call a helper method to inspect the returned results
        inspectResults(results);
    }
    // Helper method
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        // sendEmail returns an array of result objects.
        // Iterate through the list to inspect results. 
        // In this class, the methods send only one email, 
        // so we should have only one result.
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            }
            else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }
        return sendResult;
    
    }

}