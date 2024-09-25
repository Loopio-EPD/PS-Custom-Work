/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : projecttriggerhandler
* Details : Trigger handler for projectTrigger
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

public class projecttriggerhandler {

    public static void beforeinsert(Map<id,avnio__Project__c> oldMap, Map<id,avnio__Project__c> newMap) {
        ProjectTriggerForHubspotController.onInsertProjectBefore((List< avnio__Project__c>)Trigger.new);
    }
    
    public static void beforeupdate(Map<id,avnio__Project__c> oldMap, Map<id,avnio__Project__c> newMap) {
        ProjectTriggerForHubspotController.onUpdateProjectBefore(oldMap, (List< avnio__Project__c>)Trigger.new);
    }
    
    public static void afterinsert(Map<id,avnio__Project__c> oldMap, Map<id,avnio__Project__c> newMap) {
        ProjectTriggerForHubspotController.onInsertProjectAfter((List< avnio__Project__c>)Trigger.new);
    }
    
    public static void afterupdate(Map<id,avnio__Project__c> oldMap, Map<id,avnio__Project__c> newMap) {
        ProjectTriggerForHubspotController.onUpdateProjectAfter(oldMap, (List< avnio__Project__c>)Trigger.new);
    
    }
    
}