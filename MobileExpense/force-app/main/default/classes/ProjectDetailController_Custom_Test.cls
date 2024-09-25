/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : ProjectDetailController_Custom_Test
* Details : Test class for ProjectDetailController_Custom
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

@IsTest
public with sharing class ProjectDetailController_Custom_Test{

    @testSetup
    private static void createData(){
        List<avnio__Project__c> projects = new List<avnio__Project__c>();
        projects.add(new avnio__Project__c(
                avnio__ProjectName__c = 'Test Project'
            )
        );

        insert projects;
    }
    @IsTest
    static void testProjectDetails(){
       
       avnio__Project__c projectInput = [SELECT Id FROM avnio__Project__c WHERE avnio__ProjectName__c = 'Test Project' LIMIT 1];
       ProjectDetailController_Custom ctrl  =  new ProjectDetailController_Custom();
       ctrl.projectInput = projectInput;
       ctrl.flowDevName = 'test';
       ctrl.instanceURL = 'test';
       ctrl.currentUserId = 'test';
       ctrl.recordId = 'test';
       System.assertEquals('Test Project', ctrl.projectSO.avnio__ProjectName__c,'Unable to retrive Project Details');
       
    }
}