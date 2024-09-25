public class RulesController {
		@AuraEnabled(cacheable=true)
	public static List<Map<String, Map<String, String>>> getReferenceFieldList(String sobj, String referenceString)
	{
	

		System.debug('--> Ref Sobj - ' + sobj + '\nRef Str - ' + referenceString);

		List<Map<String, Map<String, String>>> sobjFieldsList = new List<Map<String, Map<String, String>>> ();

		List<String> refList = referenceString.split('\\.');
		System.debug('-- refList - ' + refList);

	
			String currentSobj = sobj;
			for (Integer i = 0; i<refList.size(); i++)
			{
				Map<String, Map<String, String>> sobjFieldMap = getSobjFields(currentSobj);
				sobjFieldsList.add(sobjFieldMap);

				for (String key : sobjFieldMap.keySet())
				{
					Map<String, String> val = sobjFieldMap.get(key);
					System.debug('--> Val Map - ' + val);
					if (val.get('ReferenceName') == refList[i])
					{
						System.debug('--> Changing Sobj to - ' + refList[i]);
						//currentSobj = refList[i];

						currentSobj = val.get('ReferenceSobject');
						break;
					}
				}
			}

			return sobjFieldsList;

	}

    
    	@AuraEnabled(cacheable=true)
	public static String getSobjectLabel(String SObjectName)
	{
		
			return SObjectUtils.getSObjectLabel(SObjectName);
		
	}
    
    	@AuraEnabled(cacheable=true)
	public static Map<String, Map<String, String>> getSobjFields(String sobjName)
	{
		
			return getSobjectFields(sobjName);
		
	
	}
    
    public static Map<String, Map<String, String>> getSobjectFields(String sobjName)
	{
		Map<String, Schema.SObjectField> sobjFieldMap = SObjectUtils.getFieldMap(sobjName);

		Map<String, Map<String, String>> fieldsMap = new Map<String, Map<String, String>> ();
		Map<String, Map<String, String>> relatedFieldsMap = new Map<String, Map<String, String>> ();

		for (Schema.SObjectField sobjField : sobjFieldMap.values())
		{
			Schema.DescribeFieldResult fieldDesc;
			
				fieldDesc = sobjField.getDescribe();
		

			//TODO Check for Schema.DisplayType.ANYTYPE
			//TODO Implementation for Time type
			Schema.DisplayType fieldType = fieldDesc.getType();
			if (fieldType == Schema.DisplayType.BASE64
			    || fieldType == Schema.DisplayType.ADDRESS
			    || fieldType == Schema.DisplayType.COMPLEXVALUE
			    || fieldType == Schema.DisplayType.DATACATEGORYGROUPREFERENCE
			    || fieldType == Schema.DisplayType.ENCRYPTEDSTRING
			    || fieldType == Schema.DisplayType.MULTIPICKLIST
			    || fieldType == Schema.DisplayType.TIME) continue;

			Map<String, String> tempMap = new Map<String, String> ();
			tempMap.put('FieldType', String.valueOf(fieldType).toUpperCase());
			tempMap.put('FieldLabel', String.valueOf(fieldDesc.getLabel()));
			tempMap.put('ReferenceSobject', sobjName);
			tempMap.put('IsAccessible', String.valueOf(fieldDesc.isAccessible()));
            tempMap.put('IsCreateable', String.valueOf(fieldDesc.isCreateable()));
			tempMap.put('IsUpdateable', String.valueOf(fieldDesc.isUpdateable()));
			tempMap.put('IsCascadeDelete', String.valueOf(fieldDesc.isCascadeDelete()));
			tempMap.put('IsIdLookup', String.valueOf(fieldDesc.isIdLookup()));
			tempMap.put('IsMasterDetail', String.valueOf(fieldDesc.getRelationshipOrder() == null ? false : true));
			tempMap.put('IsRequired', String.valueOf(fieldDesc.isCreateable() && !fieldDesc.isNillable() && !fieldDesc.isDefaultedOnCreate()));
			tempMap.put('IsHierarchy', String.valueOf(SObjectUtils.isHierarchyCustomSetting(sobjName)));

			if (String.valueOf(fieldType).containsIgnoreCase('REFERENCE'))
			{
				String refSobj = String.valueOf(fieldDesc.getReferenceTo() [0].getDescribe().getName());
				String refName = String.valueOf(fieldDesc.getRelationshipName());
				String refLabel = String.valueOf(fieldDesc.getReferenceTo() [0].getDescribe().getLabel());

				tempMap.put('ReferenceSobject', refSobj);
				tempMap.put('ReferenceName', refName);

				if (!String.isBlank(refName))
				{
					Map<String, String> tmpMap = new Map<String, String> ();
					tmpMap.putAll(tempMap);
					if (fieldDesc.getLabel().endsWithIgnoreCase('ID'))
					tmpMap.put('FieldLabel', fieldDesc.getLabel().removeEndIgnoreCase('ID').trim());
					relatedFieldsMap.put(refName, tmpMap);
				}

				//DO NOT MOVE THIS LINE ABOVE
				tempMap.put('FieldType', 'REFERENCEID');
				if (!fieldDesc.getLabel().endsWithIgnoreCase('ID'))
				tempMap.put('FieldLabel', fieldDesc.getLabel() + ' ID');
			}

			fieldsMap.put(String.valueOf(sobjField), tempMap);
		}

		Map<String, Map<String, String>> allFieldsMap = new Map<String, Map<String, String>> ();
		allFieldsMap.putAll(relatedFieldsMap);
		allFieldsMap.putAll(fieldsMap);

		System.debug('-- All Fields Map - ' + allFieldsMap);

		return allFieldsMap;
	}
}