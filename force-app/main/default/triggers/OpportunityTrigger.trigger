trigger OpportunityTrigger on Opportunity (before update,after insert,after update) {
    if(Trigger.isbefore&&(Trigger.isInsert||Trigger.isUpdate)){
        OpportunityTriggerHandler.beforeUpdateValidation(Trigger.new,Trigger.oldMap);
        OpportunityTriggerHandler.afterUpdate(Trigger.new);
    }

}