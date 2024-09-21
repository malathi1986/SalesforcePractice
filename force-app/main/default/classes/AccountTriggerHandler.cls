public with sharing class AccountTriggerHandler {
   /*Write a trigger, when a new Account is created then create a contact related to that account.*/ 
  /*  public static void isAfterTrigger(List<Account> newAccounts) {
        List<Contact> conList=new List<Contact>();
        for(Account acc:newAccounts){
            Contact con=new Contact(LastName=acc.name,AccountId=acc.Id);
            conList.add(con);
        } 
        insert conList;       
        }
        */


        /*Write a trigger, if the owner of an account is changed then the owner 
        for the related contacts should also be updated.*/

        public static void isAfterUpdate(List<Account> newAccounts,Map<Id,Account> oldAccountMap,Map<Id,Account> newAccountMap) {
            List<Id> accIds=new List<Id>();
            for(Account acc:newAccounts){
                if(acc.OwnerId!=oldAccountMap.get(acc.Id).OwnerId){
                    accIds.add(acc.Id);
                }
            }
            if(accIds.size()!=0){
              List<Contact> relatedContacts=[SELECT Id,OwnerId,AccountId from Contact WHERE AccountId IN:accIds];
              for(Contact con:relatedContacts){
                con.OwnerId=newAccountMap.get(con.AccountId).OwnerId;
              }
              update relatedContacts;

            }

    }

    /*Write a trigger, to achieve the following:

Create a new Opportunity whenever an account is created/updated for Industry – Agriculture.
Opportunity should be set as below:
Stage = ‘Prospecting’, Amount = $0, CloseDate = ’90 days from today’.*/
public static void isAfterUpdateOrInsert(List<Account> newAccounts){
    List<Opportunity> oppList = new List<Opportunity>();
    System.debug('List of new accounts===>'+newAccounts);
  for(Account acc:newAccounts){
    System.debug('Account====>'+acc);
    if(acc.Industry=='Agriculture'){
        Opportunity newOpp=new Opportunity(Name = acc.Name+' Opp',
                                           AccountId = acc.Id,
                                           StageName = 'Prospecting', 
                                           Amount = 0, 
                                           CloseDate = System.today() + 90);
                                           
                                           
                                           
                                           
        oppList.add(newOpp);
    } 
    
    }
    if(oppList.isEmpty()==false){
        insert oppList;
      
  }
}

/*Given: There is any associated Contact to an Account,

 When: User tries to delete the Account,

 Then: User should get the error that Account with associated Contact can not be deleted.*/

 public static void isBeforeDelete(List<Account> oldAccounts,Map<Id,Account> oldAccountMap){
    Map<Id,Account> accWithRelatedContacts=new Map<Id,Account>([SELECT Id,(SELECT Id from Contacts) 
                                                                FROM Account WHERE 
                                                                Id IN:oldAccountMap.Keyset()]);
                  for(Account acc:oldAccounts) 
                  {
                   if(!accWithRelatedContacts.get(acc.Id).contacts.isEmpty()) 
                   acc.addError('Account with Related Contact(s) can not be deleted.');
                  }                      

}

/*when Account status changes from "Prospect" to Customer,all its related opportunities 
should be closed-won if not thow an error as"You have opportunities to close"*/
public static void beforeUpdate(List<Account> accList){
    Set<Id> acctIds=new Set<Id>();
    for(Account acc:accList){
        acctIds.add(acc.Id);
    }
    Map<Id,Account> accwithRelatedOpp=new Map<Id,Account>([SELECT Id,Type,(SELECT Id,StageName FROM Opportunities 
                                         WHERE StageName !='Closed Won')
                                         FROM Account WHERE Id IN :acctIds]);
    /*List<Account> accwithRelatedOpp = [SELECT Id,Type,(SELECT Id,StageName FROM Opportunities 
                                          WHERE StageName !='Closed Won' OR 'Closed Lost')
                                          FROM Account WHERE Id IN :acctIds];*/
   
   for(Account a:accList){
    if(a.Type=='Customer - Direct'){
      // List<Opportunity> opp= accwithRelatedOpp.get(a.Id).opportunities;
      System.debug('Opportinies---->'+accwithRelatedOpp.get(a.Id).opportunities);
       if(!accwithRelatedOpp.get(a.Id).opportunities.isEmpty()) {
        a.addError('Account Type cannot be changed to customer when Related opportunity stage is not closed.');

       }  
       }     
     }                                 

   }
         
}