public with sharing class CompareQuestionsController {
    @AuraEnabled
    public static ResponseWrapper getRelatedProjectQuestions(String currentprojectId, String relatedProjectId){
        ResponseWrapper responseWrapper = new ResponseWrapper();
        responseWrapper.showRetrieveAllButton = false;
        responseWrapper.baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        if(currentprojectId != null && relatedProjectId != null){
            List<avnio__ProjectQuestion__c> currentProjectQuestions = [select id,avnio__Question__c,NSE__c,avnio__Answer__c,avnio__ProjectId__r.avnio__AccountId__c,avnio__ProjectId__r.CreatedDate from avnio__ProjectQuestion__c where avnio__ProjectId__c =:currentprojectId limit 49999];
            if(currentProjectQuestions != null && currentProjectQuestions.size() > 0 && currentProjectQuestions[0].avnio__ProjectId__r.avnio__AccountId__c != null){
                Id relatedAccId = currentProjectQuestions[0].avnio__ProjectId__r.avnio__AccountId__c;
                List<avnio__project__c> relatedProjects = [select id,avnio__AccountId__c,Name,avnio__ProjectName__c from avnio__project__c where Id =:relatedProjectId limit 1];
                Map<String,avnio__ProjectQuestion__c> relatedPQMap = new Map<String,avnio__ProjectQuestion__c>();
                if(relatedProjects != null && relatedProjects.size() > 0){
                    responseWrapper.previousProjectId = relatedProjects[0].Id;
                    responseWrapper.previousProjectName = relatedProjects[0].Name + ' - ' + relatedProjects[0].avnio__ProjectName__c;
                    Id relatedProjId = relatedProjects[0].Id;
                    List<avnio__ProjectQuestion__c> relatedProjectQuestions = [select id,avnio__Question__c,avnio__Answer__c,avnio__ProjectId__c,avnio__ProjectId__r.Name,avnio__ProjectId__r.avnio__ProjectName__c from avnio__ProjectQuestion__c where avnio__ProjectId__c =:relatedProjId limit 49999];
                    if(relatedProjectQuestions != null && relatedProjectQuestions.size() > 0){
                        for(avnio__ProjectQuestion__c relpq : relatedProjectQuestions){
                            relatedPQMap.put(relpq.avnio__Question__c.toLowerCase(),relpq);
                        }
                    }
                }

                List<ProjectQuestionWrapper> projectQuestionWrapperList = new List<ProjectQuestionWrapper>();
                Integer questionsFound = 0, questionsHaveAnswers = 0;

                for(avnio__ProjectQuestion__c curr : currentProjectQuestions){
                    ProjectQuestionWrapper pqWrapper = new ProjectQuestionWrapper();
                    pqWrapper.currentQuestionId = curr.Id;
                    pqWrapper.currentQuestion = curr.avnio__Question__c;
                    pqWrapper.currentAnswer = curr.avnio__Answer__c;
                    pqWrapper.currentInitialAnswer = curr.avnio__Answer__c;
                    if(curr.avnio__Answer__c != null && String.isNotBlank(curr.avnio__Answer__c) && curr.avnio__Answer__c.toLowerCase().startsWith('<p>') && curr.avnio__Answer__c.toLowerCase().endsWith('</p>')){
                        pqWrapper.currentAnswer = curr.avnio__Answer__c.substring(3,curr.avnio__Answer__c.length() - 4);
                        pqWrapper.currentInitialAnswer = curr.avnio__Answer__c.substring(3,curr.avnio__Answer__c.length() - 4);
                    }
                    pqWrapper.sameAnswerPresent = false;
                    if(relatedPQMap.keySet().contains(curr.avnio__Question__c.toLowerCase())){
                        pqWrapper.previousQuestionId = relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).Id;
                        pqWrapper.previousQuestion = relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Question__c;
                        pqWrapper.previousAnswer = relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c;
                        questionsFound = questionsFound + 1;
                        pqWrapper.addPTag = false;
                        if(relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c != null && String.isNotBlank(relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c)){
                            if(relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c.startsWith('<p>') && relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c.endsWith('</p>')){
                                pqWrapper.previousAnswer = relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c.substring(3,relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c.length() - 4);
                                pqWrapper.addPTag = true;
                            }
                            pqWrapper.showButton = true;
                            questionsHaveAnswers = questionsHaveAnswers + 1;
                            responseWrapper.showRetrieveAllButton = true;
                            if(curr.avnio__Answer__c != null && String.isNotBlank(curr.avnio__Answer__c) && curr.avnio__Answer__c.equalsIgnoreCase(relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c)){
                                pqWrapper.sameAnswerPresent = true;
                            }
                        }
                        else{
                            pqWrapper.showButton = false;
                        }
                    }
                    else{
                        for(String relQues : relatedPQMap.keySet()){
                            if(relQues.contains(curr.avnio__Question__c.toLowerCase())){
                                pqWrapper.previousQuestionId = relatedPQMap.get(relQues).Id;
                                pqWrapper.previousQuestion = relatedPQMap.get(relQues).avnio__Question__c;
                                pqWrapper.previousAnswer = relatedPQMap.get(relQues).avnio__Answer__c;
                                questionsFound = questionsFound + 1;
                                pqWrapper.addPTag = false;
                                if(relatedPQMap.get(relQues).avnio__Answer__c != null && String.isNotBlank(relatedPQMap.get(relQues).avnio__Answer__c)){
                                    if(relatedPQMap.get(relQues).avnio__Answer__c.startsWith('<p>') && relatedPQMap.get(relQues).avnio__Answer__c.endsWith('</p>')){
                                        pqWrapper.previousAnswer = relatedPQMap.get(relQues).avnio__Answer__c.substring(3,relatedPQMap.get(relQues).avnio__Answer__c.length() - 4);
                                        pqWrapper.addPTag = true;
                                    }
                                    pqWrapper.showButton = true;
                                    questionsHaveAnswers = questionsHaveAnswers + 1;
                                    responseWrapper.showRetrieveAllButton = true;
                                    if(curr.avnio__Answer__c != null && String.isNotBlank(curr.avnio__Answer__c) && curr.avnio__Answer__c.equalsIgnoreCase(relatedPQMap.get(relQues).avnio__Answer__c)){
                                        pqWrapper.sameAnswerPresent = true;
                                    }
                                }
                                else{
                                    pqWrapper.showButton = false;
                                }
                            }
                        }
                    }
                    pqWrapper.isChanged = false;
                    pqWrapper.nseCheckbox = curr.NSE__c;
                    projectQuestionWrapperList.add(pqWrapper);
                }
                responseWrapper.projectQuestionWrapperList = projectQuestionWrapperList;
                responseWrapper.questionsFound = questionsFound;
                responseWrapper.questionsHaveAnswers = questionsHaveAnswers;
            }
        }
        return responseWrapper;
    }

    // @AuraEnabled
    // public static ResponseWrapper getPreviousProjectQuestions(String projectId){
    //     ResponseWrapper responseWrapper = new ResponseWrapper();
    //     responseWrapper.showRetrieveAllButton = false;
    //     responseWrapper.baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    //     if(projectId != null){
    //         List<avnio__ProjectQuestion__c> currentProjectQuestions = [select id,avnio__Question__c,NSE__c,avnio__Answer__c,avnio__ProjectId__r.avnio__AccountId__c,avnio__ProjectId__r.CreatedDate from avnio__ProjectQuestion__c where avnio__ProjectId__c =:projectId AND avnio__ProjectId__r.avnio__AccountId__c != null limit 49999];
    //         if(currentProjectQuestions != null && currentProjectQuestions.size() > 0 && currentProjectQuestions[0].avnio__ProjectId__r.avnio__AccountId__c != null){
    //             Id relatedAccId = currentProjectQuestions[0].avnio__ProjectId__r.avnio__AccountId__c;
    //             DateTime currentProCreatedDate = currentProjectQuestions[0].avnio__ProjectId__r.CreatedDate;
    //             List<avnio__project__c> relatedProjects = [select id,avnio__AccountId__c,Name,avnio__ProjectName__c from avnio__project__c where avnio__AccountId__c =:relatedAccId AND Id != :projectId AND CreatedDate < :currentProCreatedDate order by createddate desc limit 1];
    //             Map<String,avnio__ProjectQuestion__c> relatedPQMap = new Map<String,avnio__ProjectQuestion__c>();
    //             if(relatedProjects != null && relatedProjects.size() > 0){
    //                 responseWrapper.previousProjectId = relatedProjects[0].Id;
    //                 responseWrapper.previousProjectName = relatedProjects[0].Name + ' - ' + relatedProjects[0].avnio__ProjectName__c;
    //                 Id relatedProjId = relatedProjects[0].Id;
    //                 List<avnio__ProjectQuestion__c> relatedProjectQuestions = [select id,avnio__Question__c,avnio__Answer__c,avnio__ProjectId__c,avnio__ProjectId__r.Name,avnio__ProjectId__r.avnio__ProjectName__c from avnio__ProjectQuestion__c where avnio__ProjectId__c =:relatedProjId limit 49999];
    //                 if(relatedProjectQuestions != null && relatedProjectQuestions.size() > 0){
    //                     for(avnio__ProjectQuestion__c relpq : relatedProjectQuestions){
    //                         relatedPQMap.put(relpq.avnio__Question__c.toLowerCase(),relpq);
    //                     }
    //                 }
    //             }

    //             List<ProjectQuestionWrapper> projectQuestionWrapperList = new List<ProjectQuestionWrapper>();
    //             Integer questionsFound = 0, questionsHaveAnswers = 0;

    //             for(avnio__ProjectQuestion__c curr : currentProjectQuestions){
    //                 ProjectQuestionWrapper pqWrapper = new ProjectQuestionWrapper();
    //                 pqWrapper.currentQuestionId = curr.Id;
    //                 pqWrapper.currentQuestion = curr.avnio__Question__c;
    //                 pqWrapper.currentAnswer = curr.avnio__Answer__c;
    //                 pqWrapper.currentInitialAnswer = curr.avnio__Answer__c;
    //                 if(curr.avnio__Answer__c != null && String.isNotBlank(curr.avnio__Answer__c) && curr.avnio__Answer__c.toLowerCase().startsWith('<p>') && curr.avnio__Answer__c.toLowerCase().endsWith('</p>')){
    //                     pqWrapper.currentAnswer = curr.avnio__Answer__c.substring(3,curr.avnio__Answer__c.length() - 4);
    //                     pqWrapper.currentInitialAnswer = curr.avnio__Answer__c.substring(3,curr.avnio__Answer__c.length() - 4);
    //                 }
    //                 pqWrapper.sameAnswerPresent = false;
    //                 if(relatedPQMap.keySet().contains(curr.avnio__Question__c.toLowerCase())){
    //                     pqWrapper.previousQuestionId = relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).Id;
    //                     pqWrapper.previousQuestion = relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Question__c;
    //                     pqWrapper.previousAnswer = relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c;
    //                     questionsFound = questionsFound + 1;
    //                     pqWrapper.addPTag = false;
    //                     if(relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c != null && String.isNotBlank(relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c)){
    //                         if(relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c.startsWith('<p>') && relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c.endsWith('</p>')){
    //                             pqWrapper.previousAnswer = relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c.substring(3,relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c.length() - 4);
    //                             pqWrapper.addPTag = true;
    //                         }
    //                         pqWrapper.showButton = true;
    //                         questionsHaveAnswers = questionsHaveAnswers + 1;
    //                         responseWrapper.showRetrieveAllButton = true;
    //                         if(curr.avnio__Answer__c != null && String.isNotBlank(curr.avnio__Answer__c) && curr.avnio__Answer__c.equalsIgnoreCase(relatedPQMap.get(curr.avnio__Question__c.toLowerCase()).avnio__Answer__c)){
    //                             pqWrapper.sameAnswerPresent = true;
    //                         }
    //                     }
    //                     else{
    //                         pqWrapper.showButton = false;
    //                     }
    //                 }
    //                 else{
    //                     for(String relQues : relatedPQMap.keySet()){
    //                         if(relQues.contains(curr.avnio__Question__c.toLowerCase())){
    //                             pqWrapper.previousQuestionId = relatedPQMap.get(relQues).Id;
    //                             pqWrapper.previousQuestion = relatedPQMap.get(relQues).avnio__Question__c;
    //                             pqWrapper.previousAnswer = relatedPQMap.get(relQues).avnio__Answer__c;
    //                             questionsFound = questionsFound + 1;
    //                             pqWrapper.addPTag = false;
    //                             if(relatedPQMap.get(relQues).avnio__Answer__c != null && String.isNotBlank(relatedPQMap.get(relQues).avnio__Answer__c)){
    //                                 if(relatedPQMap.get(relQues).avnio__Answer__c.startsWith('<p>') && relatedPQMap.get(relQues).avnio__Answer__c.endsWith('</p>')){
    //                                     pqWrapper.previousAnswer = relatedPQMap.get(relQues).avnio__Answer__c.substring(3,relatedPQMap.get(relQues).avnio__Answer__c.length() - 4);
    //                                     pqWrapper.addPTag = true;
    //                                 }
    //                                 pqWrapper.showButton = true;
    //                                 questionsHaveAnswers = questionsHaveAnswers + 1;
    //                                 responseWrapper.showRetrieveAllButton = true;
    //                                 if(curr.avnio__Answer__c != null && String.isNotBlank(curr.avnio__Answer__c) && curr.avnio__Answer__c.equalsIgnoreCase(relatedPQMap.get(relQues).avnio__Answer__c)){
    //                                     pqWrapper.sameAnswerPresent = true;
    //                                 }
    //                             }
    //                             else{
    //                                 pqWrapper.showButton = false;
    //                             }
    //                         }
    //                     }
    //                 }
    //                 pqWrapper.isChanged = false;
    //                 pqWrapper.nseCheckbox = curr.NSE__c;
    //                 projectQuestionWrapperList.add(pqWrapper);
    //             }
    //             responseWrapper.projectQuestionWrapperList = projectQuestionWrapperList;
    //             responseWrapper.questionsFound = questionsFound;
    //             responseWrapper.questionsHaveAnswers = questionsHaveAnswers;
    //         }
    //     }
    //     return responseWrapper;
    // }
    
    @AuraEnabled
    public static Boolean updateProjectQuestions(String jsonString) {
        ResponseWrapper responseWrapper = new ResponseWrapper();
        responseWrapper = (ResponseWrapper) JSON.deserialize((String)jsonString, ResponseWrapper.class);
        if(responseWrapper != null && responseWrapper.projectQuestionWrapperList != null && responseWrapper.projectQuestionWrapperList.size() > 0){
            List<avnio__ProjectQuestion__c> quesListToUpdate = new List<avnio__ProjectQuestion__c>();
            for(ProjectQuestionWrapper res : responseWrapper.projectQuestionWrapperList){
                if(res.isChanged && res.currentAnswer != null && String.isNotBlank(res.currentAnswer)){
                    avnio__ProjectQuestion__c pq = new avnio__ProjectQuestion__c();
                    if(res.addPTag){
                        res.currentAnswer = '<p>'+res.currentAnswer+'</p>';
                    }
                    pq.avnio__Answer__c = res.currentAnswer;
                    pq.avnio__Answered__c = true;
                    pq.Id = res.currentQuestionId;
                    pq.Retrieve_From_Previous_Project__c = true;
                    pq.Matching_Project_Id__c = responseWrapper.previousProjectId;
                    pq.Matching_Project_Question_ID__c = res.previousQuestionId;
                    quesListToUpdate.add(pq);
                }
            }
            if(!Test.isRunningTest()){
                update quesListToUpdate;
            }
        }
        return true;
    }

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(String searchKey, String sObjectApiName, String selectedaccountid, String currentprojectid) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        if(sObjectApiName.equalsIgnoreCase('account')){
            string sQuery = 'Select Id,Name From account Where Name Like : sWildCardText order by createdDate DESC LIMIT 10';
            for (sObject obj: database.query(sQuery)) {
                returnList.add(obj);
            } 
        }
        else if(sObjectApiName.equalsIgnoreCase('avnio__project__c')){
            String whereClause = ' ID != :currentprojectid AND (Name Like : sWildCardText OR avnio__ProjectName__c Like : sWildCardText) ';
            if(selectedaccountid != null && String.isNotBlank(selectedaccountid)){
                whereClause = ' avnio__AccountId__c = :selectedaccountid AND ID != :currentprojectid AND (Name Like : sWildCardText OR avnio__ProjectName__c Like : sWildCardText) ';
            }
            string sQuery = 'Select Id,Name,avnio__ProjectName__c From avnio__project__c Where ' + whereClause + ' order by createdDate DESC LIMIT 10';
            for (sObject obj: database.query(sQuery)) {
                returnList.add(obj);
            }
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From avnio__project__c Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    
    public with sharing class ResponseWrapper{
        @AuraEnabled public String previousProjectId;
        @AuraEnabled public String previousProjectName;
        @AuraEnabled public Boolean showRetrieveAllButton;
        @AuraEnabled public String baseUrl;
        @AuraEnabled public Integer questionsFound;
        @AuraEnabled public Integer questionsHaveAnswers;
        @AuraEnabled public List<ProjectQuestionWrapper> projectQuestionWrapperList;
    }

    public with sharing class ProjectQuestionWrapper{
        @AuraEnabled public String currentQuestionId;
        @AuraEnabled public String currentQuestion;
        @AuraEnabled public String currentAnswer;
        @AuraEnabled public String currentInitialAnswer;
        @AuraEnabled public String previousQuestionId;
        @AuraEnabled public String previousQuestion;
        @AuraEnabled public String previousAnswer;
        @AuraEnabled public Boolean isChanged;
        @AuraEnabled public Boolean sameAnswerPresent;
        @AuraEnabled public Boolean showButton;
        @AuraEnabled public Boolean nseCheckbox;
        @AuraEnabled public Boolean addPTag;
    }
}