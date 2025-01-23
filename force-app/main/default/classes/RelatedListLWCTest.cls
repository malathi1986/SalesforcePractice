
@isTest
private class RelatedListLWCTest {

        @TestSetup
        static void makeTestData() {
          Account acc = new Account(Name = 'TestRelatedListAccountRecords', AnnualRevenue = 100);
          insert acc;

          Contact con=new Contact(FirstName='Malathi',LastName='Subramaniyam',Phone='480-543-9999',AccountId = acc.Id);
          insert con;
    }
    @isTest
    static void test_getAssetNames() {
        Account accId = [
            SELECT Id
            FROM Account
            WHERE Name = 'TestRelatedListAccountRecords'
            LIMIT 1
          ];
        String relatedListInputString='{"recordId":"'+accId.Id+'","objectName":"Account","relationshipFieldName":"Contacts","fieldsList":"FirstName,LastName,Phone"}';
      try {
        Test.startTest();
        List<Account> accRecords=RelatedListController.getRelatedList(relatedListInputString);
        System.assertEquals(1, accRecords.size());
        Test.stopTest();
        
      } catch (Exception e) {
        System.debug('Error Message====>' + e.getMessage());
      }
    }
  
}