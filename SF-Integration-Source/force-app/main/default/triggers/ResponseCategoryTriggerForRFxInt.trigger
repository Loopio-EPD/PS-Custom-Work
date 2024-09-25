trigger ResponseCategoryTriggerForRFxInt on avnio__ResponseCategory__c (after delete) {
	RFxIntegrationTriggerController.createDeleteLogs(Trigger.old);
}