@isTest
public with sharing class ReplaceFormattedAnswerBatchTest {
    
    @isTest
    public static void ReplaceFormattedAnswerBatchBatchTest(){
        Test.startTest();
        avnio__Response__c response = new avnio__Response__c();
        response.avnio__PrimaryQuestion__c = 'test q';
        response.avnio__Answer__c = '<p><span style="font-family: sans-serif; font-size: 12px;">Yes, this is a core functionality of Salesforce and Vlocity. When using OmniScript, “Next” and “Previous” buttons exist to help customers navigate through the guided process. </span></p>';
        response.FontSizes__c = '12px';
        response.FontStyles__c = 'sans-serif';
        insert response;
        ReplaceFormattedAnswerBatch ba = new ReplaceFormattedAnswerBatch('avnio__Response__c',true);
        Database.executebatch(ba);
        Test.stopTest();
        List<avnio__Response__c> resp = [select id,avnio__Answer__c,FontSizes__c,FontStyles__c from avnio__Response__c];
        System.assert(resp[0].avnio__Answer__c != null);
    }
    
}