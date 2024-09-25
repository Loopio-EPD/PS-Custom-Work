@istest
public class CompareQuestionsControllerTest {
    public static testMethod void fetchDefaultRecordTest() {
        avnio__Project__c  proj = new avnio__Project__c  ();
        proj.avnio__ProjectName__c = 'test proj';
        insert proj;
        
        Account acc = new Account();
        acc.name = 'test';
        insert acc;

        CompareQuestionsController.fetchDefaultRecord(proj.id);
        CompareQuestionsController.fetchLookupData('test','avnio__project__c','',proj.id);
        CompareQuestionsController.fetchLookupData('test','account',acc.id,'');
    }

    public static testMethod void updateProjectQuestionsTest() {
        avnio__Project__c  proj = new avnio__Project__c  ();
        proj.avnio__ProjectName__c = 'test proj';
        insert proj;
        
        Account acc = new Account();
        acc.name = 'test';
        insert acc;

        CompareQuestionsController.ResponseWrapper res = new CompareQuestionsController.ResponseWrapper();
        List<CompareQuestionsController.ProjectQuestionWrapper> queslist = new List<CompareQuestionsController.ProjectQuestionWrapper>();
        CompareQuestionsController.ProjectQuestionWrapper que = new CompareQuestionsController.ProjectQuestionWrapper();
        que.isChanged = true;
        que.currentAnswer = 'rest';
        que.addPTag = true;
        queslist.add(que);
        res.projectQuestionWrapperList = queslist;
        Boolean ans = CompareQuestionsController.updateProjectQuestions(JSON.serialize(res));
    }

    public static testMethod void getRelatedProjectQuestionsTest() {
        Account acc = new Account();
        acc.name = 'test';
        insert acc;

        avnio__Project__c  proj = new avnio__Project__c  ();
        proj.avnio__ProjectName__c = 'test proj';
        proj.avnio__AccountId__c = acc.Id;
        insert proj;

        avnio__ProjectQuestion__c pq = new avnio__ProjectQuestion__c();
        pq.avnio__Answer__c = '<p>test</p>';
        pq.avnio__Question__c = 'tw';
        pq.avnio__ProjectId__c = proj.Id;
        insert pq;

        avnio__Project__c  proj1 = new avnio__Project__c  ();
        proj1.avnio__ProjectName__c = 'test proj1';
        insert proj1;
        
        avnio__ProjectQuestion__c pq1 = new avnio__ProjectQuestion__c();
        pq1.avnio__Answer__c = '<p>test</p>';
        pq1.avnio__Question__c = 'tw';
        pq1.avnio__ProjectId__c = proj1.Id;
        insert pq1;

        CompareQuestionsController.ResponseWrapper ans = CompareQuestionsController.getRelatedProjectQuestions(proj.Id,proj1.Id);
    }
}