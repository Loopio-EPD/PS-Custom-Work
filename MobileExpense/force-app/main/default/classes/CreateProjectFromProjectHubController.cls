/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : CreateProjectFromProjectHubController
* Details : Aura handler for creation of project from Project Hub
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

public with sharing class CreateProjectFromProjectHubController {
	@AuraEnabled
    public static List<RecordType> getListOfRecordType(){
        List<RecordType> rtNames = new List<RecordType>();
        Schema.SObjectType  objType = avnio__Project__c.SObjectType;
        Set<Id> recordTypesId = new Set<Id>();
        for(RecordTypeInfo rt : objType.getDescribe().getRecordTypeInfos()){
            if(rt.getName() != 'Master' && rt.isActive()){
                recordTypesId.add(rt.getRecordTypeId());
            }
            System.debug('rtNames'+rtNames);
        }

        String query = 'SELECT Id,Name,IsActive,Description FROM RecordType WHERE SobjectType =\''+'avnio__Project__c'+'\' AND IsActive = true AND Id IN :recordTypesId';
        List<RecordType> recordTypeList = Database.query(query);
        for(RecordType singleRT : recordTypeList){
            rtNames.add(new RecordType(Id = singleRT.Id ,Name = singleRT.Name, Description = singleRT.Description));
        }
        return rtNames; 
    }
}