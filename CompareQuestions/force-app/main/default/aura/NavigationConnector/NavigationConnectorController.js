({
	init : function(component, event, helper) {
		var myPageRef = cmp.get("v.pageReference");
        var projectid = myPageRef.state.c__projectid;
        component.set("v.projectid", projectid);
		var recordId = myPageRef.state.c__recordid;
        component.set("v.recordid", recordId);
        console.log('recordId'+recordId);
		console.log('recordId'+projectid);
		component.find('compareQuestions').loadInitialData();
	}
})