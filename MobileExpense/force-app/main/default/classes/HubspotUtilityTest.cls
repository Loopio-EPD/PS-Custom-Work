/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : HubspotUtilityTest
* Details : Test class for HubspotWebhookService and HubspotWebhookServiceForUpdateAction
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

@isTest
public with sharing class HubspotUtilityTest {
 	@IsTest
    static void test_getAccountFromWrapper() {
        Test.startTest();
        HubspotUtility.Result singleResult = new HubspotUtility.Result();
		HubspotUtility.Properties properties = new HubspotUtility.Properties();
        singleResult.id = '291878172831';
        properties.name = 'test';
        properties.domain = 'www.google.com';
        properties.phone = '91823913';
        properties.address = 'abc';
        properties.city = 'Pune';
        properties.state = 'MH';
        properties.zip = '411001';
        properties.country = 'India';
        properties.numberofemployees = '20';
        singleResult.properties = properties;
        Account account = HubspotUtility.getAccountFromWrapper(singleResult);
        Test.stopTest();
        System.assertEquals(account.name, 'test');
    }
    
    @IsTest
    static void test_CreateAccountsQueue() {
        Test.startTest();
        List<HubspotUtility.Result> responseResults = new List<HubspotUtility.Result>();
        HubspotUtility.Result singleResult = new HubspotUtility.Result();
		HubspotUtility.Properties properties = new HubspotUtility.Properties();
        singleResult.id = '291878172831';
        properties.name = 'test';
        properties.domain = 'www.google.com';
        properties.phone = '91823913';
        properties.address = 'abc';
        properties.city = 'Pune';
        properties.state = 'MH';
        properties.zip = '411001';
        properties.country = 'India';
        properties.numberofemployees = '20';
        singleResult.properties = properties;
        responseResults.add(singleResult);
        System.enqueueJob(new HubspotUtility.CreateAccountsQueue(responseResults));
        Test.stopTest();
        List<Account> accountList = [select id,name from account where name = 'test'];
        System.assertEquals(0, accountList.size());
        //System.assertEquals(accountList[0].name, 'test');
    }

	// @IsTest
    // static void test_ProcessCompaniesResponseBatch() {
    //     Test.startTest();
    //     Account account = new Account();
    //     account.name = 'Account Test';
    //     account.Hubspot_Company_Id__c = '1178179';
    //     insert account;
    //     List<HubspotUtility.Result> responseResults = new List<HubspotUtility.Result>();
    //     HubspotUtility.Result singleResult = new HubspotUtility.Result();
	// 	HubspotUtility.Properties properties = new HubspotUtility.Properties();
    //     singleResult.id = '1178179';
    //     properties.name = 'test';
    //     properties.domain = 'www.google.com';
    //     properties.phone = '91823913';
    //     properties.address = 'abc';
    //     properties.city = 'Pune';
    //     properties.state = 'MH';
    //     properties.zip = '411001';
    //     properties.country = 'India';
    //     properties.numberofemployees = '20';
    //     singleResult.properties = properties;
    //     responseResults.add(singleResult);
    //     ProcessCompaniesResponseBatch processCompaniesResponseBatch = new ProcessCompaniesResponseBatch(responseResults);
    //     Database.executeBatch(processCompaniesResponseBatch);
    //     Test.stopTest();
    //     List<Account> accountList = [select id,name from account where name = 'test'];
    //     System.assertEquals(accountList.size(), 1);
    //     System.assertEquals(accountList[0].name, 'test');
    // }
    
    @IsTest
    static void test_updateProjectsWithoutSharing() {
        Test.startTest();
        List<Recordtype> rtypeList = [select id, name, SobjectType, isactive from recordtype where SobjectType='avnio__Project__c' and isactive=true];
        avnio__Project__c project = new avnio__Project__c();
        project.avnio__ProjectName__c = 'dealName';
        project.avnio__DueDate__c = Datetime.now();
        project.avnio__Status__c = 'Request';
        project.recordTypeId = rtypeList[0].Id;
        insert project;
        List<avnio__Project__c> existingProjectsForDeal = [select id from avnio__Project__c];
        existingProjectsForDeal[0].avnio__ProjectName__c = 'testname';
      	HubspotWithoutSharingClass.updateProjects(existingProjectsForDeal);
        Test.stopTest();
        List<avnio__Project__c> existingProjectsForDealNew = [select id,avnio__ProjectName__c from avnio__Project__c];
        System.assertEquals(existingProjectsForDealNew.size(), 1);
        System.assertEquals(existingProjectsForDealNew[0].avnio__ProjectName__c, 'testname');
    }

    @IsTest
    static void test_getStagesMap() {
        Test.startTest();
        Map<String,String> response = HubspotUtility.getStagesMap();
        System.assert(response.size() > 0);
        Test.stopTest();
    }

    @IsTest
    static void test_getSizeMap() {
        Test.startTest();
        Map<String,String> response = HubspotUtility.getSizeMap();
        System.assert(response.size() > 0);
        Test.stopTest();
    }
}