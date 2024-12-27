@RestResource(urlMapping='/realtime/notification/*')
global with sharing class RealTimeSpendNotificationService {
  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String request = req.requestBody.toString();
    System.debug('Incoming Request====>' + request);
    Map<String, Object> transactionRequest = (Map<String, Object>) JSON.deserializeUntyped(
      request
    );
    String creditCardObj = String.valueof(transactionRequest.get('CardNumber'));
    System.debug('CardNumber====>' + creditCardObj);
    String transactionTypeObj = String.valueof(
      transactionRequest.get('TransactionType')
    );
    System.debug('TransactionType====>' + transactionTypeObj);
    /* While typeCasting to decimal value ,Decimal.value0f() method can cast only string and not object.
     So convert the object to string and then type cast as below*/
    Decimal amountObj = Decimal.valueof(
      (String) transactionRequest.get('Amount')
    );
    System.debug('Amount====>' + amountObj);

    List<Alert__c> creditCardMatchingAlertRecords = [
      SELECT
        Id,
        Amount__c,
        EmailRecipients__c,
        Merchant_Type__c,
        creditCardNumber__c,
        Transcation_Type__c
      FROM Alert__c
      WHERE
        creditCardNumber__c = :creditCardObj
        AND Transcation_Type__c = :transactionTypeObj
        AND Amount__c <= :amountObj
    ];
    System.debug('Matched Records===>' + creditCardMatchingAlertRecords);
    Asset assetRecord;
    try {
      assetRecord = [
        SELECT AccountId, Credit_Card_Number__c
        FROM Asset
        WHERE Credit_Card_Number__c = :creditCardObj
        LIMIT 1
      ];
    } catch (Exception e) {
      System.debug('List has no rows for assignment---' + e.getMessage());
    }
    try {
      if (creditCardMatchingAlertRecords.size() > 0) {
        Notification__c notification = new Notification__c(
          Account__c = assetRecord.AccountId,
          CardNumber__c = decimal.valueOf(assetRecord.Credit_Card_Number__c)
        );
        insert notification;
        System.debug('Notification Record Created' + notification.Id);
        res.statusCode = 200;
        String responseString = '{"responseCode":"200", "result" : "Notification Created Successfully"}';
        res.responseBody = Blob.valueOf(responseString);
      }
    } catch (Exception e) {
      res.statusCode = 500;
      res.responseBody = Blob.valueOf(JSON.serialize(e.getMessage()));
    }
  }
  /**
 * 
 * {
  "account_number": "",
  "notifications": [
    {
      "amount": "",
      "transaction_type": "",
      "transaction_date": ""
    }
  ]
}
  */
  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
   
    String AccNumber = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );
    System.debug('AccountNumber====>' + AccNumber);
    Account result = [
      SELECT
        Id,
        AccountNumber,
        (
          SELECT ID, Createddate,TransactionType__c, Amount__c, CardNumber__c
          FROM Notifications__r
        )
      FROM Account
      WHERE AccountNumber = :AccNumber
      LIMIT 1
    ];
    System.debug('Result===>' + result);
    JSONGenerator gen = JSON.createGenerator(true);

    List<Notification__c> notifications = result.Notifications__r;
    List<notifications> notificationsList = new List<notifications>();

    for(Notification__c notification:notifications){
      notifications noti = new notifications();
      noti.amount=notification.Amount__c;
      noti.transaction_type=notification.TransactionType__c;
      noti.transaction_date=String.valueOf(notification.createddate);
      notificationsList.add(noti);
    }
    gen.writeStartObject();
    gen.writeStringField('account_number', result.AccountNumber);
    gen.writeObjectField('notifications', notifications);
    gen.writeEndObject();
    String pretty = gen.getAsString();
    res.responseBody = Blob.valueOf(responseString);

    //return result;
  }
  class notifications{
    public String amount;
    public String transaction_type;
    public String transaction_date;
  }
}
