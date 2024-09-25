({
	doInit : function (component, event, helper)
	{
		var picklist = component.get('v.options'), isDisabled = component.get('v.disabled');
		var selectedValue = component.get('v.value'), selectedLabel = '';
		var isRequired = component.get('v.required');

		component.set('v.searchKeyword', '');
		component.set('v.selectedLabel', '');

		if(!$A.util.isEmpty(picklist) && (picklist.length > 0) && !$A.util.isEmpty(selectedValue))
		{
			picklist.forEach(function(element)
			{
				if(element.value === selectedValue) selectedLabel = element.label;
			});

			if($A.util.isEmpty(selectedLabel))
			{
				component.set('v.value', '');
				if(isRequired) component.set('v.validity', { 'valid': false });
			}
			else
			{
				component.set('v.selectedLabel', selectedLabel);
				component.set("v.isSearchOpen", false);
				if(isDisabled) component.set('v.searchKeyword', selectedLabel);
				component.set('v.validity', { 'valid': true });
			}
		}
		else
		{
			component.set('v.validity', { 'valid': !isRequired });
		}
	},

	onfocus: function(component, event, helper)
	{
		var isDisabled = component.get('v.disabled');
		if(!isDisabled) helper.searchHelper(component, component.get('v.searchKeyword'));
	},

	onblur: function(component, event, helper)
	{
		var value = component.get('v.value'), isRequired = component.get('v.required');

		component.set('v.hasError', (isRequired && $A.util.isEmpty(value)) ? true : false);
		component.set("v.isSearchOpen", false);
	},

	search: function(component, event, helper)
	{
		helper.searchHelper(component, component.get("v.searchKeyword"));
	},

	// function for clear the Record Selection 
	clear: function(component, event, heplper)
	{
		component.set("v.searchKeyword", '');
		component.set("v.value", '');
		component.set("v.selectedLabel", '');
		component.set('v.validity', { 'valid': !component.get('v.required') });
	},

	// This function call when the end User Select any record from the result list.   
	handleComponentEvent: function(component, event, helper)
	{
		var selectedValue = event.getParam("value"), selectedLabel = event.getParam("label");

		component.set("v.value", selectedValue);
		component.set("v.selectedLabel", selectedLabel);
		component.set("v.isSearchOpen", false);
		component.set('v.validity', { 'valid': true });

		helper.fireChangeEvent(component.getEvent('onchange'), event.getParams());
	},

	handleValidation: function(component, event, helper)
	{
		var picklist = component.get('v.options'), selectedValue = component.get('v.value');

		if(!Array.isArray(picklist) && !$A.util.isEmpty(selectedValue))
		{
			component.set('v.validity', { 'valid': true });
			return true;
		}
		else if($A.util.isEmpty(selectedValue) && component.get('v.required'))
		{
			component.set('v.validity', { 'valid': false });
			component.set('v.hasError', true);

			return false;
		}
	},
})