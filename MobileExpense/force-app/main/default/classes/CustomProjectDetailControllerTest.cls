@isTest
public with sharing class CustomProjectDetailControllerTest 
{
    @testSetup
    private static void createData(){
        List<avnio__Project__c> projects = new List<avnio__Project__c>();
        projects.add(new avnio__Project__c(
                avnio__ProjectName__c = 'Test Project'
        	)
        );

        insert projects;
    }
    
    @isTest 
    static void test_myTest() {   
        avnio__Project__c projectInput = [SELECT Id FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
        Test.startTest();
       	CustomProjectDetailController ctrl  =  new CustomProjectDetailController();
        ctrl.projectInput = projectInput;
        ctrl.flowDevName = 'testflow';
        System.assertEquals(ctrl.projectSO.avnio__ProjectName__c,'Test Project');
        Test.stopTest();
    }
    
    @isTest 
    static void test_myTes2() {   
        Test.startTest();
       	CustomProjectDetailController ctrl  =  new CustomProjectDetailController();
        System.assertEquals(ctrl.projectSO,new avnio__Project__c());
        Test.stopTest();
    }
}