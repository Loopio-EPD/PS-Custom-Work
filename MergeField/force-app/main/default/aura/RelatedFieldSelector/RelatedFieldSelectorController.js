({
	/**
	 * Initializes attributes with required data
	 */
	doInit : function(component, event, helper)
	{
		component.set('v.isLoading', true);
		helper.initEmptyFields(component);

		var sobj = component.get("v.sObject");
		var fieldRefMap = component.get("v.origFieldsMap");
		var origFieldRefString = component.get("v.origFieldReference");

		if(!$A.util.isEmpty(sobj) && !$A.util.isEmpty(fieldRefMap) && !$A.util.isEmpty(origFieldRefString))
		{
			helper.resetFromFieldRefMap(component, fieldRefMap, origFieldRefString);
		}
		else if(!$A.util.isEmpty(sobj) && !$A.util.isEmpty(origFieldRefString))
		{
			helper.setFullFieldsMap(component, origFieldRefString);
		}
	},

	/**
	 * Method to empty the fields when user click on Cancel button
	 */
	doInitEmpty : function(component, event, helper)
	{
		component.set('v.isLoading', true);
		helper.initEmptyFields(component);
	},

	/**
	 * Handles Field Change event for Field selection picklist
	 */
	fieldChanged : function(component, event, helper)
	{
		component.set('v.isLoading', true);
		helper.fieldChanged(component);
	},

	/**
	 * Handles Reference Navigation event for Field selection picklist
	 */
	breadcrumbNavigate : function(component, event, helper)
	{
		var itemIndex = event.getSource().get('v.name');
		var entityList = component.get('v.entityList'), entityMapList = component.get('v.entityMapList');

		if(itemIndex == entityList.length - 1) return;

		component.set('v.isLoading', true);

		for(var i = 0; i < entityList.length - itemIndex; i++)
		{
			entityList.pop();
			entityMapList.pop();
		}

		if(!$A.util.isEmpty(entityMapList))
		{
			var fieldsMap = entityMapList[entityMapList.length - 1];
			var fieldList = helper.getPicklistFromMap(component, fieldsMap);

			component.set('v.fieldsList', fieldList);
			component.set('v.fieldsMap', fieldsMap);
			component.set('v.entityList', entityList);
			component.set('v.entityMapList', entityMapList);
			component.set('v.val', '');
			component.set('v.isLoading', false);
		}
		else
		{
			helper.initEmptyFields(component);
		}
	},

	insertField: function(component, event, helper)
	{
		if(component.get('v.isFromNewButton')){
			var cmpEvent = component.getEvent("relatedFieldSelectorEvent"); 
			cmpEvent.setParams({"fieldToAdd" : component.get("v.finalFieldReference")}); 
			cmpEvent.fire();
		}
		else{
			var onchangeEvt = component.getEvent('fieldSelectedEvent');
			if(!$A.util.isEmpty(onchangeEvt))
			{
				onchangeEvt.setParams
				({
					'source': component.get('v.name'),
					'label': component.get('v.finalFieldLabel'),
					'value': component.get("v.finalFieldReference"),
					'type': component.get("v.finalFieldType"),
					'parentSObject': component.get("v.finalFieldObject")
				});
				onchangeEvt.fire();
			}

			component.find('overlayLibChild').notifyClose();
		}
	},
})