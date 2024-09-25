public class SendNotificationQueue implements Queueable, Database.AllowsCallouts {
    public static Id currentOpportunityId;
    public static Id answerId;
    Set<Id> oppIds = new Set<Id>();
    
    public SendNotificationQueue(Set<Id> oppIds) {
        this.oppIds = oppIds;
    }

    public void execute(QueueableContext context) {
        try{
            Map<Id,Id> configIdsToOwnerMap = new Map<Id,Id>();
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
            String defaultConfigName;
            if(gonogosetting != null){
                defaultConfigName = gonogosetting.Default_Configuration_Name__c;
            }
            List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id, Go_No_Go_Configuration__c, Go_No_Go_Configuration__r.OwnerId from Go_No_Go_Linked_Configuration__c WITH SECURITY_ENFORCED];
            if(linkedConfigs != null && linkedConfigs.size() > 0){
                for(Go_No_Go_Linked_Configuration__c lc : linkedConfigs){
                    configIdsToOwnerMap.put(lc.Go_No_Go_Configuration__c, lc.Go_No_Go_Configuration__r.OwnerId);
                }
            }
            else if(defaultConfigName != null && String.isNotBlank(defaultConfigName)){
                Go_No_Go_Configuration__c configRec = [select id, ownerId from Go_No_Go_Configuration__c WHERE Name = :defaultConfigName WITH SECURITY_ENFORCED order by createddate asc limit 1];
                if(configRec != null){
                    configIdsToOwnerMap.put(configRec.Id, configRec.ownerId);
                }
            }
            
            if(configIdsToOwnerMap.size() > 0){
                String emailTemplateName = 'Go/No Go Submission Notification Email Template';
                EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE name =:emailTemplateName];
                List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                for (string oppId : oppIds) {
                    currentOpportunityId = oppId;
                    break;
                }
                //if(configIdsToOwnerMap.size() > 1){
                    Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
                    answer.Opportunity__c = currentOpportunityId;
                    answer.Status_Label__c = 'Pending';
                    insert answer;
                    answerId = answer.Id;
                //}
                oppIds.remove(currentOpportunityId);
                for(Id configId : configIdsToOwnerMap.keySet()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    mail.setTargetObjectId(configIdsToOwnerMap.get(configId));
                    mail.setTemplateId(et.id); 
                    mail.setWhatId(configId); 
                    mail.setBccSender(false); 
                    mail.setUseSignature(false); 
                    mail.setSaveAsActivity(false);
                    emailMessageList.add(mail);                            
                }
                if(emailMessageList.size() > 0){
                    Messaging.sendEmail(emailMessageList);
                }
                
                if(oppIds.size() > 0){
                    System.enqueueJob(new SendNotificationQueue(oppIds));
                }
            }
        }catch(Exception callException){}
    }
}