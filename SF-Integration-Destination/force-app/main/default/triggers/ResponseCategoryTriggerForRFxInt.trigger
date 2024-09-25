trigger ResponseCategoryTriggerForRFxInt on avnio__ResponseCategory__c (before delete, before update) {
    if(Trigger.isdelete) {
        Set<Id> recordIds = Trigger.oldMap.keySet();
        List<RFX_Integration_Log__c> logs = [select id, Response_Category__c from RFX_Integration_Log__c where Response_Category__c IN : recordIds];
        if(logs != null && logs.size() > 0){
            delete logs;
        }
    }
     if(RFxIntegrationSchedular.actionFromSchedular == false) {
        if(Trigger.isdelete) {
            for(avnio__ResponseCategory__c responscategoryeobj : Trigger.old) {
                if(responscategoryeobj.GSX_Integrated_Response__c) {
                   responscategoryeobj.addError('You can not modify the integrated records');
                }
            }
        }
         if(Trigger.isupdate) {
            for(avnio__ResponseCategory__c responscategoryeobj : Trigger.new) {
                if(responscategoryeobj.GSX_Integrated_Response__c) {
                    responscategoryeobj.addError('You can not modify the integrated records');
                }
            }
        }
    }
}