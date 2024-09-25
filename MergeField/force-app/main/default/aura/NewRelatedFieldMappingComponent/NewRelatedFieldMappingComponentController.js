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
            component.set("v.finalFieldReference",fieldVal);
        }
        component.set("v.openmodel", false);
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
	}
})