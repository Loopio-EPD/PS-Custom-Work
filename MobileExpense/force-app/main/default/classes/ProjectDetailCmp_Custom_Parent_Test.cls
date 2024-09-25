@IsTest
public with sharing class ProjectDetailCmp_Custom_Parent_Test{

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
        ProjectDetailCmp_Custom_Parent ctrl  =  new ProjectDetailCmp_Custom_Parent();
        avnio__ProjectQuestion__c projq = new avnio__ProjectQuestion__c ();
        projq.avnio__ProjectId__c = projectInput.id;
        insert projq;
        ctrl.recordId = projq.Id;
        System.assertNotEquals(null, ctrl.response,'Unable to retrive Project Details');
       
    }
}