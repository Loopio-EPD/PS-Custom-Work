({
	saveRecordHelper : function(component,event,helper) {
		var finalFieldReference = component.get("v.finalFieldReference");
		var keyWord = component.get("v.keyWord");
		var staticvalue = component.get("v.staticvalue");
		var action = component.get("c.upsertRecord");
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
        action.setParams({
            mergeField : finalFieldReference,
            keyWord : keyWord,
			value : staticvalue
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				component.set("v.showSpinner", false);
				if(response && response.getReturnValue() && response.getReturnValue().status === 'success' && response.getReturnValue().recordId){
					if(component.get("v.saveAndNew")){
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							title: "Success!",
							message: "Record created succesfully.",
							type: "success"
						});
						toastEvent.fire();
						component.set("v.saveAndNew",false);
						$A.get('e.force:refreshView').fire();
					}
					else{
						component.set("v.saveAndNew",false);
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							title: "Success!",
							message: "Record created succesfully.",
							type: "success"
						});
						toastEvent.fire();
						component.find("navigation").navigate({
							"type" : "standard__recordPage",
							"attributes": {
								"recordId"      : response.getReturnValue().recordId,
								"actionName"    : "view"
							}
						}, true);
					}
				}
				else{
					component.set("v.saveAndNew",false);
					var errorMessage = "Something went wrong. Please try again later.";
					if(response && response.getReturnValue() && response.getReturnValue().status === 'error' && response.getReturnValue().errorMessage){
						errorMessage = response.getReturnValue().errorMessage
					}
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: "Error!",
						message: errorMessage,
						type: "error"
					});
					toastEvent.fire();
				} 
            }
            else{
				component.set("v.showSpinner", false);
				component.set("v.saveAndNew",false);
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Error!",
					message: "Something went wrong. Please try again later.",
					type: "error"
				});
				toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
})