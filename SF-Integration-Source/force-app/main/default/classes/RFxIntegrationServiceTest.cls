@isTest
public with sharing class RFxIntegrationServiceTest {

    @isTest
    public static void testCategory() {
        Test.startTest();
        avnio__Category__c cat = new avnio__Category__c();
        cat.name = 'test';
        insert cat;
        
        RestRequest req = new RestRequest();
        RestResponse resContx = new RestResponse();
        req.requestURI = '/services/apexrest/RFxIntegrationService/avnio__category__c/'+String.valueOf(System.today().addDays(-1));
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resContx;
        
        Map<String, String> response = RFxIntegrationService.getData();
        
        System.assert(response != null);
        Test.stopTest();
    }
    
    @isTest
    public static void testTag() {
        Test.startTest();
        avnio__Tag__c tag = new avnio__Tag__c();
        tag.name = 'test';
        insert tag;
        
        RestRequest req = new RestRequest();
        RestResponse resContx = new RestResponse();
        req.requestURI = '/services/apexrest/RFxIntegrationService/avnio__tag__c/'+String.valueOf(System.today().addDays(-1));
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resContx;
        
        Map<String, String> response = RFxIntegrationService.getData();
        
        System.assert(response != null);
        Test.stopTest();
    }
    
    @isTest
    public static void testResponse() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        res.GSX_Integrated_Response__c = true;
        res.avnio__Status__c = 'Published';
        insert res;
        RestRequest req = new RestRequest();
        RestResponse resContx = new RestResponse();
        req.requestURI = '/services/apexrest/RFxIntegrationService/avnio__response__c/'+String.valueOf(System.today().addDays(-1));
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resContx;
        
        Map<String, String> response = RFxIntegrationService.getData();
        
        System.assert(response != null);
        Test.stopTest();
    }

    @isTest
    public static void testResponseQuestion() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        res.GSX_Integrated_Response__c = true;
        res.avnio__Status__c = 'Published';
        insert res;
        avnio__ResponseQuestion__c resQues = new avnio__ResponseQuestion__c();
        resQues.avnio__ResponseId__c = res.Id;
        insert resQues;
        
        RestRequest req = new RestRequest();
        RestResponse resContx = new RestResponse();
        req.requestURI = '/services/apexrest/RFxIntegrationService/avnio__responsequestion__c/'+String.valueOf(System.today().addDays(-1));
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resContx;
        
        Map<String, String> response = RFxIntegrationService.getData();
        
        System.assert(response != null);
        Test.stopTest();
    }

    @isTest
    public static void testAlternativeAnswer() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        res.GSX_Integrated_Response__c = true;
        res.avnio__Status__c = 'Published';
        insert res;
        avnio__AlternativeAnswer__c altAns = new avnio__AlternativeAnswer__c();
        altAns.avnio__ResponseId__c = res.Id;
        insert altAns;
        
        RestRequest req = new RestRequest();
        RestResponse resContx = new RestResponse();
        req.requestURI = '/services/apexrest/RFxIntegrationService/avnio__alternativeanswer__c/'+String.valueOf(System.today().addDays(-1));
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resContx;
        
        Map<String, String> response = RFxIntegrationService.getData();
        
        System.assert(response != null);
        Test.stopTest();
    }

    @isTest
    public static void testResponseCategory() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        res.GSX_Integrated_Response__c = true;
        res.avnio__Status__c = 'Published';
        insert res;
        avnio__Category__c cat = new avnio__Category__c();
        cat.name = 'test';
        insert cat;
        avnio__ResponseCategory__c resCat = new avnio__ResponseCategory__c();
        resCat.avnio__ResponseId__c = res.Id;
        resCat.avnio__CategoryId__c = cat.Id;
        insert resCat;
        RestRequest req = new RestRequest();
        RestResponse resContx = new RestResponse();
        req.requestURI = '/services/apexrest/RFxIntegrationService/avnio__responsecategory__c/'+String.valueOf(System.today().addDays(-1));
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resContx;
        
        Map<String, String> response = RFxIntegrationService.getData();
        
        System.assert(response != null);
        Test.stopTest();
    }

    @isTest
    public static void testResponseTag() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        res.GSX_Integrated_Response__c = true;
        res.avnio__Status__c = 'Published';
        insert res;
        avnio__Tag__c tag = new avnio__Tag__c();
        tag.name = 'test';
        insert tag;
        avnio__ResponseTag__c resTag = new avnio__ResponseTag__c();
        resTag.avnio__ResponseId__c = res.Id;
        resTag.avnio__TagId__c = tag.Id;
        insert resTag;
        RestRequest req = new RestRequest();
        RestResponse resContx = new RestResponse();
        req.requestURI = '/services/apexrest/RFxIntegrationService/avnio__responsetag__c/'+String.valueOf(System.today().addDays(-1));
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resContx;
        
        Map<String, String> response = RFxIntegrationService.getData();
        
        System.assert(response != null);
        Test.stopTest();
    }
    
    @isTest
    public static void testDeletedRecords() {
        Test.startTest();
        RFX_Integration_Data_Delete_Log__c delRec = new RFX_Integration_Data_Delete_Log__c();
        delRec.Object_API_Name__c = 'test';
        delRec.Record_ID__c = 'test';
        insert delRec;
        
        RestRequest req = new RestRequest();
        RestResponse resContx = new RestResponse();
        req.requestURI = '/services/apexrest/RFxIntegrationService/deletedRecords/'+String.valueOf(System.today().addDays(-1));
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = resContx;
        
        Map<String, String> response = RFxIntegrationService.getData();
        
        System.assert(response != null);
        Test.stopTest();
    }
}