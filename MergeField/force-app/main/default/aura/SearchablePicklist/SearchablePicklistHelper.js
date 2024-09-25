({
	searchHelper: function(component, searchKeyword)
	{
		var picklist = component.get('v.options'), picklistResults = [], minSearchLength = component.get('v.minSearchLength');

		if(searchKeyword.length < minSearchLength) return;

		if($A.util.isEmpty(searchKeyword)) picklistResults = picklist;
		else
		{
			picklist.forEach(function(element)
			{
				if(element.label.toLowerCase().includes(searchKeyword.toLowerCase()) || element.value.toLowerCase().includes(searchKeyword.toLowerCase())) picklistResults.push(element);
			});
		}

		component.set('v.filteredOptions', picklistResults);
		component.set("v.isSearchOpen", true);
	},

	fireChangeEvent: function(onchangeEvt, params)
	{
		if(!$A.util.isEmpty(onchangeEvt))
		{
			onchangeEvt.setParams(params);
			onchangeEvt.fire();
		}
	},
})