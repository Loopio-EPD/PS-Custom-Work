@isTest
public with sharing class ReplaceLinksBatchTest {
    
    @isTest
    public static void ReplaceLinksBatchTestTest(){
        Test.startTest();
        avnio__Response__c response = new avnio__Response__c();
        response.avnio__PrimaryQuestion__c = 'test q';
        response.avnio__Answer__c = '<p><span style="font-family: sans-serif; font-size: 12px;"> http://abc.com Yes, this is a core functionality of Salesforce and https://abc.com Vlocity. When using OmniScript, “Next” and “Previous” buttons exist to help customers navigate through the guided process. </span></p>';
        response.Links_Formatting_Required__c = true;
        insert response;
        ReplaceLinksBatch ba = new ReplaceLinksBatch('avnio__Response__c');
        Database.executebatch(ba);
        Test.stopTest();
        List<avnio__Response__c> resp = [select id,avnio__Answer__c from avnio__Response__c];
        System.assert(resp[0].avnio__Answer__c == '<p><span style="font-family: sans-serif; font-size: 12px;"> <a href="http://abc.com" target="_blank">http://abc.com</a> Yes, this is a core functionality of Salesforce and <a href="https://abc.com" target="_blank">https://abc.com</a> Vlocity. When using OmniScript, “Next” and “Previous” buttons exist to help customers navigate through the guided process. </span></p>');
    }

    @isTest
    public static void ReplaceLinksBatchTestTest1(){
        Test.startTest();
        avnio__Response__c response = new avnio__Response__c();
        response.avnio__PrimaryQuestion__c = 'test q';
        response.avnio__Answer__c = '<a href="https://docs.mulesoft.com/design-center/" target="_blank">https://docs.mulesoft.com/design-center/</a> <a href="http://docs.mulesoft.com/design-center/" target="_blank">http://docs.mulesoft.com/design-center/</a>';
        response.Links_Formatting_Required__c = true;
        insert response;
        ReplaceLinksBatch ba = new ReplaceLinksBatch('avnio__Response__c');
        Database.executebatch(ba);
        Test.stopTest();
        List<avnio__Response__c> resp = [select id,avnio__Answer__c from avnio__Response__c];
        System.assert(resp[0].avnio__Answer__c == '<a href="https://docs.mulesoft.com/design-center/" target="_blank">https://docs.mulesoft.com/design-center/</a> <a href="http://docs.mulesoft.com/design-center/" target="_blank">http://docs.mulesoft.com/design-center/</a>');
    }
    
}