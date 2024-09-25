/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : ProjectTriggerForHubspotControllerTest
* Details : Test class for ProjectTriggerForHubspotController
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

@isTest
public with sharing class ProjectTriggerForHubspotControllerTest {
	
    @testSetup
    private static void createData(){
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        hubspot_integration__c integrationSetting = hubspot_integration__c.getOrgDefaults();
        integrationSetting.Access_Token__c = 'abc';
        integrationSetting.API_Endpoint__c = 'apiendpoint';
        integrationSetting.Hubspot_Org_URL__c = 'abc/xyz';
        upsert integrationSetting;
        List<Recordtype> rtypeList = [select id, name, SobjectType, isactive from recordtype where SobjectType='avnio__Project__c' and isactive=true];
        avnio__Project__c project = new avnio__Project__c();
        project.avnio__ProjectName__c = 'Test Project';
        project.avnio__DueDate__c = Datetime.now();
        project.avnio__Status__c = 'Request';
        project.Hubspot_Deal_Id__c = '1273';
        project.recordTypeId = rtypeList[0].Id;
        insert project;
    }

    @IsTest
    static void test_makeCallout1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        ProjectTriggerForHubspotController.makeCallout('','deals/v1/batch-async/update');
        Test.stopTest();
    }
    
    @IsTest
    static void test_onInsertProjectAfter() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        avnio__Project__c project = [SELECT Id,Hubspot_Deal_Id__c,avnio__RecordType__c,avnio__Status__c,avnio__DueDate__c FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
        Id recordTypeIdToUse = Schema.SObjectType.avnio__project__c.getRecordTypeInfosByDeveloperName().get('RFP').getRecordTypeId();
        project.recordTypeId = recordTypeIdToUse;
        List<avnio__Project__c> projectList = new List<avnio__Project__c>();
        projectList.add(project);
        ProjectTriggerForHubspotController.onInsertProjectAfter(projectList);
        Test.stopTest();
        //System.assertEquals(account.name, 'test');
    }
    
    @IsTest
    static void test_onUpdateProjectAfter1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        avnio__Project__c project = [SELECT Id,Hubspot_Deal_Id__c,avnio__RecordType__c,avnio__Status__c,avnio__DueDate__c FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
        Map<id,avnio__Project__c> testMap = new Map<id,avnio__Project__c>();
        testMap.put(project.id,project);
        List<avnio__Project__c> projectList1 = [select id,avnio__DueDate__c,avnio__Status__c,Hubspot_Deal_Id__c from avnio__Project__c];
        projectList1[0].avnio__Status__c = 'Done';
        ProjectTriggerForHubspotController.onUpdateProjectAfter(testMap,projectList1);
        Test.stopTest();
        //System.assertEquals(account.name, 'test');
    }

    @IsTest
    static void test_onUpdateProjectAfter2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        avnio__Project__c project = [SELECT Id,Hubspot_Deal_Id__c,avnio__RecordType__c,avnio__Status__c,avnio__DueDate__c FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
        project.Hubspot_Deal_stage__c = 'Complete';
        Map<id,avnio__Project__c> testMap = new Map<id,avnio__Project__c>();
        testMap.put(project.id,project);
        List<avnio__Project__c> projectList1 = [select id,avnio__DueDate__c,avnio__Status__c,Hubspot_Deal_Id__c from avnio__Project__c];
        projectList1[0].avnio__Status__c = null;
        ProjectTriggerForHubspotController.onUpdateProjectAfter(testMap,projectList1);
        Test.stopTest();
        //System.assertEquals(account.name, 'test');
    }

    @IsTest
    static void test_onUpdateProjectBefore() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        avnio__Project__c project = [SELECT Id,Hubspot_Deal_Id__c,avnio__RecordType__c,avnio__Status__c,avnio__DueDate__c,Hubspot_Deal_stage__c FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
        Map<id,avnio__Project__c> testMap = new Map<id,avnio__Project__c>();
        testMap.put(project.id,project);
        List<avnio__Project__c> projectList1 = [select id,avnio__DueDate__c,avnio__Status__c,Hubspot_Deal_Id__c,Hubspot_Deal_stage__c from avnio__Project__c];
        projectList1[0].avnio__Status__c = null;
        projectList1[0].Hubspot_Deal_stage__c = 'Complete';
        ProjectTriggerForHubspotController.onUpdateProjectBefore(testMap,projectList1);
        Test.stopTest();
        //System.assertEquals(account.name, 'test');
    }
    
    @IsTest
    static void test_sendEmails1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        List <avnio__Project__c> projects = [SELECT Id,Hubspot_Deal_Id__c,avnio__RecordType__c,avnio__Status__c,avnio__DueDate__c,Hubspot_Deal_stage__c,Hubspot_Created_By__c FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project'];
        projects[0].Hubspot_Created_By__c = userinfo.getuserid();
        ProjectTriggerForHubspotController.sendEmails(JSON.serialize(projects));
        Test.stopTest();
    }

    @IsTest
    static void test_sendEmails2() {
        Test.startTest();
        Group g1 = new Group(Name='test group', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'avnio__Project__c');
        insert q1;
        GroupMember gm = new GroupMember();
        gm.GroupId = g1.Id;
        gm.UserOrGroupId = Userinfo.getuserid();
        Test.setMock(HttpCalloutMock.class, new HubspotWebhookServiceTest.HubspotCalloutMock());
        List <avnio__Project__c> projects = [SELECT Id,Hubspot_Deal_Id__c,avnio__RecordType__c,avnio__Status__c,avnio__DueDate__c,Hubspot_Deal_stage__c,Hubspot_Created_By__c FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project'];
        projects[0].Hubspot_Created_By__c = userinfo.getuserid();
        projects[0].ownerId = g1.id;
        ProjectTriggerForHubspotController.sendEmails(JSON.serialize(projects));
        Test.stopTest();
    }

    @IsTest
    static void test_BusinessDays1() {
        Test.startTest();
        BusinessDays bd = new BusinessDays();
        Datetime subtractedDate = bd.subtractDays(System.now(),1);
        Datetime addedDate = bd.addDays(System.now(),1);
        Datetime nextWorkDay = bd.getNextWorkingDay(System.now());
        Boolean isWorkDay = bd.isWorkingDay(System.now());
        Integer daysBetween = bd.getNoOfBusinessDaysBetweenDates(System.now(),System.now());
        Test.stopTest();
    }

    @IsTest
    static void test_BusinessDays2() {
        Test.startTest();
        BusinessDays bd = new BusinessDays('default');
        Test.stopTest();
    }
}