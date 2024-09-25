trigger TagTriggerForRFxInt on avnio__Tag__c (before delete) {
	Set<Id> recordIds = Trigger.oldMap.keySet();
	List<RFX_Integration_Log__c> logs = [select id, Tag__c from RFX_Integration_Log__c where Tag__c IN : recordIds];
    if(logs != null && logs.size() > 0){
        delete logs;
    }
}