public with sharing class GonogodetailController {
    public String recordId {get; set;}
    public String whichEmail {get; set;}
    public ApprovalTempWrapper projectSO{
        get {
          if(recordId!=null){
            String objectName = getObjectName(Id.valueOf(recordId));
            if(objectName != null && objectName.equalsIgnoreCase('Go/No-Go Submission')){
                if(whichEmail != null && whichEmail.equalsIgnoreCase('completion')){
                    List<Go_No_Go_Answer__c> projects = Database.query('Select Id, Name, Opportunity__r.Name, Opportunity__r.Owner.Name, Owner.Name, Go_No_Go_Score__c FROM Go_No_Go_Answer__c where id =:recordId');
                    if(!projects.isEmpty()){
                        ApprovalTempWrapper approvalTempWrapper = new ApprovalTempWrapper();
                        approvalTempWrapper.actorName = projects[0].Opportunity__r.Owner.Name;
                        approvalTempWrapper.recid = recordId;
                        approvalTempWrapper.name = projects.get(0).name;
                        approvalTempWrapper.oppName = projects.get(0).Opportunity__r.Name;
                        approvalTempWrapper.ownername = projects.get(0).Owner.Name;
                        approvalTempWrapper.score = String.valueOf(GoNoGoController.currentGoNoGoScore);
                        approvalTempWrapper.sentUserNameSentence = GoNoGoController.currentConfigName;
                        return approvalTempWrapper;
                    }
                }
                else{
                    List<Go_No_Go_Answer__c> projects = Database.query('Select Id, Name, Opportunity__r.Name, Owner.Name, Go_No_Go_Score__c FROM Go_No_Go_Answer__c where id =:recordId');
                    if(!projects.isEmpty()){
                        ApprovalTempWrapper approvalTempWrapper = new ApprovalTempWrapper();
                        List<ProcessInstanceWorkitem> workItemLst = [SELECT id, Actor.FirstName, CreatedBy.FirstName FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId=:recordId];
                        approvalTempWrapper.sentUserNameSentence = 'A Go/No-Go Submission has been submitted for your review.';
                        if(workItemLst.size() > 0){
                            approvalTempWrapper.approvalrecid = workItemLst[0].id;
                            approvalTempWrapper.actorName = workItemLst[0].Actor.FirstName;
                            approvalTempWrapper.sentUserNameSentence = workItemLst[0].CreatedBy.FirstName + ' has submitted a Go/No-Go Submission for your review.';
                        }
                        approvalTempWrapper.recid = recordId;
                        approvalTempWrapper.name = projects.get(0).name;
                        approvalTempWrapper.oppName = projects.get(0).Opportunity__r.Name;
                        approvalTempWrapper.ownername = projects.get(0).Owner.Name;
                        approvalTempWrapper.score = String.valueOf(projects.get(0).Go_No_Go_Score__c);
                        return approvalTempWrapper;
                    }
                }
            }
            else{
                List<Go_No_Go_Configuration__c> configs = Database.query('Select Id, Name, Owner.Name FROM Go_No_Go_Configuration__c where id =:recordId');
                if(!configs.isEmpty()){
                    ApprovalTempWrapper approvalTempWrapper = new ApprovalTempWrapper();
                    approvalTempWrapper.name = configs.get(0).name;
                    approvalTempWrapper.ownername = configs.get(0).Owner.Name;
                    approvalTempWrapper.actorName = configs.get(0).Owner.Name;
                    Id oppID;
                    if(SendNotificationQueue.currentOpportunityId != null){
                        oppID = SendNotificationQueue.currentOpportunityId;
                    }
                    else if(GoNoGoController.currentOpportunityId != null){
                        oppID = GoNoGoController.currentOpportunityId;
                    }
                    else if(GoNoGoReminderNotificationJob.currentOpportunityId != null){
                        oppID = GoNoGoReminderNotificationJob.currentOpportunityId;
                    }

                    if(SendNotificationQueue.answerId != null){
                        approvalTempWrapper.recid = SendNotificationQueue.answerId;
                    }
                    else if(GoNoGoController.answerId != null){
                        approvalTempWrapper.recid = GoNoGoController.answerId;
                    }
                    else if(GoNoGoReminderNotificationJob.answerId != null){
                        approvalTempWrapper.recid = GoNoGoReminderNotificationJob.answerId;
                    }
                    else{
                        approvalTempWrapper.recid = oppID;
                    }
                    List<Opportunity> oppList = [select id, name, Owner.Name from Opportunity where id = :oppID WITH SECURITY_ENFORCED LIMIT 1];
                    if(oppList != null && oppList.size() > 0){
                        approvalTempWrapper.oppName = oppList.get(0).Name;
                        approvalTempWrapper.oppownername = oppList.get(0).Owner.Name;
                    }
                    return approvalTempWrapper;
                }
            }
          }
          return new ApprovalTempWrapper(); }
       set;
    }

    public static String getObjectName(ID recordId) {
        if(recordId == null){
            return '';
        }
        return recordId.getSObjectType().getDescribe().getLabel(); 
    }
    
    public with sharing class ApprovalTempWrapper{
        @auraEnabled public String recid {get;set;}
        @auraEnabled public String name {get;set;}
        @auraEnabled public String oppName {get;set;}
        @auraEnabled public String score {get;set;}
        @auraEnabled public String ownername {get;set;}
        @auraEnabled public String oppownername {get;set;}
        @auraEnabled public String approvalrecid {get;set;}
        @auraEnabled public String sentUserNameSentence {get;set;}
        @auraEnabled public String actorName {get;set;}
    }
}