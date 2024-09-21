public with sharing class OpportunityTriggerHandler {

    /*Close Date Validation: Opportunities cannot have a Close Date in the past. If an Opportunity’s Close Date is in the past, display an error message stating, 
    “Opportunity cannot have a Close Date in the past.”*/
    public static void beforeUpdateValidation(List<Opportunity> oppsList,Map<Id,Opportunity> oldOpps){
        for(Opportunity opp:oppsList){
            if(opp.CloseDate < Date.today()){
                opp.addError('Opportunity cannot have a Close Date in the past');
            }
   /*Stage Transition Lock: Opportunities cannot move from “Prospecting” directly to “Closed Won.” If an Opportunity tries to make this transition, show an error message saying, 
   “Opportunity cannot transition directly from Prospecting to Closed Won.”*/
            if(opp.StageName=='Closed Won' && oldOpps.get(opp.Id).StageName=='Prospecting'){
                opp.addError('Opportunity cannot transition directly from Prospecting to Closed Won');

            }
      /*Minimum Amount for “Closed Won”: Opportunities in the “Closed Won” 
      stage must have an Amount greater than or equal to $10,000.*/
      if (opp.StageName == 'Closed Won' && opp.Amount < 10000) {
        opp.addError('Opportunity in Closed Won stage must have an Amount greater than or equal to amount 10,000.');
    }   


        }

    }

    /*Write an Apex trigger named “OpportunityTrigger” that automatically updates a custom field named “TotalOpportunityAmount” on the 
    Account object whenever an Opportunity related to that Account is closed/won.*/
    public static void afterUpdate(List<Opportunity> oppsList){
        Set<Id> acctIds=new Set<Id>();
        for(Opportunity opp:oppsList){
            acctIds.add(opp.AccountId);
        List<Account> accountsToUpdate = [SELECT Id,(SELECT Amount, StageName FROM Opportunities 
                                          WHERE StageName = 'Closed Won')
                                          FROM Account WHERE Id IN :acctIds];
        for(Account acc:accountsToUpdate){
            Decimal totalAmount = 0;
            for (Opportunity opportunity : acc.Opportunities) {
                if (opportunity.StageName == 'Closed Won') {
                    totalAmount = totalAmount+opportunity.Amount;
                }
            }
            acc.TotalOppAmount__c = totalAmount;
        }

        update accountsToUpdate;
                
        }

    }


}