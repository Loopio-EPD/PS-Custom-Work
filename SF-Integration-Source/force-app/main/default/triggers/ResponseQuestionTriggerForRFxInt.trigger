trigger ResponseQuestionTriggerForRFxInt on avnio__ResponseQuestion__c (after update, after delete) {
    if(Trigger.isupdate) {
        List<sobject> deletedresquestion = new List<sobject> ();
        for(avnio__ResponseQuestion__c resq : Trigger.new) {
            if(resq.avnio__IsDeleted__c == true && resq.avnio__IsDeleted__c != Trigger.oldMap.get(resq.id).avnio__IsDeleted__c) {
                   deletedresquestion.add(resq);
            }
        }
        if(deletedresquestion != null && deletedresquestion.size() > 0) {
            RFxIntegrationTriggerController.createDeleteLogs(deletedresquestion);
        }
    }
    if(Trigger.isdelete) {
        RFxIntegrationTriggerController.createDeleteLogs(Trigger.old);
    }
}