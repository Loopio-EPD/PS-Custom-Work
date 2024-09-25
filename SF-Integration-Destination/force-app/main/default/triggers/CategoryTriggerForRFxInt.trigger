trigger CategoryTriggerForRFxInt on avnio__Category__c (before delete) {
	Set<Id> recordIds = Trigger.oldMap.keySet();
	List<RFX_Integration_Log__c> logs = [select id, Category__c from RFX_Integration_Log__c where Category__c IN : recordIds];
    if(logs != null && logs.size() > 0){
        delete logs;
    }
}