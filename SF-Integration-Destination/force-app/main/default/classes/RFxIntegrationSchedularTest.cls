@isTest
public with sharing class RFxIntegrationSchedularTest {

    @isTest
    public static void testCategory() {
        Test.startTest();
        avnio__Category__c cat = new avnio__Category__c();
        cat.name = 'test';
        insert cat;
        
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        insert batchRecord;
        RFxIntegrationSchedular.SaveDataQueue sdq = new RFxIntegrationSchedular.SaveDataQueue(null,null,null,null);
        sdq.processCategoriesData(new List<avnio__Category__c>{cat},batchRecord.Id);
        Test.stopTest();
    }

    @isTest
    public static void testTag() {
        Test.startTest();
        avnio__Tag__c tag = new avnio__Tag__c();
        tag.name = 'test';
        insert tag;
        
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        insert batchRecord;
        RFxIntegrationSchedular.SaveDataQueue sdq = new RFxIntegrationSchedular.SaveDataQueue(null,null,null,null);
        sdq.processTagsData(new List<avnio__Tag__c>{tag},batchRecord.Id);
        Test.stopTest();
    }

    @isTest
    public static void testResponse() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;

		RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        insert batchRecord;       
        List<Id> responseIdForPublish = new List<Id>{res.Id};
        RFxIntegrationSchedular.SaveDataQueue sdq = new RFxIntegrationSchedular.SaveDataQueue(null,null,null,responseIdForPublish);
        sdq.processResponsesData(new List<avnio__Response__c>{res},batchRecord.Id);
        
        res.External_ID__c = String.valueOf(res.Id);
        update res;
        sdq.processResponsesData(new List<avnio__Response__c>{res},batchRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testResponseQuestion() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__ResponseQuestion__c resQues = new avnio__ResponseQuestion__c();
        resQues.avnio__ResponseId__c = res.Id;
        insert resQues;

        res.External_ID__c = res.Id;
        update res;
        List<Id> responseIdForPublish = new List<Id>{res.Id};
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        insert batchRecord;
        RFxIntegrationSchedular.SaveDataQueue sdq = new RFxIntegrationSchedular.SaveDataQueue(null,null,null,responseIdForPublish);
        sdq.processResponseQuestionsData(new List<avnio__ResponseQuestion__c>{resQues},batchRecord.Id); 
        Test.stopTest();
    }

    @isTest
    public static void testAlternativeAnswer() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__AlternativeAnswer__c altAns = new avnio__AlternativeAnswer__c();
        altAns.avnio__ResponseId__c = res.Id;
        insert altAns;
        
        res.External_ID__c = String.valueOf(res.Id);
        update res;
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        insert batchRecord;
        List<Id> responseIdForPublish = new List<Id>{res.Id};
        RFxIntegrationSchedular.SaveDataQueue sdq = new RFxIntegrationSchedular.SaveDataQueue(null,null,null,responseIdForPublish);
        sdq.processAlternativeAnswersData(new List<avnio__AlternativeAnswer__c>{altAns},batchRecord.Id); 
        Test.stopTest();
    }

    @isTest
    public static void testResponseCategory() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__Category__c cat = new avnio__Category__c();
        cat.name = 'test';
        insert cat;
        avnio__ResponseCategory__c resCat = new avnio__ResponseCategory__c();
        resCat.avnio__ResponseId__c = res.Id;
        resCat.avnio__CategoryId__c = cat.Id;
        insert resCat;
        
        res.External_ID__c = String.valueOf(res.Id);
        update res;
        resCat.External_ID__c = String.valueOf(resCat.Id);
        update resCat;
        cat.External_ID__c = String.valueOf(cat.Id);
        update cat;
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        insert batchRecord;
        List<Id> responseIdForPublish = new List<Id>{res.Id};
        RFxIntegrationSchedular.SaveDataQueue sdq = new RFxIntegrationSchedular.SaveDataQueue(null,null,null,responseIdForPublish);
        sdq.processResponseCategoriesData(new List<avnio__responsecategory__c>{resCat},batchRecord.Id); 
        Test.stopTest();
    }

    @isTest
    public static void testResponseTag() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__Tag__c tag = new avnio__Tag__c();
        tag.name = 'test';
        insert tag;
        avnio__ResponseTag__c resTag = new avnio__ResponseTag__c();
        resTag.avnio__ResponseId__c = res.Id;
        resTag.avnio__TagId__c = tag.Id;
        insert resTag;
        
        res.External_ID__c = String.valueOf(res.Id);
        update res;
        resTag.External_ID__c = String.valueOf(resTag.Id);
        update resTag;
        tag.External_ID__c = String.valueOf(tag.Id);
        update tag;
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        insert batchRecord;
        List<Id> responseIdForPublish = new List<Id>{res.Id};
        RFxIntegrationSchedular.SaveDataQueue sdq = new RFxIntegrationSchedular.SaveDataQueue(null,null,null,responseIdForPublish);
        sdq.processResponseTagsData(new List<avnio__ResponseTag__c>{resTag},batchRecord.Id); 
        Test.stopTest();
    }
    
    @isTest
    public static void testRFxIntegrationSchedular() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__Tag__c tag = new avnio__Tag__c();
        tag.name = 'test';
        insert tag;
        avnio__ResponseTag__c resTag = new avnio__ResponseTag__c();
        resTag.avnio__ResponseId__c = res.Id;
        resTag.avnio__TagId__c = tag.Id;
        insert resTag;
        
        RFxIntegrationSchedular rsc = new RFxIntegrationSchedular();
        rsc.execute(null);
        Test.stopTest();
    }
    
    @isTest
    public static void testRunIntegrationBatch() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__Tag__c tag = new avnio__Tag__c();
        tag.name = 'test';
        insert tag;
        avnio__ResponseTag__c resTag = new avnio__ResponseTag__c();
        resTag.avnio__ResponseId__c = res.Id;
        resTag.avnio__TagId__c = tag.Id;
        insert resTag;
        
        Boolean resr = RFxIntegrationSchedular.runIntegrationBatch();
        Test.stopTest();
    }
    
	@isTest
    public static void testSaveDataQueue1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        Set<String> objectAPINames = new Set<String>{'avnio__category__c'};
        String yesterdayDate = String.valueOf(System.today());
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        Database.insert(batchRecord);
        System.enqueueJob(new RFxIntegrationSchedular.SaveDataQueue(objectAPINames,batchRecord.Id,yesterdayDate,null));
        Test.stopTest();
    }

	@isTest
    public static void testSaveDataQueue2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        Set<String> objectAPINames = new Set<String>{'avnio__tag__c'};
        String yesterdayDate = String.valueOf(System.today());
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        Database.insert(batchRecord);
        System.enqueueJob(new RFxIntegrationSchedular.SaveDataQueue(objectAPINames,batchRecord.Id,yesterdayDate,null));
        Test.stopTest();
    }

	@isTest
    public static void testSaveDataQueue4() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        Set<String> objectAPINames = new Set<String>{'avnio__responsequestion__c'};
        String yesterdayDate = String.valueOf(System.today());
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        Database.insert(batchRecord);
        System.enqueueJob(new RFxIntegrationSchedular.SaveDataQueue(objectAPINames,batchRecord.Id,yesterdayDate,null));
        Test.stopTest();
    }
    
    @isTest
    public static void testSaveDataQueue5() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        Set<String> objectAPINames = new Set<String>{'avnio__alternativeanswer__c'};
        String yesterdayDate = String.valueOf(System.today());
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        Database.insert(batchRecord);
        System.enqueueJob(new RFxIntegrationSchedular.SaveDataQueue(objectAPINames,batchRecord.Id,yesterdayDate,null));
        Test.stopTest();
    }
    
    @isTest
    public static void testSaveDataQueue6() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        Set<String> objectAPINames = new Set<String>{'avnio__responsecategory__c'};
        String yesterdayDate = String.valueOf(System.today());
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        Database.insert(batchRecord);
        System.enqueueJob(new RFxIntegrationSchedular.SaveDataQueue(objectAPINames,batchRecord.Id,yesterdayDate,null));
        Test.stopTest();
    }
    
    @isTest
    public static void testSaveDataQueue7() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        Set<String> objectAPINames = new Set<String>{'avnio__responsetag__c'};
        String yesterdayDate = String.valueOf(System.today());
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        Database.insert(batchRecord);
        System.enqueueJob(new RFxIntegrationSchedular.SaveDataQueue(objectAPINames,batchRecord.Id,yesterdayDate,null));
        Test.stopTest();
    }
    
    @isTest
    public static void testSaveDataQueue8() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockClass());
        Set<String> objectAPINames = new Set<String>{'deletedRecords'};
        String yesterdayDate = String.valueOf(System.today());
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        Database.insert(batchRecord);
        System.enqueueJob(new RFxIntegrationSchedular.SaveDataQueue(objectAPINames,batchRecord.Id,yesterdayDate,null));
        Test.stopTest();
    }
    
    @isTest
    public static void testProcessAltQuestionsDeleteData_new() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__ResponseQuestion__c resQues = new avnio__ResponseQuestion__c();
        resQues.avnio__ResponseId__c = res.Id;
        insert resQues;

        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        insert batchRecord;
        List<Id> responseIdForPublish = new List<Id>{res.Id};
        RFxIntegrationSchedular.SaveDataQueue sdq = new RFxIntegrationSchedular.SaveDataQueue(null,null,null,responseIdForPublish);
        sdq.processAltQuestionsDeleteData_new(new List<avnio__ResponseQuestion__c>{resQues}); 
        Test.stopTest();
    }
    
    @isTest
    public static void testProcessAltAnswerDeleteData_new() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__AlternativeAnswer__c altAns = new avnio__AlternativeAnswer__c();
        altAns.avnio__ResponseId__c = res.Id;
        insert altAns;
        
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        insert batchRecord;
        List<Id> responseIdForPublish = new List<Id>{res.Id};
        RFxIntegrationSchedular.SaveDataQueue sdq = new RFxIntegrationSchedular.SaveDataQueue(null,null,null,responseIdForPublish);
        sdq.processAltAnswerDeleteData_new(new List<avnio__AlternativeAnswer__c>{altAns}); 
        Test.stopTest();
    }
    
    public with sharing class CalloutMockClass implements HttpCalloutMock {
        public HttpResponse respond( HttpRequest req ) {
            String endpoint = req.getEndpoint(); 
            Map<String,String> mm = new Map<String,String>();
            HttpResponse res = new HttpResponse();
            String responseData = '[{"attributes":{"type":"RFX_Integration_Data_Delete_Log__c","url":"/services/data/sobjects/RFX_Integration_Data_Delete_Log__c/a1SKG000000Kzgq2AC"},"Id":"a1SKG000000Kzgq2AC","Record_ID__c":"a1SKG000000Kzgq2AC","Object_API_Name__c":"avnio__category__c","CurrencyIsoCode":"USD"},{"attributes":{"type":"RFX_Integration_Data_Delete_Log__c","url":"/services/data/sobjects/RFX_Integration_Data_Delete_Log__c/a1SKG000000Kzgq2AC"},"Id":"a1SKG000000Kzgq2AC","Record_ID__c":"a1SKG000000Kzgq2AC","Object_API_Name__c":"avnio__tag__c","CurrencyIsoCode":"USD"},{"attributes":{"type":"RFX_Integration_Data_Delete_Log__c","url":"/services/data/sobjects/RFX_Integration_Data_Delete_Log__c/a1SKG000000Kzgq2AC"},"Id":"a1SKG000000Kzgq2AC","Record_ID__c":"a1SKG000000Kzgq2AC","Object_API_Name__c":"avnio__response__c","CurrencyIsoCode":"USD"},{"attributes":{"type":"RFX_Integration_Data_Delete_Log__c","url":"/services/data/sobjects/RFX_Integration_Data_Delete_Log__c/a1SKG000000Kzgq2AC"},"Id":"a1SKG000000Kzgq2AC","Record_ID__c":"a1SKG000000Kzgq2AC","Object_API_Name__c":"avnio__responsequestion__c","CurrencyIsoCode":"USD"},{"attributes":{"type":"RFX_Integration_Data_Delete_Log__c","url":"/services/data/sobjects/RFX_Integration_Data_Delete_Log__c/a1SKG000000Kzgq2AC"},"Id":"a1SKG000000Kzgq2AC","Record_ID__c":"a1SKG000000Kzgq2AC","Object_API_Name__c":"avnio__alternativeanswer__c","CurrencyIsoCode":"USD"},{"attributes":{"type":"RFX_Integration_Data_Delete_Log__c","url":"/services/data/sobjects/RFX_Integration_Data_Delete_Log__c/a1SKG000000Kzgq2AC"},"Id":"a1SKG000000Kzgq2AC","Record_ID__c":"a1SKG000000Kzgq2AC","Object_API_Name__c":"avnio__responsecategory__c","CurrencyIsoCode":"USD"},{"attributes":{"type":"RFX_Integration_Data_Delete_Log__c","url":"/services/data/sobjects/RFX_Integration_Data_Delete_Log__c/a1SKG000000Kzgq2AC"},"Id":"a1SKG000000Kzgq2AC","Record_ID__c":"a1SKG000000Kzgq2AC","Object_API_Name__c":"avnio__responsetag__c","CurrencyIsoCode":"USD"}]';
            mm.put('avnio__category__c',responseData);
            mm.put('avnio__tag__c',responseData);
            mm.put('avnio__response__c',responseData);
            mm.put('avnio__responsequestion__c',responseData);
            mm.put('avnio__alternativeanswer__c',responseData);
            mm.put('avnio__responsecategory__c',responseData);
            mm.put('avnio__responsetag__c',responseData);
            mm.put('deletedRecords',responseData);
            res.setBody(JSON.serialize(mm)); 
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}