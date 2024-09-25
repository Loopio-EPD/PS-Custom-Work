/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : ProjectDetailController
* Details : Used as email controller
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

global with sharing class ProjectDetailController {
    global SObject projectInput{get;set;}
    public String flowDevName{get;set;}
    public String dueDateDevName{get;set;}

    
    public avnio__Project__c projectSO{
        get {
          avnio__Project__c record = null;
          if(String.isBlank(dueDateDevName)) dueDateDevName  = 'avnio__DueDate__c';
          if(projectInput!=null){
              Id projectId = projectInput.Id;
              List<avnio__Project__c> projects = Database.query('Select Id, Name, avnio__ProjectName__c, avnio__RecordType__c,Hubspot_Deal_Link__c, Owner.Name,'+dueDateDevName+' , avnio__Status__c FROM avnio__Project__c where id =:projectId');
              if(!projects.isEmpty()) return projects.get(0);
          }
          return new avnio__Project__c(); }
       set;
    }
}