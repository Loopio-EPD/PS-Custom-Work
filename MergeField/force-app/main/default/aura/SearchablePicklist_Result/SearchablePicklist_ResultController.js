({
	selectRecord: function(component, event, helper)
	{
		var selectRecord = component.get("v.picklistItem");

		var compEvent = component.getEvent("SearchablePicklist_SelectedEvent"); 
		compEvent.setParams
		({
			"value": selectRecord.value,
			"label": selectRecord.label
		});
		compEvent.fire();
	},
})