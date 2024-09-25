public class SObjectUtils
{
	public static String getNamespace(String stringToAppend)
	{
		String namespacePrefix = getCurrentNameSpace();
		String resultantStr = (String.isBlank(namespacePrefix) || namespacePrefix.toLowerCase() == 'null') ? '' : namespacePrefix + stringToAppend;
		return resultantStr;
	}

	/**
	 * @description Identify SObject Type from record
	 * @param record SObject Record
	 * @return SObject Type
	 */
	public static String GetSObjectType(SObject record) {
		return record.getSObjectType().getDescribe().getName();
	}

	public static String GetSObjectType(Id recordId) {
		return Id.valueOf(recordId).getSObjectType().getDescribe().getName();
	}

	/**
	 * @description Get value from SObject based on field & relationship
	 * @param so SObject Record
	 * @param field Field to get from SObject like Parent.Parent.Name
	 * @return Value of Field
	 */
	public static Object getSObjectFieldVal(SObject so, String field) {
		String[] fields = field.split('\\.');
		Integer len = fields.size();
		field = field.trim();
		if (len == 1) {
			return so.get(field);
		}

		SObject tmpSo = NULL;
		for (Integer i = 0; i<len - 1; i++) {
			if (i == 0) {
				tmpSo = so.getSObject(fields[i]);
			} else {
				tmpSo = tmpSo.getSObject(fields[i]);
			}

			if (tmpSo == NULL) {
				return NULL;
			}
		}
		return tmpSo.get(fields[len - 1]);
	}

	public static Object getSObjectFieldVal(SObject so, String field,String apexType) {
		Object val = getSObjectFieldVal(so,field);
		try{
			if(val!=null){
				 if (apexType == String.valueOf(Schema.DisplayType.DATE) && val instanceof DateTime) {
					DateTime dtVal = (Datetime) val;
					return dtVal.date();
				 }
			}
		}catch(Exception e){
			System.debug('getSObjectFieldVal exception:'+e);
		}
		
		return val;
	}

	/**
	 * @description Get List of the Fields of given SObjectType
	 * @param sObjectType SObject Type like Account, Custom_Object__c etc.
	 * @return Set of fields of given SObject Type
	 */
	public static Set<String> getSObjectFields(String sObjectType) {
		return getSObjectFieldMap(sObjectType).keySet();
	}

	/**
	 * @description Method to get Field Describe of give field of current SObject Type
	 * @param sObjectType Name of the SObject Type
	 * @param fieldName Name of the Field
	 * @return Schema.DescribeFieldResult 
	 */
	public static Schema.SObjectField getSObjectField(String sObjectType, String fieldName) {
		return getSObjectField(getSObjectDescribe(sObjectType), fieldName);
	}

	/**
	 * @description Get List of the Fields of given SObjectType
	 * @param sObjDescribe SObject Describe.
	 * @param fieldName Field API Name.
	 * @return Set of fields of given SObject Type
	 */
	public static Schema.SObjectField getSObjectField(Schema.DescribeSObjectResult sObjDescribe, String fieldName) {
		
		Schema.SObjectField fieldResult = NULL;
		String currentNameSpace = getCurrentNameSpace();
		

		if (fieldName.endsWith('__r')) {
			fieldName = fieldName.replace('__r', '__c');
		}
		
		fieldResult = sObjDescribe.fields.getMap().get(fieldName);
		if (fieldResult == NULL) {
			if (!String.isBlank(currentNameSpace) && fieldName.split('__').size() != 3) {
				fieldName = currentNameSpace + '__' + fieldName;
				fieldResult = sObjDescribe.fields.getMap().get(fieldName);
			}

			if (fieldResult == NULL) {
				fieldName = fieldName + 'Id';
				fieldResult = sObjDescribe.fields.getMap().get(fieldName);
			}
		}

		return fieldResult;
	}

	/**
	 * @description Get List of the Fields of given SObjectType
	 * @param sObjectType SObject Type like Account, Custom_Object__c etc.
	 * @return Set of fields of given SObject Type
	 */
	public static Map<String, Schema.SObjectField> getSObjectFieldMap(String sObjectType) {
		Set<String> fieldResultList = new Set<String> ();
		Schema.SObjectType sObjectTypeObj = getSObjectType(sObjectType);
		Schema.DescribeSObjectResult result = sObjectTypeObj.getDescribe();
		return result.fields.getMap();
	}

	/**
	 * @description Get List of Filtered Fields of given SObjectType
	 * @param sObjectType SObject Type like Account, Custom_Object__c etc.
	 * @param isReadable Flag indicate method should include readOnly fields or not.
	 * @param isWriteable Flag indicate method should include Writeable fields or not(This excudes formula fields).
	 * @return Map of filtered fields of given SObject Type
	 */
	public static Map<String, Schema.SObjectField> getFilterSObjectFieldMap(String sObjectType, Boolean isReadable, Boolean isWriteable) {
		Map<String, Schema.SObjectField> fieldMap = getSObjectFieldMap(sObjectType);


		Map<String, Schema.SObjectField> filteredFieldMap = new Map<String, Schema.SObjectField> ();

		for (String fieldName : fieldMap.keySet()) {

			Schema.SObjectField field = fieldMap.get(fieldName);
			Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
			//system.debug(fieldDescribe);
			if (fieldDescribe.isAccessible()) {
				if (isReadable && isWriteable) {
					filteredFieldMap.put(fieldName, field);
				} else if (!isReadable && !fieldDescribe.isAccessible()) {
					filteredFieldMap.put(fieldName, field);
				} else if (!isWriteable && (!fieldDescribe.isUpdateable() && !fieldDescribe.isCalculated())) {
					filteredFieldMap.put(fieldName, field);
				}
			}


		}

		return filteredFieldMap;
	}

	/**
	 * @description Get the Query of given SObject Type with all fields
	 * @param sObjectType SObject Type like Account, Custom_Object__c etc.
	 * @return Query of Sobject with all fields
	 */
	public static String getQuery(String sObjectType) {
		Set<String> fields = SObjectUtils.getSObjectFields(sObjectType);
		String query = 'SELECT ' + String.join(new List<String> (fields), ',') + ' FROM ' + sObjectType;
		return query;
	}

	/**
	 * @description Get List of all Child Relationship
	 * @param sObjectType SObject Type like Account, Custom_Object__c etc.
	 * @return List of all child relationship with fields : Relationship, SObject, Field
	 */
	public static List<Map<String, String>> getChildRelationship(String sObjectType) {

		List<Map<String, String>> childRelationList = new List<Map<String, String>> ();

		Schema.SObjectType sObjectTypeObj = getSObjectType(sObjectType);
		Schema.DescribeSObjectResult result = sObjectTypeObj.getDescribe();

		for (Schema.ChildRelationship chilRelationship : result.getChildRelationships()) {
			if (!chilRelationship.isDeprecatedAndHidden()) {
				Map<String, String> childFieldMap = new Map<String, String> ();
				childFieldMap.put('Relationship', chilRelationship.getRelationshipName());
				childFieldMap.put('SObject', String.valueOf(chilRelationship.getChildSObject()));
				childFieldMap.put('Field', String.valueOf(chilRelationship.getField()));

				childRelationList.add(childFieldMap);
			}
		}
		return childRelationList;
	}

	public static List<Map<String, String>> getChildRelationship(String sObjectType, Boolean isCreateable, Boolean isUpdateable) {

		List<Map<String, String>> childRelationList = new List<Map<String, String>> ();

		List<Map<String, String>> allChildRelationList = getChildRelationship(sObjectType);

		for (Map<String, String> chilRelationMap : allChildRelationList) {
			System.debug('chilRelationMap:'+chilRelationMap);
			String childSObject = chilRelationMap.get('SObject');
			Schema.DescribeSObjectResult sobjDescribe = getSObjectDescribe(childSObject);
			if(sobjDescribe==null){
				continue;
			}
			if (isCreateable == true && isUpdateable == false) {
				if (isCreateable == sobjDescribe.isCreateable()) {
					childRelationList.add(chilRelationMap);
				}
			} else if (isUpdateable == true && isCreateable == false) {
				if (isUpdateable == sobjDescribe.isUpdateable()) {
					childRelationList.add(chilRelationMap);
				}
			} else if (isUpdateable == true && isCreateable == true) {
				if ((isCreateable == sobjDescribe.isCreateable()) ||
				(isUpdateable == sobjDescribe.isUpdateable())) {
					childRelationList.add(chilRelationMap);
				}
			}


		}

		return childRelationList;
	}

	/**
	 * @description Update records as per the configuration of Rule Action
	 * @param parentField Parent SObject Field 
	 * @param refSObject SObject Record
	 * @return Value of the parentField against give refSObject
	 */
	public static string getParentValue(String parentField, SObject refSObject)
	{
		system.debug('In  getMergedValue parentField**' + parentField);
		system.debug('In  getMergedValue refSObject**' + refSObject);
		SObject SObj = refSObject;
		String value;
		try {
			List<String> pFieldsList = parentField.split('\\.');
			Integer i = 0;
			for (String field : pFieldsList) {
				i++;
				if (pFieldsList.size()> i && sObj != null)
				sObj = sObj.getSObject(field);
				else
				value = sObj == null ? '' : (String) sObj.get(field);
			}
		} catch(Exception Ex) {
			system.debug('In getParentValue ex.getmessage()**' + ex.getmessage());
			system.debug('In getParentValue ex.getLinenumber()**' + ex.getLinenumber());
		}
		return value;
	}

	



	/**
	 * @description Method to get Sobject type from global describe 
	 * @param sObjectType SObject Type
	 * @return Schema.SObjectType
	 */
	public static Schema.SObjectType getSObjectType(String sObjectType)
	{
		if (String.isEmpty(sObjectType)) return NULL;

		Map<String, Schema.SObjectType> sObjectTypeMap = Schema.getGlobalDescribe();

		if (sObjectType.endsWith('__c'))
		{
			//Custom Object
			if (sObjectType.split('__').size() != 3)
			{
				//Object with Not NameSpace
				if (sObjectTypeMap.containsKey(sObjectType)) return sObjectTypeMap.get(sObjectType);
				else return sObjectTypeMap.get(getCurrentNameSpace() + '__' + sObjectType);
			}
		}

		return sObjectTypeMap.get(sObjectType);
	}

	/**
	 * @description Method to get describe of Sobject from global describe 
	 * @param sObjectType SObject Type
	 * @return Schema.DescribeSObjectResult
	 */
	public static Schema.DescribeSObjectResult getSObjectDescribe(String sObjectType)
	{
		Schema.SObjectType sobjType = getSObjectType(sObjectType);
		return(sobjType == null ? null : sobjType.getDescribe());
	}

	/**
	 * @description Method to get current namespace
	 * @return Current Namespace of the ruleforce
	 */
	public static String getCurrentNameSpace()
	{
		return SObjectUtils.class.getName().substringBefore('SObjectUtils').removeEnd('.');
	}

	/**
	 * @description Method to get describe of Sobject from global describe 
	 * @return Schema.SObjectType
	 */
	public static SObjectType getGlobalDescribe(String sObjectType)
	{
		return getSObjectType(sObjectType);
	}

	/**
	 * @description Method to get all fields of given SObject Type
	 * @return Map of all fields of give Sobject Type
	 */
	public static Map<String, Schema.SObjectField> getFieldMap(String sObjectType)
	{
		return getGlobalDescribe(sObjectType).getDescribe().fields.getMap();
	}

	/**
	 * @description Method to get Field Describe of give field of current SObject Type
	 * @param sObjectType Name of the SObject Type
	 * @param fieldName Name of the Field
	 * @return Schema.DescribeFieldResult 
	 */
	public static Schema.DescribeFieldResult getFieldDescribe(String sObjectType, String fieldName)
	{
		return getFieldDescribe(getSObjectDescribe(sObjectType), fieldName);
	}

	/**
	 * @description Method to get Field Describe of give field of current SObject Type
	 * @param sObjDescribe SObject Field Describer
	 * @param fieldName Name of the Field
	 * @return Schema.DescribeFieldResult 
	 */
	public static Schema.DescribeFieldResult getFieldDescribe(Schema.DescribeSObjectResult sObjDescribe, String fieldName)
	{
		System.debug('sObjDescribe:' + sObjDescribe);
		System.debug('fieldName - ' + fieldName);

		Schema.SObjectField fieldResult = getSObjectField(sObjDescribe, fieldName);
		if (fieldResult != NULL) {
			try {
				return fieldResult.getDescribe();
			} catch(Exception e) { return NULL; }
		}

		return NULL;
	}

	public static String getSobjectNameFromId(String sobjectId)
	{
		String sobjectName = Id.valueOf(sobjectId).getSobjectType().getDescribe().getName();
		System.debug('--> Sobject Name - ' + sobjectName + ' for Id - ' + sobjectId);
		return sobjectName;
	}

	public static Boolean isHierarchyCustomSetting(String customSettingAPIName)
	{
		Schema.DescribeSObjectResult sobjDescribe = SObjectUtils.getSObjectDescribe(customSettingAPIName);
		if (sobjDescribe == null || !sobjDescribe.isCustomSetting()) return false;

		return sobjDescribe.fields.getMap().get('Name').getDescribe().isNillable();
	}

	public static Boolean isValidId(String stringId)
	{
		try
		{
			if (String.isBlank(stringId)) return false;

			Id validId = Id.valueOf(stringId);
			return true;
		} catch(Exception ex) { return false; }
	}

	public static List<String> getSObjectNameList()
	{
		List<Schema.SObjectType> allSObjects = Schema.getGlobalDescribe().values();

		List<String> sobjNames = new List<String> ();
		for (Schema.SObjectType sobjType : allSObjects)
		{
			sobjNames.add(sobjType.getDescribe().getName());
		}

		return sobjNames;
	}

	public static List<String> getPicklistValues(String sObjectName, String fieldName)
	{
		List<String> resultList = new List<String> ();
		for (Schema.PicklistEntry pickListValue : getFieldDescribe(sObjectName, fieldName).getPicklistValues())
		{
			resultList.add(pickListValue.getValue());
		}

		return resultList;
	}

	public static String getSObjectLabel(Id recordId)
	{
		if(recordId == null) return '';

		return recordId.getSObjectType().getDescribe().getLabel();
	}

	public static String getSObjectLabel(String sObjectName)
	{
		if(String.isBlank(sObjectName)) return '';

		return getSObjectDescribe(sObjectName).getLabel();
	}


	/*
	CreatedById => createdBy
	Custom__c => Custom__r
	*/
	public static String getFieldReferenceName(String fieldName)
	{
		if(!String.isEmpty(fieldName))
		{
			if(fieldName.endsWith('Id')) return fieldName.substring(0,fieldName.lastIndexOf('Id'));
			else if(fieldName.endsWith('__c')) return fieldName.replace('__c', '__r');
			else return fieldName;
		}
		return null;
	}

	private static Boolean isNamespaceSet = false;
	private static String namespace;

	public static String getNameSpace()
	{
		if(!isNamespaceSet)
		{
			isNamespaceSet = true;
			namespace = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
		}
		return namespace;
	}
}