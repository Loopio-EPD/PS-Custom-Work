trigger ResponseQuestionTriggerForRFxInt on avnio__ResponseQuestion__c  (before delete, before update) {
    if(Trigger.isdelete) {
        Set<Id> recordIds = Trigger.oldMap.keySet();
        List<RFX_Integration_Log__c> logs = [select id, Alternative_Question__c from RFX_Integration_Log__c where Alternative_Question__c IN : recordIds];
        if(logs != null && logs.size() > 0){
            delete logs;
        }
    }
     if(RFxIntegrationSchedular.actionFromSchedular == false) {
        if(Trigger.isdelete) {
            for(avnio__ResponseQuestion__c responsequestionobj : Trigger.old) {
                if(responsequestionobj.GSX_Integrated_Response__c) {
                   responsequestionobj.addError('You can not modify the integrated records');
                }
            }
        }
         if(Trigger.isupdate) {
            for(avnio__ResponseQuestion__c responsequestionobj : Trigger.new) {
                if(responsequestionobj.GSX_Integrated_Response__c) {
                 responsequestionobj.addError('You can not modify the integrated records');
                }
            }
        }
    }
}