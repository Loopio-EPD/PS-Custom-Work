public with sharing class OpportunityTriggerController {

    public static void afterInsert(List<Opportunity> newItems){
        GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
        if(gonogosetting != null && gonogosetting.Assignee_Notification__c && gonogosetting.Opportunity_Stage_For_Notification__c != null && String.isNotBlank(gonogosetting.Opportunity_Stage_For_Notification__c)){
            Set<Id> oppIds = new Set<Id>();
            String oppStatusToTrigger = gonogosetting.Opportunity_Stage_For_Notification__c;
            for(Opportunity opp : newItems){
                if(opp.StageName != null && String.isNotBlank(opp.StageName) && oppStatusToTrigger.equalsIgnoreCase(opp.StageName)){
                    oppIds.add(opp.Id);
                }
            }
            if(oppIds.size() > 0){
                System.enqueueJob(new SendNotificationQueue(oppIds));
            }
        }
    }
    
    public static void afterUpdate(List<Opportunity> newItems, Map<Id,Opportunity> oldItems){
        GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
        if(gonogosetting != null && gonogosetting.Assignee_Notification__c && gonogosetting.Opportunity_Stage_For_Notification__c != null && String.isNotBlank(gonogosetting.Opportunity_Stage_For_Notification__c)){
            Set<Id> oppIds = new Set<Id>();
            String oppStatusToTrigger = gonogosetting.Opportunity_Stage_For_Notification__c;
            for(Opportunity opp : newItems){
                if(opp.StageName != null && String.isNotBlank(opp.StageName) && oppStatusToTrigger.equalsIgnoreCase(opp.StageName)){
                    String oldStatus = oldItems.get(opp.Id).StageName;
                    if(oldStatus != opp.StageName){
                        oppIds.add(opp.Id);
                    }
                }
            }
            if(oppIds.size() > 0){
                System.enqueueJob(new SendNotificationQueue(oppIds));
            }
        }
    }
}