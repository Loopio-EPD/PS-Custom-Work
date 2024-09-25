/*

*@description: This is controller class for Go No Go page from where users answers go no go questions.

*/
public with sharing class GoNoGoController {

    public static Integer currentGoNoGoScore;
    public static String currentConfigName;
    public static String currentOpportunityId;
    public static String answerId;

    /*

    @description: This method is used to fetch go no go questions

    @param dateInput: Pass the configuration name from which we'll retrive questions

    @return wrapper response which contains list sections and questions

    */
    @AuraEnabled
    public static List<SectionWrapper> getGoNoGOQuestionsFromConfiguration(String configName, String oppId) {
        List<SectionWrapper> sectionWrapperList = new List<SectionWrapper>();

        String existingSubmissionId;
        if(oppId != null && String.isNotBlank(oppId)){
            String objectName = getObjectName(Id.valueOf(oppId));
            if(objectName != null && objectName.equalsIgnoreCase('Go/No-Go Submission')){
                List<Go_No_Go_Answer__c> gonogosublist = [select id, Opportunity__c from Go_No_Go_Answer__c where id = :oppId WITH SECURITY_ENFORCED limit 1];
                if(gonogosublist != null && gonogosublist.size() > 0){
                    existingSubmissionId = gonogosublist[0].Id;
                    oppId = gonogosublist[0].Opportunity__c;
                }
            }
        }

        //get from custom setting
        if(configName == null || String.isBlank(configName)){
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getInstance();
            if(gonogosetting != null){
                configName = gonogosetting.Default_Configuration_Name__c != null && String.isNotBlank(gonogosetting.Default_Configuration_Name__c) ? gonogosetting.Default_Configuration_Name__c : configName;
            }
        }

        //get default first record
        if(configName == null || String.isBlank(configName)){
            Go_No_Go_Configuration__c configRec = [select id, name from Go_No_Go_Configuration__c WITH SECURITY_ENFORCED order by createddate asc limit 1];
            if(configRec != null && configRec.name != null){
                configName = configRec.name;
            }
        }

        if(configName != null && String.isNotBlank(configName)){
            Set<String> opportunityFields = new Set<String>();
            List<Go_No_Go_Question_Bank__c> questionsList = new List<Go_No_Go_Question_Bank__c>();
            questionsList = [select id, name, Go_No_Go_Section__c, Go_No_Go_Section__r.Name, Go_No_Go_Section__r.Section_Sequence__c, Question_Label__c, Question_Sequence__c, Data_Type__c,Make_Required__c, Salesforce_Source__c, (select Id, Name,Go_No_Go_Question_Bank__c, Value__c, Score__c from Go_No_Go_Question_Bank_Scorings__r order by Score__c) from Go_No_Go_Question_Bank__c where Go_No_Go_Section__r.Go_No_Go_Configuration__r.Name =: configName WITH SECURITY_ENFORCED order by Question_Sequence__c limit 49999];          
            if(questionsList != null && questionsList.size() > 0){
                Map<String,List<QuestionWrapper>> sectionToQuestionsMap = new Map<String,List<QuestionWrapper>>();
                Map<String,SectionWrapper> sectionIdToSectionDetails = new Map<String,SectionWrapper>();
                
                Opportunity opportunityRecord;
                for(Go_No_Go_Question_Bank__c innerQues : questionsList){
                    if(innerQues.Data_Type__c != null && innerQues.Data_Type__c.equalsIgnoreCase('Salesforce Input') && innerQues.Salesforce_Source__c != null && String.isNotBlank(innerQues.Salesforce_Source__c)){
                        opportunityFields.add(innerQues.Salesforce_Source__c);
                    }
                }

                if(oppId != null && String.isNotBlank(oppId) && opportunityFields.size() > 0){
                    String fieldsString = String.join(opportunityFields,',');
                    String oppQuery = 'select ' + fieldsString + ' from opportunity where id = :oppId limit 1';
                    List<Opportunity> opportunityList = Database.query(oppQuery);
                    if(opportunityList != null && opportunityList.size() > 0){
                        opportunityRecord = opportunityList[0];
                    }
                }

                for(Go_No_Go_Question_Bank__c singlequestion : questionsList){
                    //Adding Section Details
                    SectionWrapper sectionWrapper = new SectionWrapper();
                    sectionWrapper.sectionId = singlequestion.Go_No_Go_Section__c;
                    sectionWrapper.sectionSequence = singlequestion.Go_No_Go_Section__r.Section_Sequence__c != null ? Integer.valueOf(singlequestion.Go_No_Go_Section__r.Section_Sequence__c) : 0;
                    sectionWrapper.sectionName = singlequestion.Go_No_Go_Section__r.Name;
                    sectionIdToSectionDetails.put(singlequestion.Go_No_Go_Section__c,sectionWrapper);

                    //Creating Questions List
                    List<QuestionWrapper> questionWrapperList = sectionToQuestionsMap.get(singlequestion.Go_No_Go_Section__c) != null ? sectionToQuestionsMap.get(singlequestion.Go_No_Go_Section__c) : new List<QuestionWrapper>();
                    QuestionWrapper questionWrapper = new QuestionWrapper();
                    questionWrapper.questionId = singlequestion.id;
                    questionWrapper.questionLabel = singlequestion.Question_Label__c;
                    questionWrapper.questionSequence = singlequestion.Question_Sequence__c != null ? Integer.valueOf(singlequestion.Question_Sequence__c) : 0;
                    questionWrapper.dataType = singlequestion.Data_Type__c;
                    questionWrapper.sectionId = singlequestion.Go_No_Go_Section__c;
                    questionWrapper.maxScore = 0;
                    questionWrapper.isRequired = singlequestion.Make_Required__c;
                    if(singlequestion.Data_Type__c != null && singlequestion.Data_Type__c.equalsIgnoreCase('Salesforce Input')){
                        questionWrapper.isRequired = false; //as it wont be required even if user marked it as required
                        if(opportunityRecord != null && singlequestion.Salesforce_Source__c != null && String.isNotBlank(singlequestion.Salesforce_Source__c) && opportunityRecord.get(singlequestion.Salesforce_Source__c) != null){
                            questionWrapper.answerValue = String.valueOf(opportunityRecord.get(singlequestion.Salesforce_Source__c));
                        }
                        else {
                            questionWrapper.answerValue = '[no value]';
                        }
                    }
                    List<ScoringWrapper> scoringRecords = new List<ScoringWrapper>();
                    for(Go_No_Go_Question_Bank_Scoring__c scoringRec : singlequestion.Go_No_Go_Question_Bank_Scorings__r) {
                        ScoringWrapper scoringWrapper = new ScoringWrapper();
                        scoringWrapper.scoringId = scoringRec.id;
                        scoringWrapper.value = scoringRec.Value__c;
                        scoringWrapper.score = scoringRec.Score__c != null ? Integer.valueOf(scoringRec.Score__c) : 0;
                        if(scoringRec.Score__c != null && Integer.valueOf(scoringRec.Score__c) > questionWrapper.maxScore){
                            questionWrapper.maxScore = Integer.valueOf(scoringRec.Score__c);
                        }
                        scoringRecords.add(scoringWrapper);
                    }
                    questionWrapper.scoringRecords = scoringRecords;
                    questionWrapperList.add(questionWrapper);
                    sectionToQuestionsMap.put(singlequestion.Go_No_Go_Section__c,questionWrapperList);
                }

                //Creating final section list
                for(String sectionId : sectionToQuestionsMap.keySet()){
                    SectionWrapper sectionWrapper = sectionIdToSectionDetails.get(sectionId);
                    if(sectionWrapper != null){
                        sectionWrapper.questionRecords = sectionToQuestionsMap.get(sectionId);
                        sectionWrapperList.add(sectionWrapper);
                    }
                }
            }
        }
        return sectionWrapperList;
    }

    /*

    @description: This method is used to save go no go answers

    @param dateInput: Pass json foramtted data of questions and answers and opportunity Id

    @return wrapper response which contains score, status

    */
    @AuraEnabled
    public static ResultWrapper saveAnswerRecords(String jsonString, String oppId, String selectedLinkedConfig){

        Boolean isLinkedConfig = selectedLinkedConfig != null && String.isNotBlank(selectedLinkedConfig) ? true : false;
        ResultWrapper resultWrapper = new ResultWrapper();
        resultWrapper.isSuccess = false;
        String existingSubmissionId;
        Boolean linkedConfigsDone = false;
        Integer linkedConfigsCount, linkedConfigsDoneCount;
        Integer totalScoreForLiknkedConfigs;
        List<String> scoreBreakdownAll = new List<String>();
        if(oppId != null && String.isNotBlank(oppId)){
            String objectName = getObjectName(Id.valueOf(oppId));
            if(objectName != null && objectName.equalsIgnoreCase('Go/No-Go Submission')){
                List<Go_No_Go_Answer__c> gonogosublist = [select id, Opportunity__c from Go_No_Go_Answer__c where id = :oppId WITH SECURITY_ENFORCED limit 1];
                if(gonogosublist != null && gonogosublist.size() > 0){
                    existingSubmissionId = gonogosublist[0].Id;
                    oppId = gonogosublist[0].Opportunity__c;

                    List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id,Name,Go_No_Go_Configuration__c,Go_No_Go_Configuration__r.Name from Go_No_Go_Linked_Configuration__c where Go_No_Go_Configuration__c != null WITH SECURITY_ENFORCED limit 49999];
                    Set<Id> linkedConfigsIdSet = new Set<Id>();
                    if(linkedConfigs != null && linkedConfigs.size() > 0){
                        for(Go_No_Go_Linked_Configuration__c linkedConfig : linkedConfigs){
                            linkedConfigsIdSet.add(linkedConfig.id);
                        }
                    }
                    
                    linkedConfigsCount = linkedConfigsIdSet.size();
                    resultWrapper.linkedConfigsCount = linkedConfigsCount;
                    List<Go_No_Go_Linked_Submission__c> linkedSubmissionRecords = [select id,Name,Go_No_Go_Configuration__c,Score__c,Score_Breakdown__c,Go_No_Go_Submission__r.Go_No_Go_Score__c from Go_No_Go_Linked_Submission__c where Go_No_Go_Configuration__c != null AND Go_No_Go_Submission__c = :existingSubmissionId WITH SECURITY_ENFORCED limit 49999];
                    if(linkedSubmissionRecords != null && linkedSubmissionRecords.size() > 0){
                        linkedConfigsDoneCount = linkedSubmissionRecords.size();
                        resultWrapper.linkedConfigsDoneCount = linkedConfigsDoneCount + 1;
                        if(linkedConfigsCount == linkedConfigsDoneCount + 1){
                            linkedConfigsDone = true;
                        }
                        for(Go_No_Go_Linked_Submission__c lcs : linkedSubmissionRecords){
                            totalScoreForLiknkedConfigs = totalScoreForLiknkedConfigs != null ? totalScoreForLiknkedConfigs + Integer.valueOf(lcs.Score__c) : Integer.valueOf(lcs.Score__c);
                            //scoreBreakdownAll.add(lcs.Score_Breakdown__c);
                        }
                    }
                }
            }
        }

        List<SectionWrapper> sectionWrapperList = new List<SectionWrapper>();
        sectionWrapperList = (List<SectionWrapper>) JSON.deserialize((String)jsonString, List<SectionWrapper>.class);
        Go_No_Go_Answer__c answerRec = new Go_No_Go_Answer__c();
        Integer gonogoscore = 0;
        if(sectionWrapperList != null && sectionWrapperList.size() > 0){
            List<Go_No_Go_Answer_Item__c> answerItemList = new List<Go_No_Go_Answer_Item__c>();
            if(existingSubmissionId != null){
                answerRec.Id = existingSubmissionId;
            }
            else{
                answerRec.Opportunity__c = oppId;
                if(Go_No_Go_Answer__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Answer__c.SObjectType.getDescribe().isCreateable() &&
                    Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isCreateable()){
                    insert answerRec;
                }
                else{
                    return resultWrapper;
                }
            }
            resultWrapper.gonogoanswerId = String.valueOf(answerRec.Id);
            Integer maxPossibleScore = 0, scoreOnAnswer = 0;
            for(SectionWrapper singleSection : sectionWrapperList){
                List<QuestionWrapper> questionRecords = singleSection.questionRecords;
                if(questionRecords != null && questionRecords.size() > 0){
                    for(QuestionWrapper ques : questionRecords){
                        maxPossibleScore = maxPossibleScore + ques.maxScore;
                        Go_No_Go_Answer_Item__c answerItem = new Go_No_Go_Answer_Item__c();
                        answerItem.Go_No_Go_Answer__c = answerRec.Id;
                        answerItem.Go_No_Go_Question_Bank__c = ques.questionId;
                        answerItem.Question__c = ques.questionLabel;
                        if(ques.answerValue != null && String.isNotBlank(ques.answerValue)){
                            answerItem.Value__c = ques.answerValue;
                            if(ques.scoringRecords != null && ques.scoringRecords.size() > 0){
                                for(ScoringWrapper scoreWrapper : ques.scoringRecords){
                                    if(scoreWrapper.scoringId != null && String.isNotBlank(scoreWrapper.scoringId) && scoreWrapper.value != null && String.isNotBlank(scoreWrapper.value)){
                                        if(scoreWrapper.score != null && ques.answerValue.toLowerCase().equalsIgnoreCase(scoreWrapper.value.toLowerCase())){
                                            answerItem.Go_No_Go_Question_Bank_Scoring__c = scoreWrapper.scoringId;
                                            scoreOnAnswer = scoreOnAnswer + scoreWrapper.score;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        answerItemList.add(answerItem);
                    }
                }
            }

            if(Go_No_Go_Answer_Item__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Answer_Item__c.SObjectType.getDescribe().isCreateable() &&
                Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Go_No_Go_Answer__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Go_No_Go_Answer__c.isCreateable() &&
                Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Go_No_Go_Question_Bank__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Go_No_Go_Question_Bank__c.isCreateable() &&
                Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Question__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Question__c.isCreateable() &&
                Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Value__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Value__c.isCreateable() &&
                Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Go_No_Go_Question_Bank_Scoring__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer_Item__c.fields.Go_No_Go_Question_Bank_Scoring__c.isCreateable()){
                    insert answerItemList;
            }
            else{
                return resultWrapper;
            }
            
            String gonogoScoreBreakdown = '';
            if(scoreOnAnswer > 0 && maxPossibleScore > 0){
                gonogoscore = (Integer)scoreOnAnswer*100/maxPossibleScore;
                gonogoScoreBreakdown = String.valueOf((Integer)scoreOnAnswer) + '/' + String.valueOf(maxPossibleScore);
            }

            List<GoNoGoStatus__c> gonogostatuslist = [select id,Name, Min_Range__c, Max_Range__c, Static_Resource_Name__c from GoNoGoStatus__c WITH SECURITY_ENFORCED limit 49999];
            if(gonogostatuslist != null && gonogostatuslist.size() > 0){
                for(GoNoGoStatus__c gonogostatus : gonogostatuslist){
                    if(gonogostatus.Min_Range__c != null && gonogostatus.Max_Range__c != null && gonogostatus.Static_Resource_Name__c != null && String.isNotBlank(gonogostatus.Static_Resource_Name__c) && gonogoscore >= Integer.valueOf(gonogostatus.Min_Range__c) && gonogoscore <= Integer.valueOf(gonogostatus.Max_Range__c)){
                        if(isLinkedConfig){
                            answerRec.Status_Label__c = 'Pending';
                        }
                        else{
                            answerRec.Status_Label__c = gonogostatus.Name;
                            answerRec.Static_Resource_Name__c = 'loopio_ext__' + gonogostatus.Static_Resource_Name__c;
                        }
                        resultWrapper.staticresourcename = 'loopio_ext__' + gonogostatus.Static_Resource_Name__c;
                        resultWrapper.statuslabel = gonogostatus.Name;
                        break;
                    }
                }
            }
            resultWrapper.gonogoscore = gonogoscore;
            resultWrapper.isSuccess = true;
            if(isLinkedConfig){
                List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id,Go_No_Go_Configuration__c from Go_No_Go_Linked_Configuration__c where Id = :selectedLinkedConfig AND Go_No_Go_Configuration__c != null WITH SECURITY_ENFORCED limit 1];
                if(linkedConfigs != null && linkedConfigs.size() > 0){
                    if(existingSubmissionId == null){
                        resultWrapper.linkedConfigsCount = linkedConfigs.size();
                        resultWrapper.linkedConfigsDoneCount = 1;
                    }
                    Go_No_Go_Linked_Submission__c linkedSubmission = new Go_No_Go_Linked_Submission__c();
                    linkedSubmission.Go_No_Go_Submission__c = answerRec.Id;
                    linkedSubmission.Go_No_Go_Configuration__c = linkedConfigs[0].Go_No_Go_Configuration__c;
                    linkedSubmission.Score__c = gonogoscore;
                    linkedSubmission.Score_Breakdown__c = 'Average';
                    if(Go_No_Go_Linked_Submission__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Linked_Submission__c.SObjectType.getDescribe().isCreateable() &&
                        Schema.SObjectType.Go_No_Go_Linked_Submission__c.fields.Go_No_Go_Configuration__c.isAccessible() && Schema.SObjectType.Go_No_Go_Linked_Submission__c.fields.Go_No_Go_Configuration__c.isCreateable() &&
                        Schema.SObjectType.Go_No_Go_Linked_Submission__c.fields.Score__c.isAccessible() && Schema.SObjectType.Go_No_Go_Linked_Submission__c.fields.Score__c.isCreateable() &&
                        Schema.SObjectType.Go_No_Go_Linked_Submission__c.fields.Score_Breakdown__c.isAccessible() && Schema.SObjectType.Go_No_Go_Linked_Submission__c.fields.Score_Breakdown__c.isCreateable()){
                            insert linkedSubmission;
                    }
                }
                if(linkedConfigsDone){
                    resultWrapper.lastConfigScore = resultWrapper.gonogoscore;
                    resultWrapper.lastConfigStatusLabel = resultWrapper.statuslabel;
                    resultWrapper.lastConfigStaticresourcename = resultWrapper.staticresourcename;
                    gonogoscore = (gonogoscore + totalScoreForLiknkedConfigs)/linkedConfigsCount;
                    //scoreBreakdownAll.add(gonogoScoreBreakdown);
                    answerRec.Go_No_Go_Score__c = gonogoscore;
                    answerRec.Score_Breakdown__c = 'Average';
                    resultWrapper.gonogoscore = gonogoscore;
                    for(GoNoGoStatus__c gonogostatus : gonogostatuslist){
                        if(gonogostatus.Min_Range__c != null && gonogostatus.Max_Range__c != null && gonogostatus.Static_Resource_Name__c != null && String.isNotBlank(gonogostatus.Static_Resource_Name__c) && gonogoscore >= Integer.valueOf(gonogostatus.Min_Range__c) && gonogoscore <= Integer.valueOf(gonogostatus.Max_Range__c)){
                            answerRec.Status_Label__c = gonogostatus.Name;
                            answerRec.Static_Resource_Name__c = 'loopio_ext__' + gonogostatus.Static_Resource_Name__c;
                            resultWrapper.staticresourcename = 'loopio_ext__' + gonogostatus.Static_Resource_Name__c;
                            resultWrapper.statuslabel = gonogostatus.Name;
                            break;
                        }
                    }
                }
            }
            else{
                answerRec.Go_No_Go_Score__c = gonogoscore;
                answerRec.Score_Breakdown__c = 'Average';
            }
            if(Go_No_Go_Answer__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Answer__c.SObjectType.getDescribe().isCreateable() && Go_No_Go_Answer__c.SObjectType.getDescribe().isUpdateable() &&
                Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isCreateable() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isUpdateable() &&
                Schema.SObjectType.Go_No_Go_Answer__c.fields.Static_Resource_Name__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Static_Resource_Name__c.isCreateable() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Static_Resource_Name__c.isUpdateable() &&
                Schema.SObjectType.Go_No_Go_Answer__c.fields.Status_Label__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Status_Label__c.isCreateable() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Status_Label__c.isUpdateable() &&
                Schema.SObjectType.Go_No_Go_Answer__c.fields.Go_No_Go_Score__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Go_No_Go_Score__c.isCreateable() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Go_No_Go_Score__c.isUpdateable() &&
                Schema.SObjectType.Go_No_Go_Answer__c.fields.Score_Breakdown__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Score_Breakdown__c.isCreateable() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Score_Breakdown__c.isUpdateable()){
                    update answerRec;
            }
            
            //check if approval process present
            resultWrapper.approvalProcessPresent = false;
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getorgdefaults();
            if(gonogosetting != null && (gonogosetting.Disable_Answer_Trigger__c || !gonogosetting.Auto_Submit_for_Approval__c) && gonogosetting.Threshold_Score_for_Approval__c != null && gonogoscore <= Integer.valueOf(gonogosetting.Threshold_Score_for_Approval__c)){
                List<ProcessDefinition> approvalProcess = [SELECT Id,Name, DeveloperName, TableEnumOrId,Description, State, Type from ProcessDefinition where type ='approval' and State ='Active' and TableEnumOrId ='loopio_ext__Go_No_Go_Answer__c' WITH SECURITY_ENFORCED];
                if(approvalProcess != null && approvalProcess.size() > 0){
                    resultWrapper.approvalProcessPresent = true;
                    answerRec.Approval_Status__c = 'Approval Required';
                    if(Go_No_Go_Answer__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Answer__c.SObjectType.getDescribe().isUpdateable() &&
                        Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isCreateable() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isUpdateable() &&
                        Schema.SObjectType.Go_No_Go_Answer__c.fields.Static_Resource_Name__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Static_Resource_Name__c.isCreateable() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Static_Resource_Name__c.isUpdateable() &&
                        Schema.SObjectType.Go_No_Go_Answer__c.fields.Go_No_Go_Score__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Go_No_Go_Score__c.isCreateable() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Go_No_Go_Score__c.isUpdateable() &&
                        Schema.SObjectType.Go_No_Go_Answer__c.fields.Approval_Status__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Approval_Status__c.isCreateable() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Approval_Status__c.isUpdateable()){
                            update answerRec;
                    }
                }
            }
        }
        resultWrapper.isLoopioPresent = false;
        try{
            String loopioProjQuery = 'select id from Loopio__Loopio_Project__c LIMIT 1';
            List<Sobject> loopioProj = Database.query(loopioProjQuery);
            resultWrapper.isLoopioPresent = true;
        } catch(Exception e){}
        
        resultWrapper.isAvnioPresent = false;
        try {
            String avnioProjQuery = 'select id from avnio__Project__c LIMIT 1';
            List<Sobject> avnioProj = Database.query(avnioProjQuery);
            resultWrapper.isAvnioPresent = true;
        } catch(QueryException e) {}
        try {
            currentGoNoGoScore = gonogoscore;
            if(selectedLinkedConfig != null && String.isNotBlank(selectedLinkedConfig)){
                List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id,Go_No_Go_Configuration__c, Go_No_Go_Configuration__r.Name from Go_No_Go_Linked_Configuration__c where Id = :selectedLinkedConfig AND Go_No_Go_Configuration__c != null WITH SECURITY_ENFORCED limit 1];
                if(linkedConfigs != null && linkedConfigs.size() > 0){
                    currentConfigName = linkedConfigs[0].Go_No_Go_Configuration__r.Name;
                }
            }
            else{
                GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getInstance();
                if(gonogosetting != null){
                    currentConfigName = gonogosetting.Default_Configuration_Name__c != null && String.isNotBlank(gonogosetting.Default_Configuration_Name__c) ? gonogosetting.Default_Configuration_Name__c : '';
                }
            }
        	sendEmailToOppOwnerForCompletion(oppId,String.valueOf(answerRec.Id));
        } catch(Exception e) {}
        return resultWrapper;
    }

    /*

    @description: This method is used to send go no go answer record for approval

    @param dateInput: Pass answer Id

    @return if scoring records saved successfully or not

    */
    @AuraEnabled
    public static Boolean submitForApproval(String answerId) {
        Boolean isSuccess = false;
        try{
            List<ProcessDefinition> approvalProcess = [SELECT Id,Name, DeveloperName, TableEnumOrId,Description, State, Type from ProcessDefinition where type ='approval' and State ='Active' and TableEnumOrId ='loopio_ext__Go_No_Go_Answer__c' WITH SECURITY_ENFORCED];
            if(approvalProcess != null && approvalProcess.size() > 0){
                String approvalProcessName = approvalProcess[0].DeveloperName;
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting Go/No-Go request for approval.');
                req1.setObjectId(answerId);
                
                // Submit on behalf of a specific submitter
                req1.setSubmitterId(userinfo.getUserId()); 
                
                // Submit the record to specific process and skip the criteria evaluation
                req1.setProcessDefinitionNameOrId(approvalProcessName);
                req1.setSkipEntryCriteria(true);
                
                // Submit the approval request for the record
                Approval.ProcessResult result = Approval.process(req1);
                
                isSuccess = result.isSuccess();
            }
        }
        catch(Exception e){}
        return isSuccess;
    }

    /*

    @description: This method is used to check if answer is approved or not

    @param dateInput: Pass answer Id

    @return wrapper response which contains approval status

    */
    @AuraEnabled
    public static ResultWrapper checkIfApproved(String answerId) {
        ResultWrapper resultWrapper = new ResultWrapper();
        resultWrapper.isSuccess = false;
        resultWrapper.errorMsg = 'Go/No Record id is empty.';
        if(answerId != null && String.isNotBlank(answerId)){
            String objectName = getObjectName(Id.valueOf(answerId));
            List<Go_No_Go_Answer__c> gonogosublist = [select id, Opportunity__c, Opportunity__r.AccountId from Go_No_Go_Answer__c where id = :answerId WITH SECURITY_ENFORCED limit 1];
            if(gonogosublist != null && gonogosublist.size() > 0){
                resultWrapper.opportunityId = gonogosublist[0].Opportunity__c;
                resultWrapper.accountId = gonogosublist[0].Opportunity__r.AccountId;
            }
        }
        if(answerId != null && String.isNotBlank(answerId)){
            Boolean isApproved = false;
            List<Go_No_Go_Answer__c> answerRecords = [select id,name,Approved__c, Status_Label__c, Opportunity__c, Approval_Required__c, Opportunity__r.AccountId from Go_No_Go_Answer__c where id =:answerId WITH SECURITY_ENFORCED];
            resultWrapper.errorMsg = 'No Go/No Record is present with provided id.';
            if(answerRecords != null && answerRecords.size() > 0){
                resultWrapper.isSuccess = true;
                if(answerRecords[0].Approval_Required__c){
                    isApproved = answerRecords[0].Approved__c;
                }
                else{
                    isApproved = true;
                }
                resultWrapper.statuslabel = answerRecords[0].Status_Label__c;
                resultWrapper.opportunityId = answerRecords[0].Opportunity__c;
                resultWrapper.accountId = answerRecords[0].Opportunity__r.AccountId;
            }
            resultWrapper.isApproved = isApproved;
        }
        resultWrapper.isLoopioPresent = false;
        try{
            String loopioProjQuery = 'select id from Loopio__Loopio_Project__c LIMIT 1';
            List<Sobject> loopioProj = Database.query(loopioProjQuery);
            resultWrapper.isLoopioPresent = true;
        } catch(Exception e){}

        resultWrapper.isAvnioPresent = false;
        try {
            String avnioProjQuery = 'select id from avnio__Project__c LIMIT 1';
            List<Sobject> avnioProj = Database.query(avnioProjQuery);
            resultWrapper.isAvnioPresent = true;
        } catch(QueryException e) {}
        resultWrapper.recordTypesForLFS = getRecordTypesForLFS();
        return resultWrapper;
    }

    @AuraEnabled
    public static GoNoGoSettingsWrapper getDefaultConfigurations() {
        GoNoGoSettingsWrapper goNoGoSettingsWrapper = new GoNoGoSettingsWrapper();
        goNoGoSettingsWrapper.hasadminaccess = false;
        GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
        if(gonogosetting != null){
            goNoGoSettingsWrapper.defaultConfigName = gonogosetting.Default_Configuration_Name__c;
            goNoGoSettingsWrapper.thresholdvalue = gonogosetting.Threshold_Score_for_Approval__c != null ? Integer.valueOf(gonogosetting.Threshold_Score_for_Approval__c) : null;
            goNoGoSettingsWrapper.autoSubmitForApproval = gonogosetting.Auto_Submit_for_Approval__c;
            goNoGoSettingsWrapper.asigneeNotification = gonogosetting.Assignee_Notification__c;
            goNoGoSettingsWrapper.selectedOppStatus = gonogosetting.Opportunity_Stage_For_Notification__c;
            goNoGoSettingsWrapper.reminderNotification = gonogosetting.Reminder_Notification__c;
            goNoGoSettingsWrapper.reminderNotificationDays = gonogosetting.Days_For_Reminder_Notification__c != null ? String.valueOf(Integer.valueOf(gonogosetting.Days_For_Reminder_Notification__c)) : null;
        }

        try{
            List<Profile> myprofile = [SELECT id,Name FROM Profile WHERE PermissionsModifyAllData = true and id = :UserInfo.getProfileId() WITH SECURITY_ENFORCED];
            if(myprofile != null && myprofile.size() > 0){
                goNoGoSettingsWrapper.hasadminaccess = true;
            }
        }
        catch(Exception e){}

        // String relativePath = '/setup/ui/listCustomSettingsData.apexp';
        // String queryString = '?id=' + SObjectType.Loopio_Ext__GoNoGoSetting__c.getKeyPrefix();
        goNoGoSettingsWrapper.manageCustomSettingUrl = '/lightning/setup/CustomSettings/page?address=%2Fsetup%2Fui%2FlistCustomSettingsData.apexp%3Fid%3D' + SObjectType.Loopio_Ext__GoNoGoSetting__c.getKeyPrefix();

        List<Go_No_Go_Configuration__c> configRecords = [select id, name from Go_No_Go_Configuration__c WITH SECURITY_ENFORCED order by createddate asc limit 49999];
        if(configRecords != null && configRecords.size() > 0){
            List<PickListWrapper> availableConfigurationsList = new List<PickListWrapper>();
            List<PickListWrapper> linkedConfigList = new List<PickListWrapper>();
            for(Go_No_Go_Configuration__c conf : configRecords){
                PickListWrapper pickListWrapper = new PickListWrapper();
                pickListWrapper.value = conf.name;
                pickListWrapper.label = conf.name;
                availableConfigurationsList.add(pickListWrapper);

                PickListWrapper pickListWrapperLinked = new PickListWrapper();
                pickListWrapperLinked.value = conf.id;
                pickListWrapperLinked.label = conf.name;
                linkedConfigList.add(pickListWrapperLinked);                
            }
            goNoGoSettingsWrapper.availableConfigurationsList = availableConfigurationsList;
            goNoGoSettingsWrapper.linkedConfigList = linkedConfigList;
        }

        List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id,Name from Go_No_Go_Linked_Configuration__c WITH SECURITY_ENFORCED limit 1];
        if(linkedConfigs != null && linkedConfigs.size() > 0){
            goNoGoSettingsWrapper.linkedConfigName = linkedConfigs[0].Name;
        }
        goNoGoSettingsWrapper.goNoGoStatusWrapperList = getStatusWrapperList();
        
        //get opportunity stages
        List<PickListWrapper> opportunityStatuses = new List<PickListWrapper>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{'opportunity'});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get('StageName').getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    PickListWrapper oppStatus = new PickListWrapper();
                    oppStatus.value = entry.getValue();
                    oppStatus.label = entry.getLabel();
                    opportunityStatuses.add(oppStatus);
                }
            }
        }
        goNoGoSettingsWrapper.opportunityStatuses = opportunityStatuses;
        return goNoGoSettingsWrapper;
    }

    @AuraEnabled
    public static ResultWrapper updateDefaultConfigName(String defaultConfigNameNew) {
        ResultWrapper resultWrapper = new ResultWrapper();
        resultWrapper.isSuccess = false;
        resultWrapper.errorMsg = 'Something went wrong. Please try again later.';
        if(defaultConfigNameNew == null || String.isBlank(defaultConfigNameNew)){
            resultWrapper.errorMsg = 'Please select the configuration name.';
            return resultWrapper;
        }
        try{
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
            gonogosetting.Default_Configuration_Name__c = defaultConfigNameNew;
            Database.upsert(gonogosetting);
            List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id from Go_No_Go_Linked_Configuration__c WITH SECURITY_ENFORCED limit 49999];
            if(linkedConfigs != null && linkedConfigs.size() > 0){
                if(Go_No_Go_Linked_Configuration__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Linked_Configuration__c.SObjectType.getDescribe().isDeletable()) {
                    delete linkedConfigs;
                }
            }
            resultWrapper.isSuccess = true;
        }
        catch(Exception e){}
        return resultWrapper;
    }

    @AuraEnabled
    public static ResultWrapper updateThreshold(Integer thresholdNew, Boolean autoSubmitForApprovalNew) {
        ResultWrapper resultWrapper = new ResultWrapper();
        resultWrapper.isSuccess = false;
        resultWrapper.errorMsg = 'Something went wrong. Please try again later.';
        try{
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
            gonogosetting.Threshold_Score_for_Approval__c = thresholdNew;
            gonogosetting.Auto_Submit_for_Approval__c = autoSubmitForApprovalNew;
            Database.upsert(gonogosetting);
            resultWrapper.isSuccess = true;
        }
        catch(Exception e){}
        return resultWrapper;
    }

    @AuraEnabled
    public static ResultWrapper updateStatusValues(String statusListJson, List<String> statusIdsToDelete) {
        ResultWrapper resultWrapper = new ResultWrapper();
        resultWrapper.isSuccess = false;
        resultWrapper.errorMsg = 'Something went wrong. Please try again later.';
        try{
            List<GoNoGoStatusWrapper> statusWrapperList = (List<GoNoGoStatusWrapper>) JSON.deserialize((String)statusListJson, List<GoNoGoStatusWrapper>.class);
            if(statusWrapperList != null && statusWrapperList.size() > 0){
                List<GoNoGoStatus__c> gonogostatusToUpsert = new List<GoNoGoStatus__c>();
                for(GoNoGoStatusWrapper statusWrapper : statusWrapperList){
                    GoNoGoStatus__c gonogostatus = new GoNoGoStatus__c();
                    if(statusWrapper.statusid != null && statusWrapper.statusid.length() != 10 && statusWrapper.statusid.length() > 10){
                        gonogostatus.Id = statusWrapper.statusid;
                    }
                    gonogostatus.Name = statusWrapper.label;
                    gonogostatus.Min_Range__c = statusWrapper.minrange;
                    gonogostatus.Max_Range__c = statusWrapper.maxrange;
                    gonogostatus.Static_Resource_Name__c = statusWrapper.staticresourcename;
                    gonogostatusToUpsert.add(gonogostatus);
                }

                if(GoNoGoStatus__c.SObjectType.getDescribe().isAccessible() && GoNoGoStatus__c.SObjectType.getDescribe().isCreateable() && GoNoGoStatus__c.SObjectType.getDescribe().isUpdateable() &&
                    Schema.SObjectType.GoNoGoStatus__c.fields.Name.isAccessible() && Schema.SObjectType.GoNoGoStatus__c.fields.Name.isCreateable() && Schema.SObjectType.GoNoGoStatus__c.fields.Name.isUpdateable() &&
                    Schema.SObjectType.GoNoGoStatus__c.fields.Min_Range__c.isAccessible() && Schema.SObjectType.GoNoGoStatus__c.fields.Min_Range__c.isCreateable() && Schema.SObjectType.GoNoGoStatus__c.fields.Min_Range__c.isUpdateable() &&
                    Schema.SObjectType.GoNoGoStatus__c.fields.Max_Range__c.isAccessible() && Schema.SObjectType.GoNoGoStatus__c.fields.Max_Range__c.isCreateable() && Schema.SObjectType.GoNoGoStatus__c.fields.Max_Range__c.isUpdateable() &&
                    Schema.SObjectType.GoNoGoStatus__c.fields.Static_Resource_Name__c.isAccessible() && Schema.SObjectType.GoNoGoStatus__c.fields.Static_Resource_Name__c.isCreateable() && Schema.SObjectType.GoNoGoStatus__c.fields.Static_Resource_Name__c.isUpdateable()){
                        upsert gonogostatusToUpsert;
                }
                
                resultWrapper.isSuccess = true;

                if(statusIdsToDelete != null && statusIdsToDelete.size() > 0){
                    List<GoNoGoStatus__c> gonogostatusToDelete = [select id from GoNoGoStatus__c where Id IN :statusIdsToDelete];
                    if(gonogostatusToDelete != null && gonogostatusToDelete.size() > 0){
                        if(GoNoGoStatus__c.SObjectType.getDescribe().isAccessible() && GoNoGoStatus__c.SObjectType.getDescribe().isDeletable()) {
                            delete gonogostatusToDelete;
                        }
                    }
                }
            }
            resultWrapper.goNoGoStatusWrapperList = getStatusWrapperList();
        }
        catch(Exception e){}
        return resultWrapper;
    }


    public static List<GoNoGoStatusWrapper> getStatusWrapperList(){
        List<GoNoGoStatusWrapper> goNoGoStatusWrapperList = new List<GoNoGoStatusWrapper>();
        List<GoNoGoStatus__c> gonogostatuslist = [select id, Name, Min_Range__c, Max_Range__c, Static_Resource_Name__c from GoNoGoStatus__c WITH SECURITY_ENFORCED limit 49999];
        if(gonogostatuslist != null && gonogostatuslist.size() > 0){
            for(GoNoGoStatus__c gonogostatus : gonogostatuslist){
                GoNoGoStatusWrapper goNoGoStatusWrapper = new GoNoGoStatusWrapper();
                goNoGoStatusWrapper.statusid = gonogostatus.id;
                goNoGoStatusWrapper.label = gonogostatus.Name;
                goNoGoStatusWrapper.minrange = gonogostatus.Min_Range__c != null ? Integer.valueOf(gonogostatus.Min_Range__c) : null;
                goNoGoStatusWrapper.maxrange = gonogostatus.Max_Range__c != null ? Integer.valueOf(gonogostatus.Max_Range__c) : null;
                goNoGoStatusWrapper.staticresourcename = gonogostatus.Static_Resource_Name__c;
                goNoGoStatusWrapperList.add(goNoGoStatusWrapper);
            }
        }
        return goNoGoStatusWrapperList;
    }

    @AuraEnabled
    public static PickListWrapper getTotalMaxScore(String recordId){
        PickListWrapper result = new PickListWrapper();
        try{
            if(recordId != null && String.isNotBlank(recordId)){
                String objectAPIName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
                String query = 'select id, Sum_of_Max_Scores__c from ' + objectAPIName + ' where Id = :recordId WITH SECURITY_ENFORCED limit 1';
                List<SObject> recordsretrived = Database.query(query);
                if(recordsretrived != null && recordsretrived.size() > 0){
                    if(recordsretrived[0].get('Sum_of_Max_Scores__c') != null && String.valueOf(recordsretrived[0].get('Sum_of_Max_Scores__c')) != null){
                        result.value = String.valueOf(recordsretrived[0].get('Sum_of_Max_Scores__c'));
                        if(objectAPIName.toLowerCase().contains('configuration')){
                            result.label = 'Configuration';
                        }
                        else if(objectAPIName.toLowerCase().contains('section')){
                            result.label = 'Section';
                        }
                    }
                }
            }
        }
        catch(Exception e){}
        return result;
    }

    @AuraEnabled
    public static ResultWrapper saveNewConfiguration(String configname, String configurationOwnerId) {
        ResultWrapper resultWrapper = new ResultWrapper();
        resultWrapper.isSuccess = false;
        resultWrapper.errorMsg = 'Something went wrong. Please try again later.';
        
        Go_No_Go_Configuration__c config = new Go_No_Go_Configuration__c();
        config.Name = configname;
        if(configurationOwnerId != null && String.isNotBlank(configurationOwnerId)){
            config.ownerId = configurationOwnerId;
        }
        if(Go_No_Go_Configuration__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Configuration__c.SObjectType.getDescribe().isCreateable()){
            insert config;
            resultWrapper.isSuccess = true;
            resultWrapper.errorMsg = config.Id;
        }
        else{
            return resultWrapper;
        }
        return resultWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> getSObjectList(String searchKey, String objectName){
        string searchKeyword = '%' + searchKey + '%';
		
        String query = 'Select id,Name From ' + objectName + ' WHERE name LIKE : searchKeyword limit 10';
        List<SObject> sobjectList = Database.query(query);
    
        if(sobjectList.size() == 0){
            throw new AuraHandledException('No record found..'); 
        }
         
        return sobjectList;
    }

    @AuraEnabled
    public static sObject fetchDefaultRecord(String recordId , String sObjectApiName){
        string sRecId = recordId;
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: Database.query(sQuery)){
        	return obj;
        }
        return null;
    }

    @AuraEnabled
    public static Map<String,Object> upsertQuestionRecord(String questionId, String sectionId, Integer questionsequence, Integer maxscore, String datatype, String questionlabel, Boolean makerequired, String opportuntityFieldAPIName){
        Map<String,Object> result = new Map<String,Object>();
		try{
            Go_No_Go_Question_Bank__c gonogoquestion = new Go_No_Go_Question_Bank__c();
            gonogoquestion.Go_No_Go_Section__c = sectionId;
            gonogoquestion.Question_Sequence__c = questionsequence;
            gonogoquestion.Max_Score__c = maxscore;
            gonogoquestion.Data_Type__c = datatype;
            gonogoquestion.Question_Label__c = questionlabel;
            gonogoquestion.Make_Required__c = makerequired;
            gonogoquestion.Salesforce_Source__c = opportuntityFieldAPIName;

            if(questionId != null && String.isNotBlank(questionId)){
                gonogoquestion.Id = questionId;
                update gonogoquestion;
            }
            else{
                insert gonogoquestion;
            }

			result.put('status', 'success');
		    result.put('recordId', String.valueOf(gonogoquestion.Id));
		}
		catch(Exception e){
            result.put('status', 'error');
			result.put('errorMessage', e.getMessage());
        }
		return result;
    }

    @AuraEnabled
    public static GoNoGoQuestionWrapper loadDataForGoNoGoQuestion(String questionId){
        GoNoGoQuestionWrapper goNoGoQuestionWrapper = new GoNoGoQuestionWrapper();
        List<PickListWrapper> dataTypesOptions = new List<PickListWrapper>();
        Schema.DescribeFieldResult fieldResult = Go_No_Go_Question_Bank__c.Data_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            PickListWrapper pickListWrapper = new PickListWrapper();
            pickListWrapper.label = f.getLabel();
            pickListWrapper.value = f.getValue();
            dataTypesOptions.add(pickListWrapper);
        }
        goNoGoQuestionWrapper.dataTypesOptions = dataTypesOptions;

        List<PickListWrapper> opportunityFields = new List<PickListWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Opportunity').getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keyset()){
            Schema.DescribeFieldResult fieldDescr = fieldMap.get( fieldName ).getDescribe();
            PickListWrapper pickListWrapper = new PickListWrapper();
            pickListWrapper.label = fieldDescr.getLabel();
            pickListWrapper.value = fieldName;
            opportunityFields.add(pickListWrapper);
        }
        goNoGoQuestionWrapper.opportunityFields = opportunityFields;

        if(questionId != null && String.isNotBlank(questionId)){
            List<Go_No_Go_Question_Bank__c> questionsList = new List<Go_No_Go_Question_Bank__c>();
            questionsList = [select id, name, Go_No_Go_Section__c, Question_Label__c, Question_Sequence__c, Data_Type__c, Make_Required__c, Max_Score__c, Salesforce_Source__c from Go_No_Go_Question_Bank__c where Id =: questionId WITH SECURITY_ENFORCED limit 1];          
            if(questionsList != null && questionsList.size() > 0){
                goNoGoQuestionWrapper.questionName = questionsList[0].name;
                goNoGoQuestionWrapper.makeRequired = questionsList[0].Make_Required__c;
                goNoGoQuestionWrapper.questionLabel = questionsList[0].Question_Label__c;
                goNoGoQuestionWrapper.dataType = questionsList[0].Data_Type__c;
                goNoGoQuestionWrapper.questionSequence = Integer.valueOf(questionsList[0].Question_Sequence__c);
                goNoGoQuestionWrapper.maxScore = Integer.valueOf(questionsList[0].Max_Score__c);
                goNoGoQuestionWrapper.sectionId = questionsList[0].Go_No_Go_Section__c;
                goNoGoQuestionWrapper.opportuntityFieldAPIName = questionsList[0].Salesforce_Source__c;
            }
        }
        return goNoGoQuestionWrapper;
    }

    @AuraEnabled
    public static Boolean createLinkedConifg(String linkedConfigName, List<String> selectedLinkedConfig){
        Boolean isSuccess = false;
        try{
            List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id from Go_No_Go_Linked_Configuration__c WITH SECURITY_ENFORCED limit 49999];
            if(linkedConfigs != null && linkedConfigs.size() > 0){
                if(Go_No_Go_Linked_Configuration__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Linked_Configuration__c.SObjectType.getDescribe().isDeletable()) {
                    delete linkedConfigs;
                }
            }
            
            List<Go_No_Go_Linked_Configuration__c> linkedconfigList = new List<Go_No_Go_Linked_Configuration__c>();
            for(String configId : selectedLinkedConfig){
                Go_No_Go_Linked_Configuration__c linkedconfig = new Go_No_Go_Linked_Configuration__c();
                linkedconfig.Name = linkedConfigName;
                linkedconfig.Go_No_Go_Configuration__c = configId;
                linkedconfigList.add(linkedconfig);
            }
            if(Go_No_Go_Linked_Configuration__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Linked_Configuration__c.SObjectType.getDescribe().isCreateable() &&
                Schema.SObjectType.Go_No_Go_Linked_Configuration__c.fields.Go_No_Go_Configuration__c.isAccessible() && Schema.SObjectType.Go_No_Go_Linked_Configuration__c.fields.Go_No_Go_Configuration__c.isCreateable()){
                insert linkedconfigList;
                isSuccess = true;
            }
        }
        catch(Exception e){}
        return isSuccess;
    }

    @AuraEnabled
    public static LinkedConfigWrapperResult getLinkedConfigs(String submissionId, Boolean continuesubmission) {
        LinkedConfigWrapperResult linkedConfigWrapperResult = new LinkedConfigWrapperResult();
        linkedConfigWrapperResult.isCompleted = false;
        if(submissionId != null && String.isNotBlank(submissionId)){
            List<Go_No_Go_Answer__c> gonogosublist = [select id, Opportunity__c from Go_No_Go_Answer__c where id = :submissionId AND Go_No_Go_Score__c != NULL WITH SECURITY_ENFORCED limit 1];
            if(gonogosublist != null && gonogosublist.size() > 0){
                linkedConfigWrapperResult.isCompleted = true;
                return linkedConfigWrapperResult;
            }
        }
        Set<Id> completedConfigIds = new Set<Id>();
        if(continuesubmission && submissionId != null && String.isNotBlank(submissionId)){
            List<Go_No_Go_Linked_Submission__c> linkedSubmissionRecords = [select id,Name,Go_No_Go_Configuration__c,Score__c,Score_Breakdown__c,Go_No_Go_Submission__r.Go_No_Go_Score__c from Go_No_Go_Linked_Submission__c where Go_No_Go_Configuration__c != null AND Go_No_Go_Submission__c = :submissionId WITH SECURITY_ENFORCED limit 49999];
            if(linkedSubmissionRecords != null && linkedSubmissionRecords.size() > 0){
                if(linkedSubmissionRecords[0].Go_No_Go_Submission__r.Go_No_Go_Score__c != null){
                    throw new AuraHandledException('Submission already completed.'); 
                }
                for(Go_No_Go_Linked_Submission__c linkedSub : linkedSubmissionRecords){
                    completedConfigIds.add(linkedSub.Go_No_Go_Configuration__c);
                }
            }
        }
        List<LinkedConfigWrapper> linkedConfigsList = new List<LinkedConfigWrapper>();
        List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id,Name,Go_No_Go_Configuration__c,Go_No_Go_Configuration__r.Name from Go_No_Go_Linked_Configuration__c where Go_No_Go_Configuration__c != null WITH SECURITY_ENFORCED limit 49999];
        if(linkedConfigs != null && linkedConfigs.size() > 0){
            for(Go_No_Go_Linked_Configuration__c linkedConfig : linkedConfigs){
                LinkedConfigWrapper linkedConfigWrapper = new LinkedConfigWrapper();
                linkedConfigWrapper.label = linkedConfig.Go_No_Go_Configuration__r.Name;
                linkedConfigWrapper.value = linkedConfig.id;
                if(completedConfigIds.contains(linkedConfig.Go_No_Go_Configuration__c)){
                    linkedConfigWrapper.isCompleted = true;
                }
                else{
                    linkedConfigWrapper.isCompleted = false;
                }
                linkedConfigsList.add(linkedConfigWrapper);
            }
        }
        linkedConfigWrapperResult.linkedConfigWrapper = linkedConfigsList;
        return linkedConfigWrapperResult;
    }

    public static String getObjectName(ID recordId) {
        if(recordId == null){
            return '';
        }
        return recordId.getSObjectType().getDescribe().getLabel(); 
    }

    @AuraEnabled
    public static List<LinkedSubmissionWrapper> getLinkedSubmissions(String submissionId) {
        
        Set<Id> completedConfigIds = new Set<Id>();
        List<LinkedSubmissionWrapper> linkedSubmissionList = new List<LinkedSubmissionWrapper>();
        Map<Id,List<Go_No_Go_Answer_Item__c>> configToAnswerItemsMap = new Map<Id,List<Go_No_Go_Answer_Item__c>>();
        List<Go_No_Go_Answer_Item__c> answerItems = [select id, Name,  Score__c, Value__c, Go_No_Go_Question_Bank__c, Go_No_Go_Question_Bank__r.Question_Label__c, Go_No_Go_Question_Bank__r.Max_Score__c, Go_No_Go_Question_Bank__r.Go_No_Go_Section__r.Go_No_Go_Configuration__c, Go_No_Go_Question_Bank__r.Go_No_Go_Section__r.Go_No_Go_Configuration__r.Name, Go_No_Go_Answer__r.Go_No_Go_Score__c from Go_No_Go_Answer_Item__c where Go_No_Go_Answer__c = :submissionId WITH SECURITY_ENFORCED limit 49999];
        if(answerItems != null && answerItems.size() > 0){
            for(Go_No_Go_Answer_Item__c ansItem : answerItems){
                if(ansItem.Go_No_Go_Question_Bank__r.Go_No_Go_Section__r.Go_No_Go_Configuration__c != null){
                    List<Go_No_Go_Answer_Item__c> answeItemsToAdd = configToAnswerItemsMap.get(ansItem.Go_No_Go_Question_Bank__r.Go_No_Go_Section__r.Go_No_Go_Configuration__c) != null ? configToAnswerItemsMap.get(ansItem.Go_No_Go_Question_Bank__r.Go_No_Go_Section__r.Go_No_Go_Configuration__c) : new List<Go_No_Go_Answer_Item__c>();
                    answeItemsToAdd.add(ansItem);
                    configToAnswerItemsMap.put(ansItem.Go_No_Go_Question_Bank__r.Go_No_Go_Section__r.Go_No_Go_Configuration__c,answeItemsToAdd);
                }
            }
        }

        List<Go_No_Go_Linked_Submission__c> linkedSubmissionRecords = [select id,Name,Go_No_Go_Configuration__c,Go_No_Go_Configuration__r.Name,Score__c,Score_Breakdown__c,Go_No_Go_Submission__r.Go_No_Go_Score__c from Go_No_Go_Linked_Submission__c where Go_No_Go_Configuration__c != null AND Go_No_Go_Submission__c = :submissionId WITH SECURITY_ENFORCED limit 49999];
        if(linkedSubmissionRecords != null && linkedSubmissionRecords.size() > 0){
            for(Go_No_Go_Linked_Submission__c linkedSub : linkedSubmissionRecords){
                LinkedSubmissionWrapper linkedSubmissionWrapper = new LinkedSubmissionWrapper();
                linkedSubmissionWrapper.configName = linkedSub.Go_No_Go_Configuration__r.Name;
                linkedSubmissionWrapper.configId = linkedSub.Go_No_Go_Configuration__c;
                linkedSubmissionWrapper.score = linkedSub.Score__c != null ? String.valueOf(Integer.valueOf(linkedSub.Score__c)) + '%' : null;
                List<Go_No_Go_Answer_Item__c> answerItemsToAddQ = configToAnswerItemsMap.get(linkedSub.Go_No_Go_Configuration__c);
                if(answerItemsToAddQ != null && answerItemsToAddQ.size() > 0){
                    List<LinkedQuestionWrapper> questionRecords = new List<LinkedQuestionWrapper>();
                    for(Go_No_Go_Answer_Item__c ansItem : answerItemsToAddQ){
                        LinkedQuestionWrapper linkedQuestionWrapper = new LinkedQuestionWrapper();
                        linkedQuestionWrapper.questionId = ansItem.Go_No_Go_Question_Bank__c;
                        linkedQuestionWrapper.questionName = ansItem.Name;
                        linkedQuestionWrapper.questionLabel = ansItem.Go_No_Go_Question_Bank__r.Question_Label__c;
                        linkedQuestionWrapper.value = ansItem.Value__c;
                        linkedQuestionWrapper.score = ansItem.Score__c != null ? String.valueOf(Integer.valueOf(ansItem.Score__c)) : null;
                        linkedQuestionWrapper.maxScore = ansItem.Go_No_Go_Question_Bank__r.Max_Score__c != null ? String.valueOf(Integer.valueOf(ansItem.Go_No_Go_Question_Bank__r.Max_Score__c)) : null;
                        questionRecords.add(linkedQuestionWrapper);
                        linkedSubmissionWrapper.questionRecords = questionRecords;
                    }
                }
                linkedSubmissionList.add(linkedSubmissionWrapper);
                completedConfigIds.add(linkedSub.Go_No_Go_Configuration__c);
            }
            List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id,Name,Go_No_Go_Configuration__c,Go_No_Go_Configuration__r.Name from Go_No_Go_Linked_Configuration__c where Go_No_Go_Configuration__c != null WITH SECURITY_ENFORCED limit 49999];
            if(linkedConfigs != null && linkedConfigs.size() > 0){
                for(Go_No_Go_Linked_Configuration__c linkedConfig : linkedConfigs){
                    if(!completedConfigIds.contains(linkedConfig.Go_No_Go_Configuration__c)){
                        LinkedSubmissionWrapper linkedSubmissionWrapper = new LinkedSubmissionWrapper();
                        linkedSubmissionWrapper.configName = linkedConfig.Go_No_Go_Configuration__r.Name;
                        linkedSubmissionWrapper.configId = linkedConfig.Go_No_Go_Configuration__c;
                        linkedSubmissionWrapper.score = 'Pending';
                        linkedSubmissionWrapper.hideTable = true;
                        linkedSubmissionList.add(linkedSubmissionWrapper);
                    }
                }
            }
        }
        else {
            for(Id configId : configToAnswerItemsMap.keySet()){
                List<Go_No_Go_Answer_Item__c> answerItemsToAddQ = configToAnswerItemsMap.get(configId);
                if(answerItemsToAddQ != null && answerItemsToAddQ.size() > 0){
                    LinkedSubmissionWrapper linkedSubmissionWrapper = new LinkedSubmissionWrapper();
                    linkedSubmissionWrapper.configName = answerItemsToAddQ[0].Go_No_Go_Question_Bank__r.Go_No_Go_Section__r.Go_No_Go_Configuration__r.Name;
                    linkedSubmissionWrapper.configId = answerItemsToAddQ[0].Go_No_Go_Question_Bank__r.Go_No_Go_Section__r.Go_No_Go_Configuration__c;
                    linkedSubmissionWrapper.score = answerItemsToAddQ[0].Go_No_Go_Answer__r.Go_No_Go_Score__c != null ? String.valueOf(Integer.valueOf(answerItemsToAddQ[0].Go_No_Go_Answer__r.Go_No_Go_Score__c)) + '%' : null;
                    List<LinkedQuestionWrapper> questionRecords = new List<LinkedQuestionWrapper>();
                    for(Go_No_Go_Answer_Item__c ansItem : answerItemsToAddQ){
                        LinkedQuestionWrapper linkedQuestionWrapper = new LinkedQuestionWrapper();
                        linkedQuestionWrapper.questionId = ansItem.Go_No_Go_Question_Bank__c;
                        linkedQuestionWrapper.questionName = ansItem.Name;
                        linkedQuestionWrapper.questionLabel = ansItem.Go_No_Go_Question_Bank__r.Question_Label__c;
                        linkedQuestionWrapper.value = ansItem.Value__c;
                        linkedQuestionWrapper.score = ansItem.Score__c != null ? String.valueOf(Integer.valueOf(ansItem.Score__c)) : null;
                        linkedQuestionWrapper.maxScore = ansItem.Go_No_Go_Question_Bank__r.Max_Score__c != null ? String.valueOf(Integer.valueOf(ansItem.Go_No_Go_Question_Bank__r.Max_Score__c)) : null;
                        questionRecords.add(linkedQuestionWrapper);
                        linkedSubmissionWrapper.questionRecords = questionRecords;
                    }
                    linkedSubmissionList.add(linkedSubmissionWrapper);
                }
                break;
            }
        }
        
        return linkedSubmissionList;
    }

    @AuraEnabled
    public static ResultWrapper updateAsigneeNotification(Boolean asigneeNotificationlNew, String selectedOppStatus, Boolean reminderNotificationlNew, Integer reminderNotificationDaysNew) {
        ResultWrapper resultWrapper = new ResultWrapper();
        resultWrapper.isSuccess = false;
        resultWrapper.errorMsg = 'Something went wrong. Please try again later.';
        try{
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
            gonogosetting.Assignee_Notification__c = asigneeNotificationlNew;
            gonogosetting.Opportunity_Stage_For_Notification__c = selectedOppStatus;
            gonogosetting.Reminder_Notification__c = reminderNotificationlNew;
            gonogosetting.Days_For_Reminder_Notification__c = reminderNotificationDaysNew;
            Database.upsert(gonogosetting);
            resultWrapper.isSuccess = true;
            try{
                if(asigneeNotificationlNew && reminderNotificationlNew){
                    createReminderJob();
                }
                else{
                    deleteReminderJob();
                }
            }
            catch(Exception e){}
        }
        catch(Exception e){}
        return resultWrapper;
    }

    public static void createReminderJob() {
        System.schedule('AutoSetup GoNoGoReminderNotificationJob','0 0 8 ? * 1,2,3,4,5,6,7', new GoNoGoReminderNotificationJob());
    }

    public static void deleteReminderJob() {
        List<CronTrigger> jobList = [SELECT id from CronTrigger where CronJobDetail.name ='AutoSetup GoNoGoReminderNotificationJob' limit 1];
        if(jobList != null && jobList.size() > 0){
            System.abortJob(jobList[0].Id);
        }
    }

    public static void sendEmailToOppOwnerForCompletion(String oppId, String submissionId) {
        String emailTemplateName = 'Go/No Go Submission Completed Notification';
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE name =:emailTemplateName];
        
        Opportunity oppRec = [select id, OwnerId from Opportunity where Id = :oppId limit 1];
        if(oppRec != null){
            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setTargetObjectId(oppRec.OwnerId);
            mail.setTemplateId(et.id); 
            mail.setWhatId(submissionId); 
            mail.setBccSender(false); 
            mail.setUseSignature(false); 
            mail.setSaveAsActivity(false);
            emailMessageList.add(mail);
    
            if(emailMessageList.size() > 0){
                Messaging.sendEmail(emailMessageList);
            }
        }
    }

    @AuraEnabled
    public static Boolean requestGoNoGoSubmission(String opportunityId) {
        Boolean isSuccess = false;
        try{
            if(opportunityId != null && String.isNotBlank(opportunityId)){
                if(Go_No_Go_Answer__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Answer__c.SObjectType.getDescribe().isCreateable() &&
                    Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isAccessible() && Schema.SObjectType.Go_No_Go_Answer__c.fields.Opportunity__c.isCreateable()){
                        Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
                        answer.Opportunity__c = opportunityId;
                        answer.Status_Label__c = 'Pending';
                        insert answer;

                        currentOpportunityId = opportunityId;
                        answerId = answer.Id;

                        Map<Id,Id> configIdsToOwnerMap = new Map<Id,Id>();
                        GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
                        String defaultConfigName;
                        if(gonogosetting != null){
                            defaultConfigName = gonogosetting.Default_Configuration_Name__c;
                        }
                        List<Go_No_Go_Linked_Configuration__c> linkedConfigs = [select id, Go_No_Go_Configuration__c, Go_No_Go_Configuration__r.OwnerId from Go_No_Go_Linked_Configuration__c WITH SECURITY_ENFORCED];
                        if(linkedConfigs != null && linkedConfigs.size() > 0){
                            for(Go_No_Go_Linked_Configuration__c lc : linkedConfigs){
                                configIdsToOwnerMap.put(lc.Go_No_Go_Configuration__c, lc.Go_No_Go_Configuration__r.OwnerId);
                            }
                        }
                        else if(defaultConfigName != null && String.isNotBlank(defaultConfigName)){
                            Go_No_Go_Configuration__c configRec = [select id, ownerId from Go_No_Go_Configuration__c WHERE Name = :defaultConfigName WITH SECURITY_ENFORCED order by createddate asc limit 1];
                            if(configRec != null){
                                configIdsToOwnerMap.put(configRec.Id, configRec.ownerId);
                            }
                        }
                        
                        if(configIdsToOwnerMap.size() > 0){
                            String emailTemplateName = 'Go/No Go Submission Notification Email Template';
                            EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE name =:emailTemplateName];
                            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                            for(Id configId : configIdsToOwnerMap.keySet()){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                                mail.setTargetObjectId(configIdsToOwnerMap.get(configId));
                                mail.setTemplateId(et.id); 
                                mail.setWhatId(configId); 
                                mail.setBccSender(false); 
                                mail.setUseSignature(false); 
                                mail.setSaveAsActivity(false);
                                emailMessageList.add(mail);                       
                            }
                            if(emailMessageList.size() > 0){
                                Messaging.sendEmail(emailMessageList);
                            }
                        }
                        isSuccess = true;
                    }
            }
        }
        catch(Exception e){}
        return isSuccess;
    }

    @AuraEnabled
    public static List<PickListWrapper> getRecordTypesForLFS(){
        List<PickListWrapper> recordTypesWrapperList = new List<PickListWrapper>();
        List<Recordtype> recordTypes = [select id, name from Recordtype where SobjectType = 'avnio__Project__c' and IsActive = true];
        if(recordTypes != null && recordTypes.size() > 0){
            for(Recordtype rt : recordTypes){
                PickListWrapper recordT = new PickListWrapper();
                recordT.label = rt.name;
                recordT.value = rt.id;
                recordTypesWrapperList.add(recordT);
            }
        }
        return recordTypesWrapperList;
    }

    public class GoNoGoQuestionWrapper {
        @AuraEnabled public List<PickListWrapper> dataTypesOptions;
        @AuraEnabled public List<PickListWrapper> opportunityFields;
        @AuraEnabled public String questionName;
        @AuraEnabled public Boolean makeRequired;
        @AuraEnabled public String questionLabel;
        @AuraEnabled public String dataType;
        @AuraEnabled public Integer questionSequence;
        @AuraEnabled public Integer maxScore;
        @AuraEnabled public String sectionId;
        @AuraEnabled public String opportuntityFieldAPIName;
    }

    public class GoNoGoSettingsWrapper {
        @AuraEnabled public String defaultConfigName;
        @AuraEnabled public Integer thresholdvalue;
        @AuraEnabled public Boolean hasadminaccess;
        @AuraEnabled public String manageCustomSettingUrl;
        @AuraEnabled public Boolean autoSubmitForApproval;
        @AuraEnabled public Boolean approvalProcessPresent;
        @AuraEnabled public List<GoNoGoStatusWrapper> goNoGoStatusWrapperList;
        @AuraEnabled public List<PickListWrapper> availableConfigurationsList;
        @AuraEnabled public List<PickListWrapper> linkedConfigList;
        @AuraEnabled public String linkedConfigName;
        @AuraEnabled public Boolean asigneeNotification;
        @AuraEnabled public List<PickListWrapper> opportunityStatuses;
        @AuraEnabled public String selectedOppStatus;
        @AuraEnabled public Boolean reminderNotification;
        @AuraEnabled public String reminderNotificationDays;
    }

    public class PickListWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class GoNoGoStatusWrapper {
        @AuraEnabled public String statusid;
        @AuraEnabled public String label;
        @AuraEnabled public Integer minrange;
        @AuraEnabled public Integer maxrange;
        @AuraEnabled public String staticresourcename;
    }

    public class SectionWrapper {
        @AuraEnabled public String sectionId;
        @AuraEnabled public String sectionName;
        @AuraEnabled public Integer sectionSequence;
        @AuraEnabled public List<QuestionWrapper> questionRecords;
    }

    public class LinkedConfigWrapperResult {
        @AuraEnabled public List<LinkedConfigWrapper> linkedConfigWrapper;
        @AuraEnabled public Boolean isCompleted;
    }

    public class LinkedConfigWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isCompleted;
    }

    public class QuestionWrapper {
        @AuraEnabled public String questionId;
        @AuraEnabled public String questionLabel;
        @AuraEnabled public Integer questionSequence;
        @AuraEnabled public String dataType;
        @AuraEnabled public String sectionId;
        @AuraEnabled public String answerValue;
        @AuraEnabled public Integer maxScore;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public List<ScoringWrapper> scoringRecords;
    }

    public class ScoringWrapper {
        @AuraEnabled public String scoringId;
        @AuraEnabled public String value;
        @AuraEnabled public Integer score;
    }

    public class ResultWrapper {
        @AuraEnabled public String gonogoanswerid;
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public Integer gonogoscore;
        @AuraEnabled public String staticresourcename;
        @AuraEnabled public String statuslabel;
        @AuraEnabled public Boolean approvalProcessPresent;
        @AuraEnabled public String errorMsg;
        @AuraEnabled public Boolean isApproved;
        @AuraEnabled public String opportunityId;
        @AuraEnabled public Boolean isLoopioPresent;
        @AuraEnabled public Boolean isAvnioPresent;
        @AuraEnabled public List<GoNoGoStatusWrapper> goNoGoStatusWrapperList;
        @AuraEnabled public Integer linkedConfigsCount;
        @AuraEnabled public Integer linkedConfigsDoneCount;
        @AuraEnabled public Integer lastConfigScore;
        @AuraEnabled public String lastConfigStatusLabel;
        @AuraEnabled public String lastConfigStaticresourcename;
        @AuraEnabled public String accountId;
        @AuraEnabled public List<PickListWrapper> recordTypesForLFS;
    }

    public class LinkedSubmissionWrapper {
        @AuraEnabled public String configId;
        @AuraEnabled public String configName;
        @AuraEnabled public String score;
        @AuraEnabled public Boolean hideTable;
        @AuraEnabled public List<LinkedQuestionWrapper> questionRecords;
    }

    public class LinkedQuestionWrapper {
        @AuraEnabled public String questionId;
        @AuraEnabled public String questionName;
        @AuraEnabled public String questionLabel;
        @AuraEnabled public String value;
        @AuraEnabled public String score;
        @AuraEnabled public String maxScore;
    }
}