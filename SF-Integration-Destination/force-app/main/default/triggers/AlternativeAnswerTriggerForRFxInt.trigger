trigger AlternativeAnswerTriggerForRFxInt on avnio__AlternativeAnswer__c  (before delete, before update) {
    if(Trigger.isdelete) {
        Set<Id> recordIds = Trigger.oldMap.keySet();
        List<RFX_Integration_Log__c> logs = [select id, Alternative_Answer__c from RFX_Integration_Log__c where Alternative_Answer__c IN : recordIds];
        if(logs != null && logs.size() > 0){
            delete logs;
        }
    }
    if(RFxIntegrationSchedular.actionFromSchedular == false) {
        if(Trigger.isdelete) {
            for(avnio__AlternativeAnswer__c alternativeanswerobj : Trigger.old) {
                if(alternativeanswerobj.GSX_Integrated_Response__c) {
                    alternativeanswerobj.addError('You can not modify the integrated records');
                }
            }
        }
         if(Trigger.isupdate) {
            for(avnio__AlternativeAnswer__c alternativeanswerobj : Trigger.new) {
                if(alternativeanswerobj.GSX_Integrated_Response__c) {
                  alternativeanswerobj.addError('You can not modify the integrated records');
                }
            }
        }
    }
}