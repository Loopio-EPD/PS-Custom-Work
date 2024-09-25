/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : HubspotWebhookServiceTest
* Details : Test Class for HubspotWebhookService
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

@isTest
public with sharing class HubspotWebhookServiceTest {

    @IsTest
    static void test_createRecord1() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/createRequiredRecord/';       
        String postData = '{"size__c":"S","received_date":"1346524199000","dealname":"Test Deal","dealtype":"TestDealType","win_reason":"Business Rules","win_information__c":"test info","project_status":"Submitted","amount":2000,"dealstage":14406871,"projectid":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1k2QAC","hs_object_id":10315463012,"sharepoint_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1k2QAC","sq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jxQAC","cq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jsQAC","hubspot_owner_id":228671153,"rfi_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jnQAC","avnio_project_type":"RFI"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        HubspotWebhookService.createRecord();
        Test.stopTest();
    }

    @IsTest
    static void test_createRecord2() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/createRequiredRecord/';       
        String postData = '{"size__c":"S","received_date":"1346524199000","dealname":"Test Deal","dealtype":"TestDealType","win_reason":"Business Rules","win_information__c":"test info","project_status":"Submitted","amount":30000,"dealstage":14406871,"projectid":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1k2QAC","hs_object_id":10315463012,"sharepoint_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1k2QAC","sq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jxQAC","cq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jsQAC","hubspot_owner_id":228671153,"rfi_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jnQAC","avnio_project_type":"RFI"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        HubspotWebhookService.createRecord();
        Test.stopTest();
    }

    @IsTest
    static void test_createRecord3() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/createRequiredRecord/';       
        String postData = '{"size__c":"S","received_date":"1346524199000","dealname":"Test Deal","dealtype":"TestDealType","win_reason":"Business Rules","win_information__c":"test info","project_status":"Submitted","amount":82000,"dealstage":14406871,"projectid":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1k2QAC","hs_object_id":10315463012,"sharepoint_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1k2QAC","sq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jxQAC","cq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jsQAC","hubspot_owner_id":228671153,"rfi_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jnQAC","avnio_project_type":"RFP"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        HubspotWebhookService.createRecord();
        Test.stopTest();
    }

    @IsTest
    static void test_createRecord4() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/createRequiredRecord/';       
        String postData = '{"size__c":"S","received_date":"1346524199000","dealname":"Test Deal","dealtype":"TestDealType","win_reason":"Business Rules","win_information__c":"test info","project_status":"Submitted","amount":122000,"dealstage":14406871,"projectid":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1k2QAC","hs_object_id":10315463012,"sharepoint_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1k2QAC","sq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jxQAC","cq_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jsQAC","hubspot_owner_id":228671153,"rfi_project_link":"https://mobilexpense--avniodev.sandbox.my.salesforce.com/a093G000000F1jnQAC"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        HubspotWebhookService.createRecord();
        Test.stopTest();
    }

    @IsTest
    static void test1_updateCompanyOnProject() {
        hubspot_integration__c integrationSetting = hubspot_integration__c.getOrgDefaults();
        integrationSetting.Access_Token__c = 'abc';
        integrationSetting.API_Endpoint__c = 'apiendpoint';
        integrationSetting.Hubspot_Org_URL__c = 'abc/xyz';
        upsert integrationSetting;
        Test.startTest();
        List<Recordtype> rtypeList = [select id, name, SobjectType, isactive from recordtype where SobjectType='avnio__Project__c' and isactive=true];
        avnio__Project__c project = new avnio__Project__c();
        project.avnio__ProjectName__c = 'dealName';
        project.avnio__DueDate__c = Datetime.now();
        project.avnio__Status__c = 'Request';
        project.recordTypeId = rtypeList[0].Id;
        Test.setMock(HttpCalloutMock.class, new HubspotCalloutMock());
        HubspotWebhookService.updateCompanyOnProject(project,'2728282');
        Test.stopTest();
        List<avnio__Project__c> projectList = [select id,name,avnio__ProjectName__c from avnio__Project__c where avnio__ProjectName__c = 'dealName'];
        System.assertEquals(projectList.size(), 1);
        System.assertEquals(projectList[0].avnio__ProjectName__c, 'dealName');
    }
    
    @IsTest
    static void test2_updateCompanyOnProject() {
        hubspot_integration__c integrationSetting = hubspot_integration__c.getOrgDefaults();
        integrationSetting.Access_Token__c = 'abc';
        integrationSetting.API_Endpoint__c = 'apiendpoint';
        integrationSetting.Hubspot_Org_URL__c = 'abc/xyz';
        upsert integrationSetting;
        Account account = new Account();
        account.name = 'Account Test';
        account.Hubspot_Company_Id__c = '1178179';
        insert account;
        Test.startTest();
        List<Recordtype> rtypeList = [select id, name, SobjectType, isactive from recordtype where SobjectType='avnio__Project__c' and isactive=true];
        avnio__Project__c project = new avnio__Project__c();
        project.avnio__ProjectName__c = 'dealName';
        project.avnio__DueDate__c = Datetime.now();
        project.avnio__Status__c = 'Request';
        project.recordTypeId = rtypeList[0].Id;
        Test.setMock(HttpCalloutMock.class, new HubspotCalloutMock());
        HubspotWebhookService.updateCompanyOnProject(project,'2728282');
        Test.stopTest();
        List<avnio__Project__c> projectList = [select id,name,avnio__ProjectName__c from avnio__Project__c where avnio__ProjectName__c = 'dealName'];
        System.assertEquals(projectList.size(), 1);
        System.assertEquals(projectList[0].avnio__ProjectName__c, 'dealName');
    }

    @IsTest
    static void test_updateAccountOnProjectFuture() {
        Test.startTest();
        Account account = new Account();
        account.name = 'Account Test';
        account.Hubspot_Company_Id__c = '1178179';
        insert account;
        List<Recordtype> rtypeList = [select id, name, SobjectType, isactive from recordtype where SobjectType='avnio__Project__c' and isactive=true];
        avnio__Project__c project = new avnio__Project__c();
        project.avnio__ProjectName__c = 'dealName';
        project.avnio__DueDate__c = Datetime.now();
        project.avnio__Status__c = 'Request';
        project.recordTypeId = rtypeList[0].Id;
        insert project;
        Test.setMock(HttpCalloutMock.class, new HubspotCalloutMock());
        HubspotWebhookService.updateAccountOnProjectFuture(account.id,project.id);
        Test.stopTest();
        List<avnio__Project__c> projectList = [select id,name,avnio__AccountId__c from avnio__Project__c where avnio__AccountId__c = :account.id];
        System.assertEquals(projectList.size(), 1);
        System.assertEquals(projectList[0].avnio__AccountId__c, account.id);
    }
    
    
    public with sharing class HubspotCalloutMock implements HttpCalloutMock {
        public HttpResponse respond( HttpRequest req ) {
            String endpoint = req.getEndpoint(); 
            HttpResponse res = new HttpResponse();
            if(endpoint.endsWith('/associations/Company/?limit=1')) {
                res.setBody('{"id":"1178179"}');
            }
            else if(endpoint.endsWith('&properties=numberofemployees&limit=1')){
                res.setBody('{"id":"192289","properties":{"name":"abc"}}'); 
            }
            else if(endpoint.endsWith('deals/v1/batch-async/update')){
                res.setBody('Success! Updated successfully.'); 
            }
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}