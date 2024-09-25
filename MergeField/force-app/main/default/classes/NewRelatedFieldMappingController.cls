public with sharing class NewRelatedFieldMappingController {

    @AuraEnabled
    public static Map<String,Object> upsertRecord(String mergeField, String keyWord, String value){
        Map<String,Object> result = new Map<String,Object>();
		try{
            Response_Merge_Field_Mapping__c mergeFieldMapping = new Response_Merge_Field_Mapping__c();
            mergeFieldMapping.Keyword__c = keyWord;
            mergeFieldMapping.Merge_Field_API_Name__c = mergeField;
            mergeFieldMapping.Value__c = value;

            insert mergeFieldMapping;

			result.put('status', 'success');
		    result.put('recordId', String.valueOf(mergeFieldMapping.Id));
		}
		catch(Exception e){
            result.put('status', 'error');
			result.put('errorMessage', e.getMessage());
        }
		return result;
    }
}