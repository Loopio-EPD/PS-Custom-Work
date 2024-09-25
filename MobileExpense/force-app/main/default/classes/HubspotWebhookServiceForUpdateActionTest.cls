/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : HubspotWebhookServiceForUpdateActionTest
* Details : Test class for HubspotWebhookServiceForUpdateAction
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

@isTest
public with sharing class HubspotWebhookServiceForUpdateActionTest 
{
    
    @testSetup
    private static void createData(){
        List<avnio__Project__c> projects = new List<avnio__Project__c>();
        projects.add(new avnio__Project__c(
                avnio__ProjectName__c = 'Test Project',
            	Hubspot_Deal_Id__c = '10315463012'
        	)
        );

        insert projects;
    }
    
    @IsTest
    static void updateRecord_Test1() {
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        avnio__Project__c projectInput = [SELECT Id FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/updateRequiredRecord/';       
        String postData = '{"size__c":"S","dealname":"Test Deal","dealstage":14406871,"hs_object_id":10315463012,"amount":2000,"sq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jxQAC","cq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jsQAC","hubspot_owner_id":228671153,"rfi_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jnQAC","avnio_project_type":"RFI"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        HubspotWebhookServiceForUpdateAction.updateRecord();
        Test.stopTest();
    }
    
    @IsTest
    static void updateRecord_Test2() {
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        avnio__Project__c projectInput = [SELECT Id FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/updateRequiredRecord/';       
        String postData = '{"size__c":"S","dealname":"Test Deal","dealstage":14406871,"hs_object_id":10315463012,"amount":30000,"sq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jxQAC","cq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jsQAC","hubspot_owner_id":228671153,"rfi_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jnQAC","avnio_project_type":"RFI"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        HubspotWebhookServiceForUpdateAction.updateRecord();
        Test.stopTest();
    }
    
    @IsTest
    static void updateRecord_Test3() {
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        avnio__Project__c projectInput = [SELECT Id FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/updateRequiredRecord/';       
        String postData = '{"size__c":"S","dealname":"Test Deal","dealstage":14406871,"hs_object_id":10315463012,"amount":80000,"sq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jxQAC","cq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jsQAC","hubspot_owner_id":228671153,"rfi_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jnQAC","avnio_project_type":"RFI"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        HubspotWebhookServiceForUpdateAction.updateRecord();
        Test.stopTest();
    }
    
    @IsTest
    static void updateRecord_Test4() {
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        avnio__Project__c projectInput = [SELECT Id FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/updateRequiredRecord/';       
        String postData = '{"size__c":"S","dealname":"Test Deal","dealstage":14406871,"hs_object_id":10315463012,"amount":102000,"sq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jxQAC","cq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jsQAC","hubspot_owner_id":228671153,"rfi_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jnQAC","avnio_project_type":"RFI"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        HubspotWebhookServiceForUpdateAction.updateRecord();
        Test.stopTest();
    }
 
}