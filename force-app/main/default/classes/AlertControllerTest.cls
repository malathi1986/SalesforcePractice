@isTest
private class AlertControllerTest {
    @TestSetup
    static void makeTestData(){
        Alert__c alertRecord = new Alert__c(
            AlertName__c = 'TestAlert',
            AlertDate__c = System.today(),
            Alert_Type__c = 'declinedTransaction',
            //Amount__c = 3000.0,
            EmailRecipients__c = 'malathi@gmail.com',
            Merchant_Type__c = 'online',
            Notes__c = '',
            Transcation_Type__c = 'purchases' 
          );
          insert alertRecord; 
    }
  @isTest
  static void test_insertAlertRecord() {
    try {
      String inputString =
        '{"AlertName__c":"TestAlertRecord","Alert_Type__c":"declinedTransaction","Amount__c":30000.0,' +
        '"EmailRecipients__c":"malathi@gmail.com",' +
        '"Merchant_Type__c":"online",' +
        '"Notes__c":"",' +
        '"Transcation_Type__c":"purchases"}';
      Test.startTest();
      AlertController.insertAlertRecord(inputString);
      List<Alert__c> listOfInsertedAlertRecord = [
        SELECT
          AlertName__c,
          Alert_Type__c,
          //Amount__c,
          EmailRecipients__c,
          Id,
          Merchant_Type__c,
          Notes__c,
          Transcation_Type__c
        FROM Alert__c WHERE AlertName__c='TestAlertRecord'
      ];
      system.assertequals(1, listOfInsertedAlertRecord.size());

      Test.stopTest();
    } catch (Exception e) {
      System.debug('Error Message====>' + e.getMessage());
    }
  }
  @isTest
  static void test_getActiveAlertRecords() {
    try{
    Test.startTest();
    AlertController.getActiveAlertRecords();
    List<Alert__c> listOfactiveRecords = [
      SELECT
        Id,
        AlertDate__c,
        AlertName__c,
        Alert_Type__c,
        //Amount__c,
        EmailRecipients__c,
        Merchant_Type__c,
        Notes__c,
        Transcation_Type__c
      FROM Alert__c
      WHERE AlertDate__c >= Today
    ];
    system.assertequals(1,listOfactiveRecords.size());
    Test.stopTest();
    }
    catch (Exception e) {
        System.debug('Error Message====>' + e.getMessage());
      }
  }
  @isTest
  static void test_getExpiredAlertRecords() {
    try{
    Test.startTest();
    AlertController.getExpiredAlertRecords();
    List<Alert__c> listOfexpiredRecords = [
      SELECT
        Id,
        AlertDate__c,
        AlertName__c,
        Alert_Type__c,
        //Amount__c,
        EmailRecipients__c,
        Merchant_Type__c,
        Notes__c,
        Transcation_Type__c
      FROM Alert__c
      WHERE AlertDate__c < Today 
    ];
    system.assertequals(0, listOfexpiredRecords.size());
    Test.stopTest();
    }
    catch (Exception e) {
        System.debug('Error Message====>' + e.getMessage());
      }
  }
}
