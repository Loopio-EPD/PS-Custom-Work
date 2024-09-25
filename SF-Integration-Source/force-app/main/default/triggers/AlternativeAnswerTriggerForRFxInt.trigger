trigger AlternativeAnswerTriggerForRFxInt on avnio__AlternativeAnswer__c (after update, after delete) {
     if(Trigger.isupdate) {
        List<sobject> deletedaltanswer = new List<sobject> ();
        for(avnio__AlternativeAnswer__c altanswer : Trigger.new) {
            if(altanswer.avnio__IsDeleted__c == true && altanswer.avnio__IsDeleted__c != Trigger.oldMap.get(altanswer.id).avnio__IsDeleted__c) {
                   deletedaltanswer.add(altanswer);
            }
        }
        if(deletedaltanswer != null && deletedaltanswer.size() > 0) {
            RFxIntegrationTriggerController.createDeleteLogs(deletedaltanswer);
        }
    }
    if(Trigger.isdelete) {
        RFxIntegrationTriggerController.createDeleteLogs(Trigger.old);
    }
}