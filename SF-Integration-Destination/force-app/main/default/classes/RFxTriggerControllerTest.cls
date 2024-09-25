@isTest
public with sharing class RFxTriggerControllerTest {

     @isTest
    public static void testCategoryTrigger() {
        Test.startTest();
        avnio__Category__c cat = new avnio__Category__c();
        cat.name = 'test';
        insert cat;
        delete cat;
        Test.stopTest();
    }

    @isTest
    public static void testTagTrigger() {
        Test.startTest();
        avnio__Tag__c tag = new avnio__Tag__c();
        tag.name = 'test';
        insert tag;
        delete tag;
        Test.stopTest();
    }

    @isTest
    public static void testResponseTrigger() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        res.GSX_Integrated_Response__c = true;
        insert res;
        
        res.avnio__Answer__c = 'test1';
        update res;
        
        delete res;
        Test.stopTest();
    }

    @isTest
    public static void testResponseQuestionTrigger() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__ResponseQuestion__c resQues = new avnio__ResponseQuestion__c();
        resQues.avnio__ResponseId__c = res.Id;
        insert resQues;
        
        resQues.avnio__IsDeleted__c = true;
        update resQues;
        
        delete resQues;
        Test.stopTest();
    }

    @isTest
    public static void testAlternativeAnswerTrigger() {
        Test.startTest();
        avnio__Response__c res = new avnio__Response__c();
        res.avnio__Answer__c = 'test';
        res.avnio__PrimaryQuestion__c = 'test';
        insert res;
        avnio__AlternativeAnswer__c altAns = new avnio__AlternativeAnswer__c();
        altAns.avnio__ResponseId__c = res.Id;
        insert altAns;
        
        altAns.avnio__IsDeleted__c = true;
        update altAns;
        
        delete altAns;
        Test.stopTest();
    }

    @isTest
    public static void testResponseCategoryTrigger() {
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
        
        resCat.avnio__CategoryId__c = null;
        update resCat;
        
        delete resCat;
        Test.stopTest();
    }

    @isTest
    public static void testResponseTagTrigger() {
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
        
        resTag.avnio__TagId__c = null;
        update resTag;
        
        delete resTag;
        Test.stopTest();
    }
}