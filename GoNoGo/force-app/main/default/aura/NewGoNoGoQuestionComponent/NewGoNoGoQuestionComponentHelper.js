({
	getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&⌗]*)|&|⌗|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
	
	saveRecordHelper : function(component,event,helper) {
        var sectionId = component.get("v.sectionId");
        var makerequired = component.get("v.makerequired");
        var questionsequence = component.get("v.questionsequence");
        var maxscore = component.get("v.maxscore");
        var datatype = component.get("v.datatype");
		var questionlabel = component.get("v.questionlabel");
		var opportuntityFieldAPIName = component.get("v.opportuntityFieldAPIName");
		var action = component.get("c.upsertQuestionRecord");
		var toastEvent = $A.get("e.force:showToast");
		if(sectionId == null || sectionId.trim() == "" || questionsequence == null || questionsequence == "" || 
           datatype == null || datatype.trim() == "" || questionlabel == null || questionlabel.trim() == ""){
			toastEvent.setParams({
				title: "Error!",
				message: "Please fill the required data.",
				type: "error"
			});
			toastEvent.fire();
			return;
		}
		if(datatype == "Salesforce Input" && (opportuntityFieldAPIName == null || opportuntityFieldAPIName.trim() == "")){
			toastEvent.setParams({
				title: "Error!",
				message: "Please fill the required data.",
				type: "error"
			});
			toastEvent.fire();
			return;
		}
		if(maxscore == null || maxscore == undefined || maxscore == ""){
			maxscore = null;
		}
        component.set("v.showSpinner", true);
        action.setParams({
			questionId : '',
            sectionId : sectionId,
            questionsequence : questionsequence,
            maxscore : maxscore,
            datatype : datatype,
            questionlabel : questionlabel,
            makerequired : makerequired,
			opportuntityFieldAPIName : opportuntityFieldAPIName
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