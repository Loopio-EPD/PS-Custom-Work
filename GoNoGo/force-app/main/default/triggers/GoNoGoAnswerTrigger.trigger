trigger GoNoGoAnswerTrigger on Go_No_Go_Answer__c (after update) {
	GoNoGoAnswerTriggerController.sendForApproval(Trigger.new);
}