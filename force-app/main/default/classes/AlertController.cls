public with sharing class AlertController {
  public AlertController() {
  }
  @AuraEnabled(cacheable=false)
  public static Alert__c insertAlertRecord(String alert) {
    Alert__c alertRecord;
    try {
      List<Alert__c> alerts = new List<Alert__c>();

      Map<String, Object> alertObject = (Map<String, Object>) JSON.deserializeUntyped(
        alert
      );

      Object creditCardObj = alertObject.get(
        'creditCardNumbers'
      );
      List<Object> creditCardNumbers = (List<Object>) creditCardObj;

      
      for (Object cardNumber : creditCardNumbers) {
        Map<String, Object> alertData = (Map<String, Object>) alertObject.get(
          'alert'
        );
        alertRecord = new Alert__c();

        Set<String> fieldNames = alertData.keySet();

        Map<String, Schema.DescribeFieldResult> fieldTypeInfo = ObjectMetadataUtil.getFieldsType('Alert__c', fieldNames);

        for (String fieldName : fieldNames) {
          Schema.DescribeFieldResult fieldDesc = fieldTypeInfo.get(fieldName);
          Schema.DisplayType dataType = fieldDesc.getType(); 
          if(dataType == Schema.DisplayType.STRING){
            alertRecord.put(fieldName, (String) alertData.get(fieldName));
          }
          if(dataType == Schema.DisplayType.DOUBLE){
            alertRecord.put(fieldName, Decimal.valueOf((String)alertData.get(fieldName)));
          }
          if(dataType == Schema.DisplayType.DATE){
            alertRecord.put(fieldName, Date.valueOf((String) alertData.get(fieldName)));
          }
        }
        String creditCardNumber = (String) cardNumber;
        alertRecord.creditCardNumber__c = creditCardNumber;
        alerts.add(alertRecord);
      }

      /* Map<String, Object> alertObject = (Map<String, Object>) JSON.deserializeUntyped(alert);
        System.debug('Alert_Type: ' + alertObject.get('Alert_Type__c'));  
        Alert__c alertObj=new Alert__c();
        alertObj.Alert_Type__c=(String)alertObject.get('Alert_Type__c');*/
      insert alerts;
      if (
        alertRecord.EmailRecipients__c != '' &&
        alertRecord.EmailRecipients__c != null
      ) {
        sendEmailToSubscribers(alertRecord);
      }
    } catch (Exception e) {
      System.debug('Record insertion is unsuccessful=====>' + e.getMessage());
    }
    return alertRecord;
  }
  @AuraEnabled(cacheable=false)
  public static List<Alert__c> getActiveAlertRecords() {
    List<Alert__c> activeAlertRecords = [
      SELECT
        Id,
        AlertDate__c,
        AlertName__c,
        Alert_Type__c,
        Amount__c,
        EmailRecipients__c,
        Merchant_Type__c,
        Notes__c,
        Transcation_Type__c
      FROM Alert__c
      WHERE AlertDate__c >= Today
      LIMIT 20
    ];
    system.debug('activeALERTS====>' + activeAlertRecords);
    return activeAlertRecords;
  }

  @AuraEnabled(cacheable=false)
  public static List<Alert__c> getExpiredAlertRecords() {
    List<Alert__c> expiredAlertRecords = [
      SELECT
        Id,
        AlertDate__c,
        AlertName__c,
        Alert_Type__c,
        Amount__c,
        EmailRecipients__c,
        Merchant_Type__c,
        Notes__c,
        Transcation_Type__c
      FROM Alert__c
      WHERE AlertDate__c < Today
    ];
    system.debug('ExpiredALERTS====>' + expiredAlertRecords);
    return expiredAlertRecords;
  }

  @AuraEnabled(cacheable=false)
  public static void sendEmailToSubscribers(Alert__c alert) {
    String emailAddress = alert.EmailRecipients__c;
    String[] toAddresses = emailAddress.split(',');
    system.debug('emailAddress====>' + toAddresses);
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //String[] toAddresses = new String[] {address};
    mail.setToAddresses(toAddresses);
    mail.setSubject('New Alert Created : ' + alert.Id);
    mail.setPlainTextBody('Your Alert: ' + alert.Id + ' has been created.');
    // Pass this email message to the built-in sendEmail method
    // of the Messaging class
    Messaging.SendEmailResult[] results = Messaging.sendEmail(
      new List<Messaging.SingleEmailMessage>{ mail }
    );
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
      } else {
        sendResult = false;
        System.debug('The following errors occurred: ' + res.getErrors());
      }
    }
    return sendResult;
  }
  @AuraEnabled(cacheable=true)
  public static List<Asset> getAssetRecords(String accountId) {
    System.debug(LoggingLevel.INFO, 'accountId ----' + accountId);
    List<Asset> listOfAssetRecords;
    try {
      listOfAssetRecords = [
        SELECT Id, Name, Credit_Card_Number__c
        FROM Asset
        WHERE AccountId = :accountId
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    System.debug(
      LoggingLevel.INFO,
      'listOfAssetRecords ----' + listOfAssetRecords
    );
    return listOfAssetRecords;
  }
}
