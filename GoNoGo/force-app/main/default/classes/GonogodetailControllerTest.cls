@IsTest
public with sharing class GonogodetailControllerTest {

    @IsTest
    static void testProjectQuestionListController_Custom(){
       	Opportunity opp = new Opportunity();
        opp.Closedate= System.today();
        opp.Name = 'test';
        opp.StageName = 'IsWon';
        insert opp;
        
        Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
        answer.Opportunity__c = opp.Id;
        insert answer;
        
       	GonogodetailController gng = new GonogodetailController();
       	gng.recordId = answer.Id;
        System.assert(gng.projectSO != null);
    }
}