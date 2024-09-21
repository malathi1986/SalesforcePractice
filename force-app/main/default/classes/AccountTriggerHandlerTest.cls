/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountTriggerHandlerTest {

    @TestSetup
    static void dataSetUp() {
        // TO DO: implement unit test
        Profile salesProfile = [SELECT Name FROM Profile WHERE Name='Sales'];
        User user1= new User(LastName='Sub',Alias='sysAdmin',Email='malathi2@gmail.com',Username='malathi2@gmail.com',ProfileId=salesProfile.Id,

        emailencodingkey='UTF-8',
        
        languagelocalekey='en_US',
        
        localesidkey='en_US',
        TimeZoneSidKey='America/Los_Angeles');
        
         insert user1;

        Account acc1 = new Account(Name='TestAccount1',Type='Prospect');
        insert acc1;
       
         Account acc3 = new Account(Name='TestAccount3',Industry='Agriculture');
         insert acc3;
        Opportunity opp = new Opportunity(Name = 'TestOpportunity1', StageName = 'Prospecting',
                                         Amount = 2000, AccountId = acc1.Id,
                                         CloseDate = Date.today().addDays(10));
          insert opp;
         Contact con=new Contact(LastName='TestContact',AccountId = acc1.Id); 
         
         insert con;   
                                   
         
    }
    @isTest
    static void test_accountWithRelatedContacts(){
        List<Account> insertedAccount= [Select Id From Account Where Name='TestAccount1'];
        System.assertEquals(1, insertedAccount.size(), 'List should have only 1 account.');
        try{
            Test.startTest();
            delete insertedAccount;
           Test.stopTest();
        } 
        catch(exception e){
            System.debug('Error Message====>'+e.getMessage());
            //System.assertEquals(true,e.getMessage().contains('Account with Related Contact(s) can not be deleted'));
            System.assertEquals(1, [Select Id From Account Where Name='TestAccount1'].size(), 
            'Account with Related Contact can not be deleted.');
        }


    }
    @isTest
    static void test_accountWithCustomerTypeTest() {
        Account insertedAccount = [Select Id From Account Where Name='TestAccount1' LIMIT 1];
       // System.assertEquals(1, insertedAccount.size(), 'List should have only 1 account.');
        
        try{
            insertedAccount.Type='Customer - Direct';
            Test.startTest();
            update insertedAccount;
            Test.stopTest();
        }
        catch(exception e){
            System.debug('Error Message====>'+e.getMessage());
            System.assertEquals(true,e.getMessage().contains('Account Type cannot be changed to customer when Related opportunity stage is not closed'));
        }
       
    }
    @isTest
    static void test_createOpportunity_whenAccountIndustryFieldisAgriculture(){
        Account newAcc = new Account(Name='TestAccount', Industry='Agriculture');
        
        Test.startTest();
            insert newAcc;
        Test.stopTest();
        List<Opportunity> insertedOpp = [Select Id, Account.Name, CloseDate, Amount 
                                         From Opportunity Where AccountId = :newAcc.Id];
        System.assertEquals(1, insertedOpp.size(), 'Only 1 opportunity should be inserted for the Account');
    }
    @isTest 
    static void test_ownerofAccountChanged_relatedContactrecordOwnerUpdated(){
        Account insertedAccount = [Select Id,OwnerId From Account WHERE Name='TestAccount1' LIMIT 1];
        User salesUser = [SELECT Id FROM User WHERE Email ='malathi2@gmail.com' LIMIT 1];
        insertedAccount.OwnerId = salesUser.Id;
        Test.startTest();
        update insertedAccount;
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT Id,OwnerId FROM Contact WHERE AccountId =:insertedAccount.Id];
        System.assertEquals(true, updatedContacts[0].ownerId == salesUser.Id);
      
    }
}