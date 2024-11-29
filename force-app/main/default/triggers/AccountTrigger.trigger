trigger AccountTrigger on Account (after insert,after update,before delete,before insert,before update) {
    if((trigger.isAfter)&&(trigger.isInsert)){
       // AccountTriggerHandler.isAfterTrigger(trigger.new );
        AccountTriggerHandler.isAfterUpdateOrInsert(trigger.new);
        
       
    }
    if((trigger.isAfter)&&(trigger.isUpdate)){
         AccountTriggerHandler.isAfterUpdate(trigger.new,trigger.oldMap,trigger.newMap);
         
        
     }
     if((trigger.isbefore)&&(trigger.isUpdate)){
        AccountTriggerHandler.beforeUpdate(trigger.new);
        
    }
    if((trigger.isbefore)&&(trigger.isDelete)){
        AccountTriggerHandler.isBeforeDelete(trigger.old,trigger.oldMap);
        
    }
}