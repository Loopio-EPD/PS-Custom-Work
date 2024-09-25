/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : calculateScoreOnProjectTest
* Details : Test class for calculateScoreOnProject
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

@isTest
public with sharing class calculateScoreOnProjectTest {
    @IsTest
    static void test_calculate() {
        Test.startTest();
        Bid_No_Bid_Score__c bidNoBidScore = new Bid_No_Bid_Score__c();
        bidNoBidScore.Field_API_Name__c = 'Based_on_the_RFx_information_what_is_th__c';
        bidNoBidScore.value__c = '0-20 k€';
        bidNoBidScore.score__c = 10;
        insert bidNoBidScore;
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
        project.Based_on_the_RFx_information_what_is_th__c = '0-20 k€';
        insert project;
        List<avnio__Project__c> proList = [select id,Bid_score__c from avnio__Project__c where id =: project.Id];
        System.assertEquals(proList[0].Bid_score__c, 10);
        Test.stopTest();
    }
}