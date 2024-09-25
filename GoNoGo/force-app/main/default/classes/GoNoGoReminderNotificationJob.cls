global with sharing class GoNoGoReminderNotificationJob implements Database.Batchable<sObject>, Schedulable{

    public static Id currentOpportunityId;
    public static Id answerId;

    global void execute(SchedulableContext SC) {
        Database.executeBatch(this);
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
        Integer reminderDays = 3;
        if(gonogosetting != null && gonogosetting.Days_For_Reminder_Notification__c != null){
            reminderDays = Integer.valueOf(gonogosetting.Days_For_Reminder_Notification__c);
        }
        Date dateToFilter = System.today().addDays(-Integer.valueOf(reminderDays));
        Date dateToFilterTill = dateToFilter.addDays(1);
        String queryStr ='SELECT id, Opportunity__c FROM Go_No_Go_Answer__c where (Status_Label__c = null OR Status_Label__c = \'Pending\') AND Opportunity__c != null AND createddate > :dateToFilter AND createddate < :dateToFilterTill';
        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext bc, List<Go_No_Go_Answer__c> submissionList){
        System.enqueueJob(new SendRemiderQueue(submissionList));
    }

    public void finish(Database.BatchableContext bc){

    }

    public class SendRemiderQueue implements Queueable, Database.AllowsCallouts {
        List<Go_No_Go_Answer__c> gonogosubmissions = new List<Go_No_Go_Answer__c>();
        
        public SendRemiderQueue(List<Go_No_Go_Answer__c> gonogosubmissions) {
            this.gonogosubmissions = gonogosubmissions;
        }
    
        public void execute(QueueableContext context) {
            try{
                Set<Id> configIdsDone = new Set<Id>();
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
                    String emailTemplateName = 'Go/No Go Reminder Email Template';
                    EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE name =:emailTemplateName];
                    List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                    for(Id configId : configIdsToOwnerMap.keySet()){
                        
                    }
                }
                
                if(configIdsToOwnerMap.size() > 0){
                    String emailTemplateName = 'Go/No Go Reminder Email Template';
                    EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE name =:emailTemplateName];
                    List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                    for (Go_No_Go_Answer__c ans : gonogosubmissions) {
                        currentOpportunityId = ans.Opportunity__c;
                        answerId = String.valueOf(ans.Id);
                        List<GoNoGoController.LinkedSubmissionWrapper> linkedWrapper = GoNoGoController.getLinkedSubmissions(answerId);
                        if(linkedWrapper != null && linkedWrapper.size() > 0){
                            for(GoNoGoController.LinkedSubmissionWrapper lsw : linkedWrapper){
                                if(lsw.configId != null && lsw.score != null && !lsw.score.equalsIgnoreCase('Pending')){
                                    configIdsDone.add(lsw.configId);
                                }
                            }
                        }
                        gonogosubmissions.remove(0);
                        break;
                    }

                    for(Id configId : configIdsToOwnerMap.keySet()){
                        if(configIdsDone.contains(configId)){
                            continue;
                        }
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
                    
                    if(gonogosubmissions.size() > 0){
                        System.enqueueJob(new SendRemiderQueue(gonogosubmissions));
                    }
                }
            }catch(Exception callException){}
        }
    }
}