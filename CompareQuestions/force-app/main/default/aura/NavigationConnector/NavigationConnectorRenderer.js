({
	rerender : function(component,helper) {
      this.superRerender();
      helper.initLWC(component,helper);
	}
})