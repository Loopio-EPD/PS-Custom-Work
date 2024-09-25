trigger ResponseTriggerForRFxInt on avnio__Response__c (after delete) {
	RFxIntegrationTriggerController.createDeleteLogs(Trigger.old);
}