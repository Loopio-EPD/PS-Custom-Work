({
	doInit : function(component,event,helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.checkIfApproved");
        action.setParams({'answerId' : recordId});
        action.setCallback(this, function(response) {
            var returnVal = response.getReturnValue();
            if(returnVal && returnVal.isSuccess){
                if(returnVal.statuslabel && returnVal.statuslabel == 'Pending'){
                    component.set("v.isPending",true);
                }
                if(returnVal.isLoopioPresent){
                    component.set("v.isLoopioPresent",returnVal.isLoopioPresent);
                }
                if(returnVal.isAvnioPresent){
                    component.set("v.isAvnioPresent",returnVal.isAvnioPresent);
                }
                if(returnVal.recordTypesForLFS && returnVal.recordTypesForLFS.length){
                    component.set("v.recordTypesForLFS",returnVal.recordTypesForLFS);
                    component.set("v.selectedRecordType",returnVal.recordTypesForLFS[0].value);
                }
                else{
                    component.set("v.skipRecordTypeSelection",true);
                }
                if(returnVal.isApproved && returnVal.opportunityId){
                    component.set("v.opportunityId",returnVal.opportunityId);
                    component.set("v.accountId",returnVal.accountId);
                    if(component.get("v.isLoopioPresent") && component.get("v.isAvnioPresent")){
                        var urlToRedirect = "/apex/Loopio__Create_Loopio_Project?id=" + returnVal.opportunityId + "&gonogoid="+ recordId;
                        component.set('v.loopioCreateProjectUrl',urlToRedirect);
                        component.set("v.showProjectTypeSelection",true);
                        component.set("v.isLoopioPresent",true);
                        component.set("v.isAvnioPresent",false);
                    }
                    else if(component.get("v.isLoopioPresent")){
                        var urlToRedirect = "/apex/Loopio__Create_Loopio_Project?id=" + returnVal.opportunityId + "&gonogoid="+ recordId;
                        //var urlToRedirect = "/apex/Create_Loopio_Custom?id=" + returnVal.opportunityId + "&gonogoid="+ recordId;
                        component.set('v.loopioCreateProjectUrl',urlToRedirect);
                        component.set("v.showSpinner",false);
                        //window.open(urlToRedirect,'_self');
                        //helper.closeQA(component,event,helper);
                    }
                    else if(component.get("v.isAvnioPresent")){
                        if(component.get("v.skipRecordTypeSelection")){
                            helper.createLFSProjectWithoutRecordType(component, event, helper);
                        }
                        else{
                            component.set("v.showRecordTypeSelectionForLFS",true);
                        }
                    }
                    component.set("v.isApproved",true);
                    component.set("v.isError",false);
                }
                else{
                    component.set("v.isApproved",false);
                    component.set("v.isError",false);
                }
            }
            else{
               	component.set("v.isError",true);
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },

    handleProjectTypeChange: function (component, event) {
        var changeValue = event.getParam("value");
        component.set("v.isLoopioPresent",false);
        component.set("v.isAvnioPresent",false);
        if(changeValue == "Loopio"){
            component.set("v.isLoopioPresent",true);
        }
        else if(changeValue == "Loopio for Salesforce"){
            component.set("v.isAvnioPresent",true);
        }
    },

    continueToCreateProject: function (component, event, helper) {
        component.set("v.showRecordTypeSelectionForLFS", false);
        if(component.get("v.isAvnioPresent")){
            if(component.get("v.skipRecordTypeSelection")){
                helper.createLFSProjectWithoutRecordType(component, event, helper);
            }
            else{
                component.set("v.showRecordTypeSelectionForLFS",true);
            }
        }
    },

    handleRecordTypeChange: function (component, event) {
        var changeValue = event.getParam("value");
        component.set("v.selectedRecordType",changeValue);
    },

    continueToRecTypeSelection: function (component, event) {
        component.set("v.showRecordTypeSelectionForLFS", false);
        if(component.get("v.skipRecordTypeSelection")){
            helper.createLFSProjectWithoutRecordType(component, event, helper);
        }
        else{
            if(component.get("v.selectedRecordType")){
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
                        "recordTypeId" : component.get("v.selectedRecordType"),
                        "defaultFieldValues": defaultFieldValues
                    });
                    createRecordEvent.fire();
                }
            }
            else{
                helper.createLFSProjectWithoutRecordType(component, event, helper);
            }
        }
    }
})