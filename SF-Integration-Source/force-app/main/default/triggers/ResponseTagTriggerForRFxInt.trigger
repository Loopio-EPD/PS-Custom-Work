trigger ResponseTagTriggerForRFxInt on avnio__ResponseTag__c (after delete) {
	RFxIntegrationTriggerController.createDeleteLogs(Trigger.old);
}