({
        doInit: function (component, event, helper) {
            var action = component.get("c.loadDataForGoNoGoQuestion");
            var recordId = component.get("v.recordId");
            action.setParams({'questionId' : recordId});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                        if(response && response.getReturnValue() && response.getReturnValue().dataTypesOptions && response.getReturnValue().opportunityFields){
                                component.set("v.datatypeoptions", response.getReturnValue().dataTypesOptions);
                                component.set("v.opportunityfields", response.getReturnValue().opportunityFields);
                                component.set("v.questionName", response.getReturnValue().questionName);
                                component.set("v.makerequired", response.getReturnValue().makeRequired);
                                component.set("v.questionlabel", response.getReturnValue().questionLabel);
                                component.set("v.datatype", response.getReturnValue().dataType);
                                component.set("v.questionsequence", response.getReturnValue().questionSequence);
                                component.set("v.maxscore", response.getReturnValue().maxScore);
                                component.set("v.sectionId", response.getReturnValue().sectionId);
                                component.set("v.opportuntityFieldAPIName", response.getReturnValue().opportuntityFieldAPIName);
                                component.set("v.showSpinner", false);
                                var customlookupcmp = component.find('customlookupcmp');
                                customlookupcmp.loadInitialData();
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
            helper.saveRecordHelper(component,event,helper);
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