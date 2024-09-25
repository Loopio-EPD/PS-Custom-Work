({	
	/*Method to initialize all fields when component is created*/
	initEmptyFields : function(component)
	{
		var helper = this;

		var sobj = component.get("v.sObject");
		if($A.util.isEmpty(sobj))
		{
			component.set("v.errorText", $A.get("$Label.c.Rule_No_Sobject"));
			component.set('v.isLoading', false);
			return;
		}

		component.set("v.finalFieldReference", "");
		component.set("v.finalFieldObject", "");
		component.set("v.finalFieldType", "");
		component.set("v.errorText", "");
		component.set("v.fieldsMap", {});
		component.set("v.fieldsList", []);
		component.set("v.entityMapList", []);
		component.set("v.val", "");
		component.set("v.origFieldsMap", {});

		helper.setSobjectLabel(component, sobj);
		helper.setFieldsList(component, sobj);
	},

	setSobjectLabel : function(component, sobj)
	{
		var helper = this;

		var sobjectLabel = component.get('v.sObjectLabel');
		if(!$A.util.isEmpty(sobjectLabel))
		{
			component.set("v.entityList", []);
			helper.addToEntityList(component, sobjectLabel, sobj, true);
			return;
		}

		helper.sendRequest(component, 'getSobjectLabel', { 'SObjectName' : sobj })
		.then(function(sobjLabel)
		{	
			component.set('v.sObjectLabel', sobjLabel);
			component.set("v.entityList", []);
			helper.addToEntityList(component, sobjLabel, sobj, true);
		})
		.catch(function(error)
		{
			helper.handleUnsuccess(error);
		});
	},

	/**
	 * Sets full list of fields by making callback to controller
	 * @param {Object} component Lightning component
	 * @param {String} sobjName Name of sObject for getting it's fields
	 */
	setFullFieldsMap : function(component, referenceString)
	{
		console.log('Entered setFullFieldsMap Helper method...');
		var helper = this;

		var params =
		{
			"sobj" : component.get("v.sObject"),
			"referenceString" : referenceString
		};

		helper.sendRequest(component, 'getReferenceFieldList', params)
		.then(function(stringMap)
		{
			component.set("v.origFieldsMap", stringMap);
			component.set("v.entityMapList", stringMap);
			helper.resetFromFieldRefMap(component, stringMap, referenceString);
		})
		.catch(function(error)
		{
			helper.handleUnsuccess(error);
			component.set('v.isLoading', false);
		});
	},
	
	/*Method to reset the Field Value when user click on reset button*/
	resetFromFieldRefMap : function(component, fieldRefMap, referenceString)
	{
		if($A.util.isEmpty(fieldRefMap))
			return;

		var ls = referenceString.split(".");
		console.log("ls - " + ls);

		var lastFieldName = ls.pop();
		console.log("lastFieldName - " + lastFieldName);
		console.log("ls - " + ls);

		for(var i in ls)
		{
			var currentResObj = fieldRefMap[i];
			console.log("currentResObj - " + JSON.stringify(currentResObj));

			var refKey = Object.keys(currentResObj).find(key => currentResObj[key].ReferenceName == ls[i]);
			var refObj = currentResObj[refKey];
			console.log("Ref Obj - " + JSON.stringify(refObj));

			this.addToEntityList(component, refObj.FieldLabel, refObj.ReferenceName);
		}

		var lastElem = fieldRefMap.pop();
		console.log("Last Elem - " + JSON.stringify(lastElem));
		
		if($A.util.isEmpty(lastElem[lastFieldName])) return;
		
		var fieldList = this.getPicklistFromMap(component, lastElem);
		//console.log('-- Fields list - ' + JSON.stringify(fieldList));
				
		component.set("v.fieldsMap", lastElem);
		component.set("v.fieldsList", fieldList);
		component.set("v.val", lastFieldName);

		component.set("v.finalFieldObject", lastElem[lastFieldName].ReferenceSobject);
		component.set("v.finalFieldReference", referenceString);
		component.set("v.finalFieldType", lastElem[lastFieldName].FieldType);
		component.set('v.isLoading', false);
	},

	/*
	Method to handle field change event. Call when user change the field
	*/
	fieldChanged : function(component)
	{
		console.log('Entered fieldChanged Helper method...');

		var selectedField = component.get("v.val");
		var sobjMap = component.get("v.fieldsMap");
		var sobjField = sobjMap[selectedField];
		var entityList = component.get("v.entityList");
		var fieldRefDepth = component.get("v.fieldReferenceDepth");
		
		console.log("Selected Field - " + selectedField + "\nSelected Field Type - " + sobjField.FieldType + "\nEntity List Size - " + entityList.length);

		if(entityList.length >= fieldRefDepth && sobjField && sobjField.FieldType == "REFERENCE")
		{
			component.set("v.errorText", "Maximum relation allowed is upto " + fieldRefDepth + " steps");
			component.set("v.finalFieldReference", component.get("v.origFieldReference"));
			component.set("v.finalFieldType", "");
			component.set("v.val", "");
			component.set('v.isLoading', false);
		}
		else if(sobjField && sobjField.FieldType == "REFERENCE" && (entityList.length < fieldRefDepth))
		{
			component.set("v.val", "");
			component.set("v.errorText", "");
			component.set("v.fieldsList", "");
			component.set("v.finalFieldType", "");

			this.addToEntityList(component, sobjField.FieldLabel, sobjField.ReferenceName);
			this.setFieldsList(component, sobjField.ReferenceSobject);
		}
		else
		{
			var finalField = this.createResultantObj(component, selectedField);

			if(!$A.util.isEmpty(finalField))
			{
				component.set("v.finalFieldLabel", finalField.Label);
				component.set("v.finalFieldReference", finalField.Name);
				component.set("v.finalFieldObject", finalField.ParentSObject);
				component.set("v.finalFieldType", finalField.Type);
				component.set("v.errorText", "");
			}
			component.set('v.isLoading', false);
		}
	},

	/**
	 * Adds string value to entityList attribute
	 * @param {Object} component Lightning component
	 * @param {String} stringValue String to add
	 */
	addToEntityList : function(component, stringLabel, stringValue, putAtFirst)
	{
		console.log('Entered addToEntityList Helper method...');

		var breadCrumb =
		{
			label : stringLabel,
			value : stringValue
		};

		var entityList = component.get("v.entityList");

		if(putAtFirst == true) entityList.unshift(breadCrumb);
		else entityList.push(breadCrumb);

		component.set("v.entityList", entityList);
	},

	/**
	 * Sets list of fields in attribute objFields by making callback to controller
	 * @param {Object} component Lightning component
	 * @param {String} sobjName Name of sObject for getting it's fields
	 */
	setFieldsList : function(component, sobjName)
	{
		console.log('Entered setFields Helper method...');
		console.log('Getting fields for - ' + sobjName);
		var helper = this;
		
		helper.sendRequest(component, 'getSobjFields', { 'sobjName' : sobjName })
		.then(function(stringMap)
		{
			component.set("v.fieldsMap", stringMap);
			var fieldList = helper.getPicklistFromMap(component, stringMap);

			//console.log('-- Fields list - ' + JSON.stringify(fieldList));
			//console.log('-- Fields Map - ' + JSON.stringify(stringMap));
			component.set("v.fieldsList", fieldList);
			component.set('v.isLoading', false);

			var entityMapList = component.get("v.entityMapList");
			entityMapList.push(stringMap);
			component.set("v.entityMapList", entityMapList);
		})
		.catch(function(error)
		{
			helper.handleUnsuccess(error);
			component.set('v.isLoading', false);
		});
	},

	/**
	 * Gets picklist object of type SelectOption using map of Strings
	 * @param {Map} stringValues Map of String to convert to SelectOption object
	 */
	getPicklistFromMap : function(component, objMap)
	{
		console.log('Entered getPicklistFromMap Helper method...');

		var isDisplayRequiredFields = component.get("v.isRequiredFields");
		var isDisplayNonCreateableFields = component.get("v.isNonCreateableFields");
		var isDisplayNonUpdateableFields = component.get("v.isNonUpdateableFields");
		var filterFieldTypes = component.get("v.typeFilters");
		var filterExceptionTypes = component.get("v.typeExceptions");
		var filterSObjects = component.get("v.objectFilters");

		filterFieldTypes = ($A.util.isEmpty(filterFieldTypes)) ? [] : filterFieldTypes.toUpperCase().trim().split(',');
		filterExceptionTypes = ($A.util.isEmpty(filterExceptionTypes)) ? [] : filterExceptionTypes.toUpperCase().trim().split(',');
		filterSObjects = ($A.util.isEmpty(filterSObjects)) ? [] : filterSObjects.toUpperCase().trim().split(',')

		var refPicklist = [];
		var refIdPicklist = [];
		var valPicklist = [];
		var reqFieldPicklist = [];

		Object.keys(objMap).forEach(function(key)
		{
			var objVal = objMap[key];

			var isReference = objVal.FieldType == "REFERENCE";
			var isReferenceId = objVal.FieldType == "REFERENCEID" || objVal.FieldType == "ID";
			var isRequired = objVal.IsRequired == "true";
			
			//Don't add field if Not accessible AND (not Updateable/Createable if Flag is set in attribute)
			if(!isReference || !isRequired)
			{
				if(objVal.IsAccessible == 'false') return;
				if(objVal.IsCreateable == 'false' && !isDisplayNonCreateableFields) return;
				if(objVal.IsUpdateable == 'false' && !isDisplayNonUpdateableFields) return;
			}
			
			//Don't add field if filter is applied and filtered list doesn't contain that field type
			if(filterExceptionTypes.includes(objVal.FieldType)) return;
			if(filterFieldTypes.length > 0 && !filterFieldTypes.includes(objVal.FieldType)) return;
			if(filterSObjects.length > 0 && (objVal.FieldType != 'REFERENCE') && !filterSObjects.includes(objVal.ReferenceSobject.toUpperCase())) return;

			var objLabel = isReference ? (objVal.FieldLabel + " (" + objVal.ReferenceName + ") >") : objVal.FieldLabel;
			var objValue = key;
			//var objValue = isReference ? objVal.ReferenceSobject : key;

			var tempObj =
			{
				label : objLabel,
				value : objValue
			};

			if(isReference) refPicklist.push(tempObj);
			else if(isReferenceId) refIdPicklist.push(tempObj);
			else if(isRequired)
			{
				tempObj.label = tempObj.label + " *";
				reqFieldPicklist.push(tempObj);
			}
			else valPicklist.push(tempObj);
		});

		refPicklist.sort(function(a, b)
		{
			if (a.label < b.label) return -1;
			if (a.label > b.label) return 1;
			return 0;
		});

		refIdPicklist.sort(function(a, b)
		{
			if (a.label < b.label) return -1;
			if (a.label > b.label) return 1;
			return 0;
		});

		valPicklist.sort(function(a, b)
		{
			if (a.label < b.label) return -1;
			if (a.label > b.label) return 1;
			return 0;
		});

		reqFieldPicklist.sort(function(a, b)
		{
			if (a.label < b.label) return -1;
			if (a.label > b.label) return 1;
			return 0;
		});

		var picklist = [];
		picklist = picklist.concat(refPicklist);
		if(isDisplayRequiredFields) picklist = picklist.concat(reqFieldPicklist);
		picklist = picklist.concat(refIdPicklist);
		picklist = picklist.concat(valPicklist);

		return picklist;
	},

	/**
	 * Validates all fields and returns true if all fields are valid
	 * @param {Object} component Lightning component
	 */
	validateAllFields : function(component)
	{
		console.log('Entered validateAllFields Helper method...');
		/*
		var isNameValid = component.find("ruleSetName").get("v.validity").valid;
		var isObjectValid = component.find("ruleSetObj").get("v.validity").valid;
		var isEvaluationRuleValid = component.find("evalRule").get("v.validity").valid;
		var isFilterLogicValid = component.find("filterLogic").get("v.validity").valid;
		var isExpirationDateValid = component.find("expirationDT").get("v.validity").valid;

		if(isNameValid && isObjectValid && isEvaluationRuleValid && isFilterLogicValid && isExpirationDateValid)
		{
			return true;
		}

		return false;
		*/
	},

	/**
	 * Returns Resultant String from List of fields with Referenced fields
	 * @param {Object} component Lightning component
	 */
	createResultantObj : function(component, selectedField)
	{
		console.log('Entered createResultantString Helper method...');

		var fieldList = component.get("v.entityList");
		console.log(fieldList);

		var resultantString = "";
		for(var i in fieldList)
		{
			if(i == 0){}
			else if($A.util.isEmpty(fieldList[i].value))
			{
				console.log("Error. Null Field!");
				var fieldRefError = $A.get("$Label.c.Rule_FieldReference_Error");
				this.showErrors(component, fieldRefError);
				
				return "";
			}
			else
			{
				resultantString += fieldList[i].value + ".";
			}
		}

		resultantString += selectedField;
		var fieldsMap = component.get("v.fieldsMap");

		var resultantObj =
		{
			Label: fieldsMap[selectedField].FieldLabel,
			Name : resultantString,
			Type : fieldsMap[selectedField].FieldType,
			ParentSObject : fieldsMap[selectedField].ReferenceSobject
		};

		console.log("Final resultantObj - " + resultantObj);

		return resultantObj;
	},

	/**
	 * Shows error in UI using errorText attribute
	 * @param {Object} component Lightning component
	 * @param {string} msg Error message to show
	 */
	showErrors : function(component, msg)
	{
		console.log('Entered showErrors Helper method...');

		component.set("v.errorText", msg);
	},

	/**
	 * Gets picklist object of type SelectOption using list of Strings
	 * @param {List} stringValues List of String to convert to SelectOption object
	 */
	getPicklistFromStringList : function(stringValues)
	{
		console.log('Entered getPicklistFromStringList Helper method...');
		console.log('-- stringValues = ' + stringValues);

		var picklist = [];
		stringValues.forEach(function(pickListItem)
		{
			var tempObj = 
			{
				label : pickListItem,
				value : pickListItem
			};
			picklist.push(tempObj);
		});

		return picklist;
	},

	/**
	 * Refreshes Record Details
	 * @param {Object} component Lightning component
	 */
	refreshView : function(component)
	{
		$A.get('e.force:refreshView').fire();
	},

	/**
	 * Sends Request to Controller for fetching data and to be used as JS Promise
	 * @param {Object} component Lightning component
	 * @param {String} actionName Name of Action to call
	 * @param {Object} params Request parameters
	 */
	sendRequest : function(component, actionName, params)
	{
		console.log('Entered sendRequest Helper method...');

		return new Promise($A.getCallback(function(resolve, reject)
		{
			var action = component.get("c."+actionName);
			if(params)
			{
				action.setParams(params);
			}
			action.setCallback(this, function(response)
			{
				var state = response.getState();
				if (state === "SUCCESS")
				{
					resolve(response.getReturnValue());
				}
				else
				{
					reject(response.getError());
				}
			});
			$A.enqueueAction(action);
		}));
	},

	/**
	 * Handles default Unsuccessful action callback using Toast notifications with Errors
	 * @param {List} errors List of errors
	 */
	handleUnsuccess : function(errors)
	{
		console.log('Entered handleError Helper method...');

		var ruleInternalServerError = $A.get("$Label.c.Rule_Internal_Server_Error");
		var ruleUnknownError = $A.get("$Label.c.Rule_Unknown_Error");

		var errorMsg = (errors && errors[0] && errors[0].message) ? (ruleInternalServerError + errors[0].message) : ruleUnknownError;
		console.log(errorMsg);

		this.showToast(errorMsg, "error");
	},

	/**
	 * Shows Toast Notification for Success or Failure
	 * @param {string} msg Toast Message to Show
	 * @param {string} toastType Toast Type (success/warning/info/error)
	 */
	showToast : function(msg, toastType)
	{
		var toastMessage = (!$A.util.isEmpty(msg)) ? msg : $A.get("$Label.c.Rule_Unknown_Error");
		var params =
		{
			message: toastMessage,
			type: toastType,
			duration: 5000,
			mode: "dismissible"
		};
		this.fireLtnEvent("e.force:showToast", params);
	},

	/**
	 * Gets event from $A using Lightning Event Name and parameters
	 * @param {String} eventName Name of Event to fire
	 * @param {Object} params Event parameters
	 */
	fireLtnEvent : function(eventName, params)
	{
		var event = $A.get(eventName);

		if($A.util.isEmpty(event)) return;

		event.setParams(params);
		event.fire();
	},
})