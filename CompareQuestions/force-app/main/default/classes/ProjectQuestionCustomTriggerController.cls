public with sharing class ProjectQuestionCustomTriggerController {
    public static void afterInsertAction(List<avnio__ProjectQuestion__c> newList){
        Set<Id> projectIdSet = new Set<Id>();
        for(avnio__ProjectQuestion__c pq : newList){
            if(pq.avnio__ProjectId__c  != null){
                projectIdSet.add(pq.avnio__ProjectId__c);
            }
        }
        
        Map<Id,avnio__Project__c> projects = new Map<Id,avnio__Project__c>([SELECT id, Compare_with_Previous_Project__c from avnio__Project__c where Id IN :projectIdSet]);
        
        if(projects != null && projects.size() > 0){
            Set<Id> projectQuestionsIdSet = new Set<Id>();
            for(avnio__ProjectQuestion__c pq : newList){
                if(pq.avnio__Question__c  != null && String.isNotBlank(pq.avnio__Question__c) && pq.avnio__ProjectId__c  != null && projects.get(pq.avnio__ProjectId__c) != null && projects.get(pq.avnio__ProjectId__c).Compare_with_Previous_Project__c){
                    projectQuestionsIdSet.add(pq.Id);
                }
            }
            if(projectQuestionsIdSet.size() > 0){
                populateMatchingProjectQuestions(projectQuestionsIdSet);
            }
        }
	}
    
	@future(callout=true)
    public static void populateMatchingProjectQuestions(Set<Id> projectQuestionsIdSet){
        if(projectQuestionsIdSet != null && projectQuestionsIdSet.size() > 0){
        	List<avnio__ProjectQuestion__c> projectQuestions = [SELECT id,avnio__ProjectId__c, avnio__Question__c, Matching_Project_Id__c ,Matching_Project_Question_ID__c  from avnio__ProjectQuestion__c where Id IN :projectQuestionsIdSet];
            if(projectQuestions != null && projectQuestions.size() > 0){
                List<String> questions = new List<String>();
                Set<Id> projectIdSet = new Set<Id>();
                for(avnio__ProjectQuestion__c pq : projectQuestions){
                    if(pq.avnio__Question__c  != null && String.isNotBlank(pq.avnio__Question__c)){
                    	questions.add(pq.avnio__Question__c);
                        projectIdSet.add(pq.avnio__ProjectId__c);
                    }
                }
                if(questions.size() > 0){
                    String questionValues = String.join(questions,' OR ');
                    String query = 'FIND {' + questionValues + '} IN ALL FIELDS RETURNING avnio__ProjectQuestion__c(id,name,avnio__Question__c,avnio__ProjectId__c,avnio__Answer__c WHERE avnio__ProjectId__c NOT IN :projectIdSet) LIMIT 2000';
            		List<List<SObject>> searchList = search.query(query);
                    if(searchList != null){
                        Map<String,SObject> questionTOObjMap = new Map<String,SObject>();
                        List<SObject> responses = searchList.get(0);
                        if(responses != null && !responses.isEmpty()){
                            for(SObject respo : responses){
                                String question = String.valueOf(respo.get('avnio__Question__c'));
                                String answer = String.valueOf(respo.get('avnio__Answer__c'));
                        		String projectId = String.valueOf(respo.get('avnio__ProjectId__c'));
                                if(question != null && String.isNotBlank(question) && answer != null && String.isNotBlank(answer) && projectId != null){
                                    questionTOObjMap.put(question,respo);
                                }
                            }
                        }
                        if(questionTOObjMap != null && questionTOObjMap.size() > 0){
                            for(avnio__ProjectQuestion__c pq : projectQuestions){
                                if(pq.avnio__Question__c != null && String.isNotBlank(pq.avnio__Question__c) && questionTOObjMap.get(pq.avnio__Question__c) != null){
                                    SObject pqObj = questionTOObjMap.get(pq.avnio__Question__c);
                                    pq.Matching_Project_Id__c = String.valueOf(pqObj.get('avnio__ProjectId__c'));
                                    pq.Matching_Project_Question_ID__c = String.valueOf(pqObj.get('Id'));
                                }
                            }
                            Database.update(projectQuestions,false);
                        }
                    }
                }
            }
        }
	}
}