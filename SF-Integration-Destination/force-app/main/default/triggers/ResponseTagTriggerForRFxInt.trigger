trigger ResponseTagTriggerForRFxInt on avnio__ResponseTag__c  (before delete, before update) {
    if(Trigger.isdelete) {
        Set<Id> recordIds = Trigger.oldMap.keySet();
        List<RFX_Integration_Log__c> logs = [select id, Response_Tag__c from RFX_Integration_Log__c where Response_Tag__c IN : recordIds];
        if(logs != null && logs.size() > 0){
            delete logs;
        }
    }
    
     if(RFxIntegrationSchedular.actionFromSchedular == false) {
        if(Trigger.isdelete) {
            for(avnio__ResponseTag__c responsetageobj : Trigger.old) {
                if(responsetageobj.GSX_Integrated_Response__c) {
                 responsetageobj.addError('You can not modify the integrated records');
                }
            }
        }
        
        if(Trigger.isupdate) {
            for(avnio__ResponseTag__c responsetageobj : Trigger.new) {
                if(responsetageobj.GSX_Integrated_Response__c) {
                 responsetageobj.addError('You can not modify the integrated records');
                }
            }
        }
    }
}