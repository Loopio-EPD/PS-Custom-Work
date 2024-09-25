({
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
			questionId : component.get('v.recordId'),
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
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: "Success!",
						message: "Record created succesfully.",
						type: "success"
					});
					toastEvent.fire();
					window.open('/' + component.get('v.recordId') ,'_self');
				}
				else{
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