/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : HubspotWithoutSharingClass
* Details : Class without sharing context to update project records in guest user context
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

public without sharing class HubspotWithoutSharingClass {
    public static void updateProjects(List<avnio__Project__c> projects){
        Database.update(projects,false);
    }
}