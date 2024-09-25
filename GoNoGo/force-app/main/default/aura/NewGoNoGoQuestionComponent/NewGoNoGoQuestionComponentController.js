({
    doInit: function (component, event, helper) {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
		if(value){
			var context = JSON.parse(window.atob(value));
            if(context && context.attributes && context.attributes.recordId){
                component.set("v.sectionId", context.attributes.recordId);
                component.set("v.fromsectionrelatedlist",true);
            }
		}
        var action = component.get("c.loadDataForGoNoGoQuestion");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				if(response && response.getReturnValue() && response.getReturnValue().dataTypesOptions && response.getReturnValue().opportunityFields){
					component.set("v.datatypeoptions", response.getReturnValue().dataTypesOptions);
                    component.set("v.opportunityfields", response.getReturnValue().opportunityFields);
                    component.set("v.showSpinner", false);
				}
				else{
					var errorMessage = "Something went wrong. Please try again later.";
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
	},

    saveRecord : function(component, event, helper) {
        component.set("v.saveAndNew", false);
        helper.saveRecordHelper(component,event,helper);
	},

    saveAndNewRecord : function(component, event, helper) {
        component.set("v.saveAndNew", true);
        helper.saveRecordHelper(component,event, helper);
	},

	cancelCreation : function(component, helper) {
        window.history.back();
        return false;
	},
    
    handleDataTypeChange: function (component, event) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.datatype", selectedOptionValue);
        if(!selectedOptionValue || selectedOptionValue != "Salesforce Input"){
            component.set("v.opportuntityFieldAPIName", "");
        }
    },

    handleOpportunityFieldChange: function (component, event) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.opportuntityFieldAPIName", selectedOptionValue);
    },
    
    handlesectionchange: function (component,event){
        var selectedSection = event.getParam('selectedRecId');
        component.set("v.sectionId", selectedSection);
    }
})