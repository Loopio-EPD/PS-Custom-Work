@isTest
public with sharing class RetriveCategoriesAndTagsBatchTest {

    @TestSetup
    static void setupData() {
        getUserAndAssignPermissionSet();
        System.runAs(getUser()) {
            makeData();
        }
    }

    public static void getUserAndAssignPermissionSet(){
        User userObj = getUser();
        try{
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :'AvnioRFXAdministrator'];
            insert new PermissionSetAssignment(AssigneeId = userObj.id, PermissionSetId = ps.Id);
        }
        catch(Exception e){}
    }
    
    public static User getUser(){
        return [SELECT id, name, profileId FROM User WHERE id = :Userinfo.getUserId()][0];
    }

    public static void makeData(){
        List<avnio__Response__c> respList = new List<avnio__Response__c>();
        respList.add(
            new avnio__Response__c(
                avnio__Answer__c = 'Response 1',
                avnio__PrimaryQuestion__c = 'Question on create 11',
                avnio__IsTransient__c = true,
                avnio__StatusCategory__c = 'In Publish',
                avnio__Status__c = 'Ready for Publish',
                avnio__Source__c = 'SF',
                avnio__KnowledgeBaseAnswerId__c = '789'
            )
        );
        insert respList;

        List<avnio__Category__c> caategoryList = new List<avnio__Category__c>();
        caategoryList.add(new avnio__Category__c(Name = 'Category 1'));
        caategoryList.add(new avnio__Category__c(Name = 'Category 2'));
        insert caategoryList;

        List<avnio__ResponseCategory__c> responseCategoryList = new List<avnio__ResponseCategory__c>();
        responseCategoryList.add(
            new avnio__ResponseCategory__c(
                avnio__CategoryId__c = caategoryList[0].Id,
                avnio__ResponseId__c = respList[0].Id,
                avnio__TransactionType__c = 'Add'
            )
        );
        insert responseCategoryList;

        List<avnio__Tag__c> tagList = new List<avnio__Tag__c>();
        tagList.add(new avnio__Tag__c(Name = 'TestTag1'));
        tagList.add(new avnio__Tag__c(Name = 'TestTag2'));
        insert tagList;

        List<avnio__ResponseTag__c> responseTagList = new List<avnio__ResponseTag__c>();
        responseTagList.add(new avnio__ResponseTag__c(avnio__TagId__c = tagList[0].Id, avnio__ResponseId__c = respList[0].Id));
        responseTagList.add(new avnio__ResponseTag__c(avnio__TagId__c = tagList[1].Id, avnio__ResponseId__c = respList[0].Id));
        insert responseTagList;
    }

    @isTest
    private static void RetriveCategoriesAndTagsBatchTestNgtv() {
        System.runAs(getUser()) {
            List<avnio__Response__c> responseList = [SELECT Id,Name,Categories__c,Tags__c FROM avnio__Response__c];
            System.assertEquals(responseList[0].Categories__c, null);
            System.assertEquals(responseList[0].Tags__c, null);
        }
    }

    @isTest
    private static void RetriveCategoriesAndTagsBatchTestPstv() {
        System.runAs(getUser()) {
            Test.startTest();
            RetriveCategoriesAndTagsBatch myBatchObject = new RetriveCategoriesAndTagsBatch();
            Database.executeBatch(myBatchObject);
            Test.stopTest();
            List<avnio__Response__c> responseList = [SELECT Id,Name,Categories__c,Tags__c FROM avnio__Response__c];
            System.assertEquals(responseList[0].Categories__c, 'Category 1');
            System.assertEquals(responseList[0].Tags__c, 'TestTag1,TestTag2');
        }
    }

}