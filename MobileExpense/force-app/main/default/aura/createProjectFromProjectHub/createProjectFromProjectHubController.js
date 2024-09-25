({
    doInit : function(component, event, helper) { 
        var urlvalue = document.location.origin + "/lightning/n/ProjectHubTab_AddOn";
        component.set("v.backURL",urlvalue);
        helper.RecordTypeSelectorController(component); 
    },

    createRecordFun : function (component, event, helper) {
        var rtDet = document.querySelector('input[name="recordTypeRadio"]:checked');
        console.log(rtDet);
        if(rtDet != null) {
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "avnio__Project__c",
                "recordTypeId":rtDet.id
            });
            createRecordEvent.fire();
        } 
    },
    
    handleExit : function(component, event, helper) {
        var urlvalue = component.get("v.backURL");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
        "url": urlvalue
        });
        urlEvent.fire();
        //$A.get("e.force:closeQuickAction").fire() 
        //window.history.back();
    }

})