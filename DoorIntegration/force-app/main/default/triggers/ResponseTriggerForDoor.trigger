trigger ResponseTriggerForDoor on avnio__Response__c (before insert, before update, after insert, after update) {
	if(Trigger.isBefore){
		if(Trigger.isInsert){
			ResponseTriggerForDoorController.beforeInsertAction(Trigger.new);
        }
        if(Trigger.isUpdate){
			ResponseTriggerForDoorController.beforeUpdateAction(Trigger.oldMap, Trigger.new);
        }
	}
	if(Trigger.isAfter){
		ResponseTriggerForDoorController.afterAction(Trigger.new);
	}
}