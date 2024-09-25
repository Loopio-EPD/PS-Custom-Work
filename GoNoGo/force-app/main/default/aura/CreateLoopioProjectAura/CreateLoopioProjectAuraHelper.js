({
	closeQA : function(component, event, helper) { 
		$A.get("e.force:closeQuickAction").fire(); 
		$A.get("e.force:refreshView").fire(); 
	},

	createLFSProjectWithoutRecordType : function(component, event, helper) { 
		var recordId = component.get("v.recordId");
		var opportunityId = component.get("v.opportunityId");
		var accountId = component.get("v.accountId");
		var defaultFieldValues = {};
		defaultFieldValues.Opportunity__c = opportunityId;
		defaultFieldValues.Go_No_Go_Submission__c = recordId;
		defaultFieldValues.avnio__AccountId__c = accountId;
		var createRecordEvent = $A.get("e.force:createRecord");
		if (createRecordEvent) {
			createRecordEvent.setParams({
				"entityApiName": 'avnio__Project__c',
				"defaultFieldValues": defaultFieldValues
			});
			createRecordEvent.fire();
		}
	}
})