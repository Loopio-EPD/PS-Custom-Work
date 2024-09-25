@isTest
public with sharing class FormatResponseControllerTest {
    
    @isTest
    public static void FormatResponseControllerBatchTest(){
        Test.startTest();
        avnio__Response__c response = new avnio__Response__c();
        response.avnio__PrimaryQuestion__c = 'test q';
        response.avnio__Answer__c = '<p><span style="font-family: sans-serif; font-size: 12px;">Yes, this is a core functionality of Salesforce and Vlocity. When using OmniScript, “Next” and “Previous” buttons exist to help customers navigate through the guided process. </span></p>';
        insert response;
        FormatResponseController ba = new FormatResponseController('avnio__Response__c');
        Database.executebatch(ba);
        Test.stopTest();
        List<avnio__Response__c> resp = [select id,FontSizes__c,FontStyles__c from avnio__Response__c];
        System.assertEquals(resp[0].FontSizes__c, '12px');
        System.assertEquals(resp[0].FontStyles__c, 'sans-serif');
    }
    
}