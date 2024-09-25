public with sharing class CustomProjectQuestionTriggerHandler {
    public static void beforeAction(List<avnio__ProjectQuestion__c> newRecords, Map<Id,avnio__ProjectQuestion__c> oldmap){
        Set<String> questinNoString = new Set<String>{'Question Number','Question No','Q No.','Question No.','Q Number','Question Num.','question number','Q.N.','QN'};
        Set<id> projectIDset = new Set<id> ();
         for(avnio__ProjectQuestion__c pq : newRecords) {
            if(((Trigger.isinsert && pq.avnio__Configuration__c != null) || 
                (Trigger.isupdate && pq.avnio__Configuration__c  != null && oldmap != null && pq.avnio__Configuration__c  != oldmap.get(pq.id).avnio__Configuration__c))
                && !projectIDset.contains(pq.avnio__ProjectId__c)){
                    DTOProjectQuestionConfiguration projectQuestionConfiguration = (DTOProjectQuestionConfiguration) JSON.deserialize(pq.avnio__Configuration__c, DTOProjectQuestionConfiguration.class);
                    if(projectQuestionConfiguration.compliances != null && projectQuestionConfiguration.compliances.size() > 0) {
                        projectIDset.add(pq.avnio__ProjectId__c);
                    }
            }
        }
        
        Map<id,Map<string,DTOProjectConfiguration.Compliances>> projectcomplianceMap = new Map<id,Map<string,DTOProjectConfiguration.Compliances>> ();
            
        if(projectIDSet != null && projectIDSet.size() > 0) {
            List<avnio__Project__c> projectlist = new List<avnio__Project__c> ();
            projectlist = [select id,avnio__Configuration__c from avnio__Project__c where ID IN:projectIDSet];
            for(avnio__Project__c avnioproject : projectlist) {
                if(avnioproject.avnio__Configuration__c != null) {
                    DTOProjectConfiguration projectConfiguration = (DTOProjectConfiguration) JSON.deserialize(avnioproject.avnio__Configuration__c, DTOProjectConfiguration.class);
                    if(projectConfiguration.projectConfig != null && projectConfiguration.projectConfig.compliances != null && projectConfiguration.projectConfig.compliances.size() > 0) {
                        List<DTOProjectConfiguration.Compliances> compliancelist = projectConfiguration.projectConfig.compliances;
                        Map<String,DTOProjectConfiguration.Compliances>  complianceMap = new Map<String,DTOProjectConfiguration.Compliances> ();
                        for(DTOProjectConfiguration.Compliances comp :  compliancelist) {
                            if(comp.type != null && comp.type.equalsIgnoreCase('READONLYTEXT') && comp.label != null && questinNoString.contains(comp.label)){
                                complianceMap.put(comp.id,comp);    
                            }
                        }
                        projectcomplianceMap.put(avnioproject.id,complianceMap);
                    }                
               }
            }
        }

        for(avnio__ProjectQuestion__c pq : newRecords) {
            if(((Trigger.isinsert && pq.avnio__Configuration__c != null) || 
                (Trigger.isupdate && pq.avnio__Configuration__c  != null && oldmap != null && pq.avnio__Configuration__c  != oldmap.get(pq.id).avnio__Configuration__c))){
                DTOProjectQuestionConfiguration projectQuestionConfiguration = (DTOProjectQuestionConfiguration) JSON.deserialize(pq.avnio__Configuration__c, DTOProjectQuestionConfiguration.class);                
                if(projectQuestionConfiguration.compliances != null && projectQuestionConfiguration.compliances.size() > 0) {
                     for(DTOProjectConfiguration.Compliances compliance :   projectQuestionConfiguration.compliances) {
                         if(compliance.value != null && compliance.value !='' && compliance.value !=' ') {
                              if(projectcomplianceMap != null && projectcomplianceMap.get(pq.avnio__ProjectId__c) != null
                                && projectcomplianceMap.get(pq.avnio__ProjectId__c).get(compliance.id) != null
                                && projectcomplianceMap.get(pq.avnio__ProjectId__c).get(compliance.id).type =='READONLYTEXT'
                                && projectcomplianceMap.get(pq.avnio__ProjectId__c).get(compliance.id).label != null
                                && questinNoString.contains(projectcomplianceMap.get(pq.avnio__ProjectId__c).get(compliance.id).label)) {
                                    System.debug(compliance.value);
                                    pq.Question_Number__c = compliance.value;
                                    // if(pq.avnio__QuestionRichText__c != null && !String.isEmpty(pq.avnio__QuestionRichText__c) && pq.avnio__Question__c != null && !String.isEmpty(pq.avnio__Question__c) && pq.avnio__QuestionRichText__c.contains(pq.avnio__Question__c) && !pq.avnio__QuestionRichText__c.contains(compliance.value)){
                                    //     pq.avnio__QuestionRichText__c = pq.avnio__QuestionRichText__c.replace(pq.avnio__Question__c , compliance.value + ' ' + pq.avnio__Question__c);
                                    // }
                                    // if(pq.avnio__Question__c != null && !String.isEmpty(pq.avnio__Question__c) && !pq.avnio__Question__c.startsWith(compliance.value)){
                                    //     pq.avnio__Question__c = compliance.value + ' ' + pq.avnio__Question__c;
                                    // }
                              }
                        } 
                    }
                }
            }
        }
    }
}