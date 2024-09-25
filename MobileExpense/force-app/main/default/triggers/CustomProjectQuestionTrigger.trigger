trigger CustomProjectQuestionTrigger on avnio__ProjectQuestion__c (before insert, before update) {
    if(Trigger.isinsert){
        CustomProjectQuestionTriggerHandler.beforeAction(Trigger.new, null);
    }
    if(Trigger.isupdate){
        CustomProjectQuestionTriggerHandler.beforeAction(Trigger.new, Trigger.oldMap);
    }
}