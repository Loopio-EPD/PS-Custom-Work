({
	doInit: function (component, event, helper) {
		var value = helper.getParameterByName(component , event, 'inContextOfRef');
		if(value){
			var context = JSON.parse(window.atob(value));
			component.set("v.recordId", context.attributes.recordId);
			component.set("v.fromoverridebutton", true);
		}
	},

    closeQA : function(component, event, helper) { 
		$A.get("e.force:closeQuickAction").fire(); 
		$A.get("e.force:refreshView").fire(); 
	}
})