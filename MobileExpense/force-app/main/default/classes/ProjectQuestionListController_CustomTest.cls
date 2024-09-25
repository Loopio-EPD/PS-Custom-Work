@IsTest
public with sharing class ProjectQuestionListController_CustomTest {
	
    @testSetup
    private static void createData(){
        List<avnio__Project__c> projects = new List<avnio__Project__c>();
        projects.add(new avnio__Project__c(
                avnio__ProjectName__c = 'Test Project'
            )
        );

        insert projects;
    }
    
    @IsTest
    static void testProjectQuestionListController_Custom(){
       
       ProjectQuestionListController_Custom p = new ProjectQuestionListController_Custom();
       
    }
    
    @IsTest
    static void testResponse(){
        avnio__ProjectQuestion__c pq = new avnio__ProjectQuestion__c();
        pq.avnio__Answer__c = 'abc';
        pq.avnio__Question__c = 'anc';
        insert pq;
        
       avnio__Project__c projectInput = [SELECT Id FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
       ProjectQuestionListController_Custom p = new ProjectQuestionListController_Custom();
        p.currentUserId = UserInfo.getUserId();
        p.recordId = pq.Id;
		ProjectQuestionListController_Custom.ProjectQuestionResponse pr = p.response;
        String USERTYPE_ASSIGNEE = ProjectQuestionListController_Custom.USERTYPE_ASSIGNEE;
        String USERTYPE_ASSIGNEEREMINDER = ProjectQuestionListController_Custom.USERTYPE_ASSIGNEEREMINDER;
        String USERTYPE_REVIEWER = ProjectQuestionListController_Custom.USERTYPE_REVIEWER;
        String USERTYPE_REVIEWERREMINDER = ProjectQuestionListController_Custom.USERTYPE_REVIEWERREMINDER;
    }
    
    @IsTest
    static void testProjectQuestion(){
       ProjectQuestionListController_Custom.ProjectQuestion p = new ProjectQuestionListController_Custom.ProjectQuestion();
      	p.questionId = 'abc';
        p.questionName = 'abc';
        p.dueDate = System.today();
        p.status = 'abc';
        p.comment = 'abc';
        p.questionUrl = 'abc';
        p.projectId = 'abc';
        ProjectQuestionListController_Custom.ProjectQuestionResponse pqr = new ProjectQuestionListController_Custom.ProjectQuestionResponse();
        pqr.projectQuestionList = new List<ProjectQuestionListController_Custom.ProjectQuestion>();
    }
    
    @IsTest
    static void testGetterSetter(){
       ProjectQuestionListController_Custom p = new ProjectQuestionListController_Custom();
      	p.flowDevName = 'abc';
        p.questionStatus = 'abc';
        p.isOnlyReminder = true;
    }
    
    @IsTest
    static void testconvertProjectQuestion(){
      	avnio__ProjectQuestion__c pq = new avnio__ProjectQuestion__c();
        pq.avnio__Answer__c = 'abc';
        pq.avnio__Question__c = 'anc';
        ProjectQuestionListController_Custom p = new ProjectQuestionListController_Custom();
        ProjectQuestionListController_Custom.ProjectQuestion p1  = p.convertProjectQuestion(pq);
    }
}