public with sharing class AlertController {
  @AuraEnabled(cacheable=false)
  public static Map<String, String> getAssetNames(String accountId) {
    System.debug(LoggingLevel.INFO, 'recordId =====' + accountId);
    List<Asset> assets = [
      SELECT Id, Name, Credit_Card_Number__c
      FROM Asset
      WHERE AccountId = :accountId
    ];
    Map<String, String> creditCardNumberMap = new Map<String, String>();
    for (Asset assetRecord : assets) {
      creditCardNumberMap.put(
        assetRecord.Credit_Card_Number__c,
        assetRecord.Name
      );
    }
    return creditCardNumberMap;
  }

  @AuraEnabled(cacheable=false)
  public static Alert__c insertAlertRecord(String alert) {
    System.debug(LoggingLevel.INFO, 'ALERT ---' + JSON.serialize(alert));
    Alert__c alertRecord;
    try {
      List<Alert__c> alerts = new List<Alert__c>();

      Map<String, Object> alertObject = (Map<String, Object>) JSON.deserializeUntyped(
        alert
      );

      Object creditCardObj = alertObject.get('creditCardNumbers');
      List<Object> creditCardNumbers = (List<Object>) creditCardObj;

      for (Object cardNumber : creditCardNumbers) {
        Map<String, Object> alertData = (Map<String, Object>) alertObject.get(
          'alert'
        );
        alertRecord = new Alert__c();

        Set<String> fieldNames = alertData.keySet();

        Map<String, Schema.DescribeFieldResult> fieldTypeInfo = ObjectMetadataUtil.getFieldsType(
          'Alert__c',
          fieldNames
        );

        for (String fieldName : fieldNames) {
          Schema.DescribeFieldResult fieldDesc = fieldTypeInfo.get(fieldName);
          Schema.DisplayType dataType = fieldDesc.getType();
          if (dataType == Schema.DisplayType.STRING) {
            alertRecord.put(fieldName, (String) alertData.get(fieldName));
          }
          if (dataType == Schema.DisplayType.DOUBLE) {
            alertRecord.put(
              fieldName,
              Decimal.valueOf((String) alertData.get(fieldName))
            );
          }
          if (dataType == Schema.DisplayType.DATE) {
            alertRecord.put(
              fieldName,
              Date.valueOf((String) alertData.get(fieldName))
            );
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
  /**
 * { label: 'Id', fieldName: 'Id' },
    { label: 'Account', fieldName: 'Account__c'},
    { label: 'Amount', fieldName: 'Amount__c'},
    { label: 'CardNumber', fieldName: 'CardNumber__c'},
    { label: 'Merchant Type', fieldName: 'Merchant_Type__c'},
    { label: 'CreatedBy', fieldName: 'CreatedById'},
    { label: 'Transaction Type', fieldName: 'Transcation_Type__c'},
 */
  @AuraEnabled(cacheable=false)
  public static List<Notification__c> getSpendActivityRecords(
    String spendActivity
  ) {
    System.debug(
      LoggingLevel.INFO,
      'ALERT ---' + JSON.serialize(spendActivity)
    );
    System.debug(LoggingLevel.INFO, 'inside Apex method===>' + spendActivity);
    Map<String, Object> spendActivityObj = (Map<String, Object>) JSON.deserializeUntyped(
      spendActivity
    );

    String accountId = (String) spendActivityObj.get('recordId');
    String view = (String) spendActivityObj.get('view');
    System.debug('view===>' + view);
    String transaction_type = (String) spendActivityObj.get('transactionType');
    System.debug('transaction_type===>' + transaction_type);
    System.debug('timeframe===>' + spendActivityObj.get('timeFrame'));

    String timeFrame = (String) spendActivityObj.get('timeFrame');
    Integer timeFrameValue;
    Date fromDate;
    Date toDate;
    Map<String, Object> customDateRange = (Map<String, Object>) spendActivityObj.get(
      'customDateRange'
    );
    String specifiedFromDate;
    String specifiedToDate;
    if (timeFrame == 'SpecificDate') {
      specifiedFromDate = (String) customDateRange.get('fromDate');
      specifiedFromDate=specifiedFromDate+'T00:00:00Z';
      specifiedToDate = (String) customDateRange.get('toDate');  
      specifiedToDate=specifiedToDate+'T00:00:00Z';
      System.debug(LoggingLevel.INFO,'specifiedToDate====>'+specifiedToDate);
    }
    else if (timeFrame != 'SpecificDate') {
      timeFrameValue = Integer.valueOf(
        (String) spendActivityObj.get('timeFrame')
      );
    }

    // If view is aggregated, than we need to pull all the transactions from the account.
    // If specific card number is selected, then we need to fetch the transactions related to that card number.

    String amount = (String) spendActivityObj.get('amount');

    String queryResult =
      'SELECT ID, Account__c, Amount__c, TransactionType__c, Createddate ' +
      'FROM Notification__c ' +
      'WHERE ' +
      'Account__c = :accountId ' +
      'AND Amount__c = :amount ';

    if (transaction_type == 'approved' || transaction_type == 'declined') {
      queryResult = queryResult + 'AND TransactionType__c = :transaction_type ';
    }
    if (transaction_type == 'approved or declined') {
      queryResult =
        queryResult +
        'AND ( TransactionType__c = \'approved\' OR TransactionType__c = \'declined\')';
    }

    if (timeFrameValue == 30) {
      queryResult = queryResult + 'AND CreatedDate >= LAST_N_DAYS:30 ';
    }
    if (timeFrameValue == 60) {
      queryResult = queryResult + 'AND CreatedDate >= LAST_N_DAYS:60 ';
    }
    if (timeFrameValue == 90) {
      queryResult = queryResult + 'AND CreatedDate >= LAST_N_DAYS:90 ';
    }
    if (timeFrame == 'SpecificDate') {
      queryResult =
        queryResult +
        'AND CreatedDate >= '+specifiedFromDate+
        ' AND CreatedDate <= '+ specifiedToDate;
    }
    if (view != 'Aggregated') {
      Decimal cardNumber = Decimal.valueOf(view);
      queryResult = queryResult + 'AND CardNumber__c =:cardNumber';
    }
    return Database.query(queryResult);
  }

  @AuraEnabled(cacheable=false)
  public static Account getNotificationRecords(String accountId) {
    return [
      SELECT
        Id,
        AccountNumber,
        (
          SELECT ID, Account__c, Amount__c, CardNumber__c, CreatedById
          FROM Notifications__r
        )
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];
  }

  @AuraEnabled(cacheable=false)
  public static List<Alert__c> getActiveAlertRecords(String accountId) {
    //Account acc=[SELECT ID,(SELECT ID,Credit_Card_Number__c FROM Assets) FROM Account WHERE Id=:accountId];
    List<Asset> associatedAssets = [
      SELECT ID, Credit_Card_Number__c
      FROM Asset
      WHERE AccountId = :accountId
    ];
    //List<Asset> assetList=acc.Assets;
    List<String> creditCardNumbers = new List<String>();
    for (Asset ass : associatedAssets) {
      creditCardNumbers.add(ass.Credit_Card_Number__c);
    }
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
      WHERE AlertDate__c >= Today AND creditCardNumber__c IN :creditCardNumbers
    ];
    System.debug('activeALERTS====>' + activeAlertRecords);
    return activeAlertRecords;
  }

  @AuraEnabled(cacheable=false)
  public static List<Alert__c> getExpiredAlertRecords(String accountId) {
    List<Asset> associatedAssets = [
      SELECT ID, Credit_Card_Number__c
      FROM Asset
      WHERE AccountId = :accountId
    ];
    List<String> creditCardNumbers = new List<String>();
    for (Asset ass : associatedAssets) {
      creditCardNumbers.add(ass.Credit_Card_Number__c);
    }
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
        creditCardNumber__c,
        Transcation_Type__c
      FROM Alert__c
      WHERE AlertDate__c < Today AND creditCardNumber__c IN :creditCardNumbers
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
