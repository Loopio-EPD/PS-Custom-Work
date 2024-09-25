trigger ProjectTriggerForHubspot on avnio__Project__c (after insert, after update, before update) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ProjectTriggerForHubspotController.onInsertProjectBefore(Trigger.new);
        }
        if(Trigger.isUpdate){
            ProjectTriggerForHubspotController.onUpdateProjectBefore(Trigger.oldMap, Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ProjectTriggerForHubspotController.onInsertProjectAfter(Trigger.new);
        }
        if(Trigger.isUpdate){
            ProjectTriggerForHubspotController.onUpdateProjectAfter(Trigger.oldMap, Trigger.new);
        }
    }
}