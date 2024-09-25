@isTest
public class CustomProjectQuestionTHTest {
    
    @isTest
    public static void triggerTest() {
        Test.startTest();
        avnio__Project__c project = new avnio__Project__c();
        project.avnio__ProjectName__c = 'Test Project';
        insert project;
        project.avnio__Configuration__c = '{"sheetConfigMap":{"3":{"sheetOrder":1,"sheetNameAsCategory":false,"sheetName":"Volumes ","sheetId":"3","casecadeSubcategory":true,"casecadeCategory":true},"1":{"sheetOrder":0,"sheetNameAsCategory":false,"sheetName":"RfQ_Travel_requirements_ 2021","sheetId":"1","casecadeSubcategory":true,"casecadeCategory":true}},"reviewerConfig":{"readOnlyCompletedQuestion":false,"projectQuestionReviewType":"Advanced","projectOwnerAsReviewer":false,"projectOwnerAsAssignee":true,"enableProjectQuestionReview":true,"assigneeToComplete":true,"allowReviewerToEdit":true,"allowReviewerToComplete":true},"projectConfig":{"compliances":[{"value":null,"type":"PICKLIST","scope":"Project","required":false,"order":null,"options":[{"value":"Yes","label":"Yes"},{"value":"No","label":"No"}],"label":"Compliancy statement","id":"CA-1","helpText":null,"cellAddressExact":null,"cellAddress":null},{"value":null,"type":"READONLYTEXT","scope":"Project","required":false,"order":null,"options":[],"label":"Question Number","id":"CA-2","helpText":null,"cellAddressExact":null,"cellAddress":null}]},"fileConfigMap":{"0683G000000F9stQAC":{"compliances":[]}}}';
		update project;
		avnio__ProjectQuestion__c pq = new avnio__ProjectQuestion__c();
        pq.avnio__ProjectId__c = project.id;
        pq.avnio__Question__c = 'testques';
        pq.avnio__Answer__c = 'testans';
        pq.avnio__Configuration__c = '{"subcategoryCellAddress":"B68","QuestionReferencePaths":null,"QuestionPath":null,"compliances":[{"value":"7.7","type":null,"scope":null,"required":null,"order":null,"options":null,"label":null,"id":"CA-2","helpText":null,"cellAddressExact":null,"cellAddress":"A76"}],"categoryCellAddress":"B68","AnswerReferencePaths":null,"AnswerPath":null}';
        insert pq;
        pq.avnio__Answer__c = 'ans2';
        update pq;
        Test.stopTest();
        avnio__ProjectQuestion__c pqresult = [select id, Question_Number__c from avnio__ProjectQuestion__c where id = :pq.id LIMIT 1];
        System.assertEquals(pqresult.Question_Number__c,'7.7');
    }
}