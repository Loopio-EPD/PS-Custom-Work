public with sharing class ProjectQuestionListController_Custom {

    public String currentUserId  {get; set;}
    public String recordId {get; set;}
    public String flowDevName {get; set;}
    public String questionStatus {get; set;}
    public boolean isOnlyReminder {get; set;}

    public static String USERTYPE_ASSIGNEE {get {
        return 'ProjectQuestionAssignment';
    }}
    public static String USERTYPE_ASSIGNEEREMINDER {get {
        return 'ProjectQuestionAssignmentReminder';
    }}
    public static String USERTYPE_REVIEWER {get {
        return 'ProjectQuestionReviewerAssignment';
    }}
    public static String USERTYPE_REVIEWERREMINDER {get {
        return 'ProjectQuestionReviewerReminder';
    }}

    public String instanceURL {get; set;}
    public class ProjectQuestionResponse{
        public List<ProjectQuestion> projectQuestionList{get;set;}
        public Map<Id,ProjectQuestion> projectQuestionMap{get;set;}
        public String instanceURL{get;set;}

    }
    public  ProjectQuestionResponse response{get{
        ProjectQuestionResponse res = new ProjectQuestionResponse();
        Id currentUserId18D = currentUserId;
        String queryCondition = '';
        Map<Id,ProjectQuestion> quesMap = new Map<Id,ProjectQuestion>();
        List<String> fields = new List<String>(avnio__ProjectQuestion__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
                + ' select ' + String.join(fields, ',')
                + ' from avnio__ProjectQuestion__c'
                + ' where id=:recordId';
      
        for(avnio__ProjectQuestion__c projectQues : Database.query(soql)  ) {
            quesMap.put(projectQues.Id,convertProjectQuestion(projectQues));
        }
        
        res.projectQuestionMap = quesMap;
        if(quesMap != null && quesMap.size() > 0) {
            res.projectQuestionList = quesMap.values();
        }
        if(String.isNotBlank(currentUserId)){
            Boolean isCommunity = false;
            Set<String> objectFields = Schema.SObjectType.User.fields.getMap().keySet();
            if(objectFields.contains('isportalenabled')) {
                List<User> userRecords = (List<User>) (Database.query('SELECT Id, IsPortalEnabled FROM User WHERE Id = :currentUserId'));
                if(!userRecords.isEmpty()) isCommunity = (Boolean)userRecords[0].get('IsPortalEnabled');
            }
            if(isCommunity){
                avnio__RFxProjectConfiguration__c projectConfig = avnio__RFxProjectConfiguration__c.getInstance();
                if(projectConfig!=null && String.isNotBlank(projectConfig.avnio__QuestionCommunityURL__c)){
                    res.instanceURL = projectConfig.avnio__QuestionCommunityURL__c;
                }
            }else{
                res.instanceURL = System.URL.getOrgDomainUrl().toExternalForm()+ '/lightning/cmp/avnio__QuestionFullPage';
            }
        }
        
        return res;
    }}
    //public List<ProjectQuestion> projectQuestionList;

    public ProjectQuestion convertProjectQuestion(avnio__ProjectQuestion__c projectQues) {
        ProjectQuestion question = new ProjectQuestion();
        question.questionId = projectQues.Id;
        question.questionName =  projectQues.avnio__Question__c;
        question.status = projectQues.avnio__Status__c;
        question.dueDate = projectQues.avnio__DueDate__c;
        question.comment = projectQues.avnio__AssignmentComment__c;
        question.questionUrl = projectQues.avnio__ViewQuestion__c;
        question.projectId = projectQues.avnio__ProjectId__c;
        return question;
    }

  

    public ProjectQuestionListController_Custom() {
        instanceURL = System.URL.getOrgDomainUrl().toExternalForm();
        if(Apexpages.currentPage().getParameters().containsKey('id')) {
            recordId = Apexpages.currentPage().getParameters().get('id');
            currentUserId = Apexpages.currentPage().getParameters().get('userId');
            questionStatus = Apexpages.currentPage().getParameters().get('type');
            //fetchRecordDetail();
        }
    }

    public class ProjectQuestion {
        public String questionId {get; set;}
        public String questionName {get; set;}
        public Date dueDate {get; set;}
        public String status {get; set;}
        public String comment {get; set;}
        public String questionUrl {get; set;}
        public String projectId {get; set;}
    }

}