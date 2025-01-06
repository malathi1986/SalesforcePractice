@isTest
private class AlertControllerTest {
  @TestSetup
  static void makeTestData() {
    Account acc = new Account(Name = 'TestAccountRecords', AnnualRevenue = 100);
    insert acc;
 
    List<Asset> assetRecord = new List<Asset>();
    Asset asset1 = new Asset(
      Name = 'Test Asset1',
      AccountId = acc.Id,
      Credit_Card_Number__c = '343455567778889'
    );
    assetRecord.add(asset1) ;

    Asset asset2 = new Asset(
      Name = 'Test Asset2',
      AccountId = acc.Id,
      Credit_Card_Number__c = '343455567779000'
    );
    assetRecord.add(asset2) ;
    insert assetRecord;


    List<Alert__c> alerts = new List<Alert__c>();

    Alert__c alertRecord = new Alert__c(
      AlertName__c = 'TestAlert',
      AlertDate__c = System.today(),
      Alert_Type__c = 'declinedTransaction',
      EmailRecipients__c = 'malathi@gmail.com',
      Merchant_Type__c = 'online',
      Notes__c = '',
      Transcation_Type__c = 'purchases',
      creditCardNumber__c = asset1.Credit_Card_Number__c
    );
    alerts.add(alertRecord);

    Alert__c alertRecord2 = new Alert__c(
      AlertName__c = 'TestAlert1',
      AlertDate__c = System.today() + 8,
      Alert_Type__c = 'declinedTransaction',
      EmailRecipients__c = 'malathi@gmail.com',
      Merchant_Type__c = 'online',
      Notes__c = '',
      Transcation_Type__c = 'purchases',
      creditCardNumber__c = asset1.Credit_Card_Number__c
    );
    alerts.add(alertRecord2);

    Alert__c expiredAlertRecord = new Alert__c(
      AlertName__c = 'TestAlert',
      AlertDate__c = System.today() - 3,
      Alert_Type__c = 'declinedTransaction',
      EmailRecipients__c = 'malathi@gmail.com',
      Merchant_Type__c = 'online',
      Notes__c = '',
      Transcation_Type__c = 'purchases',
      creditCardNumber__c = asset1.Credit_Card_Number__c
    );
    alerts.add(expiredAlertRecord);

    Alert__c expiredAlertRecord1 = new Alert__c(
      AlertName__c = 'TestAlert',
      AlertDate__c = System.today() - 3,
      Alert_Type__c = 'declinedTransaction',
      EmailRecipients__c = 'malathi@gmail.com',
      Merchant_Type__c = 'online',
      Notes__c = '',
      Transcation_Type__c = 'purchases',
      creditCardNumber__c = asset1.Credit_Card_Number__c
    );
    alerts.add(expiredAlertRecord1);

    insert alerts;

    List<Notification__c> notifications = new List<Notification__c>();
    Notification__c notification1 = new Notification__c(
      Account__c = acc.Id,
      Amount__c = '3000',
      TransactionType__c = 'Declined',
      CardNumber__c = Decimal.valueOf(asset1.Credit_Card_Number__c),
      CreatedDate = System.today() - 20
    );
    
    notifications.add(notification1);

   
    Notification__c notification2 = new Notification__c(
      Account__c = acc.Id,
      Amount__c = '3000',
      TransactionType__c = 'Approved',
      CardNumber__c = Decimal.valueOf(asset1.Credit_Card_Number__c),
      CreatedDate = System.today() - 20
    );

    notifications.add(notification2);

    Notification__c notification3 = new Notification__c(
      Account__c = acc.Id,
      Amount__c = '3000',
      TransactionType__c = 'Approved',
      CardNumber__c = Decimal.valueOf(asset2.Credit_Card_Number__c),
      CreatedDate = System.today() - 50
    );

    notifications.add(notification3);
    
    Notification__c notification4 = new Notification__c(
      Account__c = acc.Id,
      Amount__c = '3000',
      TransactionType__c = 'Declined',
      CardNumber__c = Decimal.valueOf(asset1.Credit_Card_Number__c),
      CreatedDate = System.today() - 50
    );
    notifications.add(notification4);

    Notification__c notification5 = new Notification__c(
      Account__c = acc.Id,
      Amount__c = '3000',
      TransactionType__c = 'Declined',
      CardNumber__c = Decimal.valueOf(asset1.Credit_Card_Number__c),
      CreatedDate = System.today() - 70
    );
    notifications.add(notification5);

    insert notifications;
    notifications = [
      SELECT Id, TransactionType__c, CreatedDate, CardNumber__c
      FROM Notification__c
    ];
    System.debug(LoggingLevel.INFO, 'notifications ' + notifications);
  }
  @isTest
  static void test_getAssetNames() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];
      Map<String, String> creditCardNumberMap = AlertController.getAssetNames(
        accId.Id
      );
      System.assertEquals(
        'Test Asset1',
        creditCardNumberMap.get('343455567778889')
      );
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }

  @isTest
  static void test_insertAlertRecord() {
    try {
      String inputString = '{"alert":{"AlertName__c":"UnitTest002","Alert_Type__c":"largePurchase","Transcation_Type__c":"sales","Merchant_Type__c":"all","Amount__c":"3000","AlertDate__c":"2025-02-08","EmailRecipients__c":"malathinirmal@gmail.com"},"creditCardNumbers":["343455567778890","343455567778892"]}';
      Test.startTest();
      Alert__c listOfInsertedAlertRecord = AlertController.insertAlertRecord(
        inputString
      );
      List<String> creditCards = new List<String>{
        '343455567778890',
        '343455567778892'
      };
      List<Alert__c> createdAlerts = [
        SELECT Id
        FROM Alert__c
        WHERE creditCardNumber__c IN :creditCards
      ];
      system.assertequals(2, createdAlerts.size());

      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }
  @isTest
  static void getSpendActivityRecords_30daysDeclinedCardNumber_OneNotificationsReturned() {
    try {
      /*{
      "recordId": "0016R00003PDSbpQAH",
      "view": "Aggregated",
      "transactionType": "declined",
      "amount": "3000",
      "timeFrame": "30"
    }*/
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];

      String inputString =
        '{"recordId":"' +
        accId.Id +
        '","view":"343455567778889","transactionType":"declined","amount":"3000","timeFrame":"30"}';
      List<Notification__c> listOfspendActivityRecords = AlertController.getSpendActivityRecords(
        inputString
      );
      System.assertEquals(1, listOfspendActivityRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }
  @isTest
  static void getSpendActivityRecords_30daysApprovedCardNumber_OneNotificationsReturned() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];

      String inputString = '{"recordId":"' + accId.Id +'","view":"343455567778889","transactionType":"approved","amount":"3000","timeFrame":"30"}';
      List<Notification__c> listOfspendActivityRecords = AlertController.getSpendActivityRecords(
        inputString
      );
      System.assertEquals(1, listOfspendActivityRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }

  @isTest
  static void getSpendActivityRecords_30daysApprovedOrDeclinedCardNumber_TwoNotificationsReturned() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];

      String inputString = '{"recordId":"' + accId.Id +'","view":"343455567778889","transactionType":"Approved or Declined ","amount":"3000","timeFrame":"30"}';
      List<Notification__c> listOfspendActivityRecords = AlertController.getSpendActivityRecords(
        inputString
      );
      System.assertEquals(2, listOfspendActivityRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }

  @isTest
  static void getSpendActivityRecords_30daysApprovedOrDeclinedAggregatedView_TwoNotificationsReturned() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];

      String inputString = '{"recordId":"' + accId.Id +'","view":"Aggregated","transactionType":"Approved or Declined","amount":"3000","timeFrame":"30"}';
      List<Notification__c> listOfspendActivityRecords = AlertController.getSpendActivityRecords(
        inputString
      );
      System.assertEquals(2, listOfspendActivityRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }

  @isTest
  static void getSpendActivityRecords_60daysApprovedCardNumber_OneNotificationsReturned() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];

      String inputString = '{"recordId":"' + accId.Id +'","view":"343455567779000","transactionType":"approved","amount":"3000","timeFrame":"60"}';
      List<Notification__c> listOfspendActivityRecords = AlertController.getSpendActivityRecords(
        inputString
      );
      System.assertEquals(1, listOfspendActivityRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }

  @isTest
  static void getSpendActivityRecords_60daysDeclinedCardNumber_TwoNotificationsReturned() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];

      String inputString = '{"recordId":"' + accId.Id +'","view":"343455567778889","transactionType":"declined","amount":"3000","timeFrame":"60"}';
      List<Notification__c> listOfspendActivityRecords = AlertController.getSpendActivityRecords(
        inputString
      );
      System.assertEquals(2, listOfspendActivityRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }

  @isTest
  static void getSpendActivityRecords_90daysDeclinedCardNumber_TwoNotificationsReturned() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];

      String inputString = '{"recordId":"' + accId.Id +'","view":"343455567778889","transactionType":"declined","amount":"3000","timeFrame":"90"}';
      List<Notification__c> listOfspendActivityRecords = AlertController.getSpendActivityRecords(
        inputString
      );
      System.assertEquals(3, listOfspendActivityRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }


  @isTest
  static void test_getActiveAlertRecords() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];
      List<Alert__c> listOfactiveRecords = AlertController.getActiveAlertRecords(
        accId.Id
      );
      System.assertEquals(2, listOfactiveRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }

  @isTest
  static void test_getExpiredAlertRecords() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];

      List<Alert__c> listOfexpiredRecords = AlertController.getExpiredAlertRecords(
        accId.Id
      );

      System.assertequals(2, listOfexpiredRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }
  @isTest
  static void test_getAssetRecords() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];
      List<Asset> listOfAssetRecords = AlertController.getAssetRecords(
        accId.Id
      );
      System.assertequals(2, listOfAssetRecords.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }
  @isTest
  static void test_getNotificationRecords() {
    try {
      Test.startTest();
      Account accId = [
        SELECT Id
        FROM Account
        WHERE Name = 'TestAccountRecords'
        LIMIT 1
      ];
      Account acc = AlertController.getNotificationRecords(accId.Id);
      List<Notification__c> notifications = acc.Notifications__r;
      system.assertequals(5, notifications.size());
      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }
  @isTest
  static void test_sendEmailToSubscribers() {
    try {
      Test.startTest();
      Alert__c alertRecord = [
        SELECT AlertName__c, EmailRecipients__c
        FROM Alert__c
        WHERE AlertName__c = 'TestAlert1'
        LIMIT 1
      ];
      AlertController.sendEmailToSubscribers(alertRecord);
      Integer invocations = Limits.getEmailInvocations();
      Test.stopTest();
      system.assertEquals(1, invocations, 'An email should be sent');
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }
}
