({
    openFieldSelectorComponenet : function(component) {
        component.set("v.openmodel",true);
    },

    closeBtn : function(component) {
        component.set("v.openmodel", false);
    },

    addMergeFieldApiName : function(component,event) {
        var fieldVal = event.getParam("fieldToAdd");
        if(fieldVal){
            component.set("v.responseMergeRecord.Merge_Field_API_Name__c",fieldVal);
        }
        component.set("v.openmodel", false);
    },

    
	cancelCreation : function(component, helper) {
        window.history.back();
        return false;
	},
    
    updateRecord : function(component, event, helper) {
		var responseMergeRecord = component.get("v.responseMergeRecord");
		var finalFieldReference = responseMergeRecord.Merge_Field_API_Name__c;
		var keyWord = responseMergeRecord.Keyword__c;
		var staticvalue = responseMergeRecord.Value__c;
		var toastEvent = $A.get("e.force:showToast");
		if(keyWord == null || ((finalFieldReference == null || finalFieldReference.trim() == "") && (staticvalue == null || staticvalue.trim() == "")) || keyWord.trim() == ""){
			toastEvent.setParams({
				title: "Error!",
				message: "Please fill the required data (Any one from Merge Field API Name or Value is required along with keyword).",
				type: "error"
			});
			toastEvent.fire();
			return;
		}
		component.set("v.showSpinner", true);
		component.find("forceRecord").saveRecord($A.getCallback(function(saveResult) {
			component.set("v.showSpinner", false);
			if (saveResult.state === "SUCCESS") {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Success!",
					message: "Record updated succesfully.",
					type: "success"
				});
				toastEvent.fire();
	 
				// Navigate back to the record view
				var navigateEvent = $A.get("e.force:navigateToSObject");
				navigateEvent.setParams({ "recordId": component.get('v.recordId') });
				navigateEvent.fire();
			}
			else {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Error!",
					message: saveResult.error,
					type: "error"
				});
				toastEvent.fire();
				// Basic error handling
				component.set('v.recordError',
					'Error: ' + saveResult.state + ', message: ' + JSON.stringify(saveResult.error));
			}
		}));
	}
})