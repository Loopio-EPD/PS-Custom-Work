trigger OpportunityTrigger on Opportunity (after insert, after update) {
    if(Trigger.isInsert){
        OpportunityTriggerController.afterInsert(Trigger.new);
    }
    if(Trigger.isUpdate){
        OpportunityTriggerController.afterUpdate(Trigger.new,Trigger.oldMap);
    }
}