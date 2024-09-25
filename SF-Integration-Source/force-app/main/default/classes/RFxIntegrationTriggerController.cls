public without sharing class RFxIntegrationTriggerController {
	
    public static void createDeleteLogs(List<SObject> deletedRecords){
        if(deletedRecords == null || deletedRecords.isEmpty()){
            return;
        }

        Id recordIdForObjName = Id.valueOf(String.valueOf(deletedRecords[0].get('Id')));
        String objectName = getObjectAPIName(recordIdForObjName);
        
        Map<String,Boolean> recordIdToGSXEnableMap = new Map<String,Boolean>();
        if(objectName != null && !objectName.equalsIgnoreCase('avnio__response__c')){
            Set<String> recordIds = new Set<String>();
            for(SObject sobj : deletedRecords){
                recordIds.add(String.valueOf(sobj.get('avnio__ResponseId__c')));
            }
            String query = 'select id, GSX_Integrated_Response__c from avnio__Response__c where id IN :recordIds limit 49999';
            List<avnio__Response__c> records = Database.query(query);
            if(records != null && records.size() > 0){
                for(avnio__Response__c rec : records){
                	recordIdToGSXEnableMap.put(String.valueOf(rec.Id),rec.GSX_Integrated_Response__c);
                }
            }
        }

        List<RFX_Integration_Data_Delete_Log__c> logRecList = new List<RFX_Integration_Data_Delete_Log__c>(); 
        for(SObject sobj : deletedRecords){
            if(objectName != null && objectName.equalsIgnoreCase('avnio__response__c')){
                if(Boolean.valueOf(sobj.get('GSX_Integrated_Response__c'))){
                    RFX_Integration_Data_Delete_Log__c logRec = new RFX_Integration_Data_Delete_Log__c();
                    logRec.Record_ID__c = String.valueOf(sobj.get('Id'));
                    logRec.Object_API_Name__c = objectName;
                	logRecList.add(logRec);
                }
            }
            else{
                if(recordIdToGSXEnableMap != null && recordIdToGSXEnableMap.get(String.valueOf(sobj.get('avnio__ResponseId__c')))){
                    RFX_Integration_Data_Delete_Log__c logRec = new RFX_Integration_Data_Delete_Log__c();
                    logRec.Record_ID__c = String.valueOf(sobj.get('Id'));
                    logRec.Object_API_Name__c = objectName;
                    logRecList.add(logRec);
                }
            }
        }

        Database.insert(logRecList,false);
    }

    public static String getObjectAPIName(ID recordId) {
        if(recordId == null){
            return '';
        }
        return recordId.getSObjectType().getDescribe().getName();
    }
}