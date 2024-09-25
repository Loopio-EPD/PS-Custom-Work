({
    initLWC : function(component,helper) {
        console.log('IN init');
        var myPageRef = component.get("v.pageReference");
  
          //package
          var projectid = myPageRef.state.c__projectid;
          component.set("v.projectid", projectid);
          
          //version
          var recordId = myPageRef.state.c__recordid;
          component.set("v.recordid", recordId);
          
          component.find('compareQuestions').loadInitialData();
      }
})