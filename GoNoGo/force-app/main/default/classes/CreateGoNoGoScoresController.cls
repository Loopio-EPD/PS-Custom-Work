/*

*@description: This is controller class for creating, updating and deleting Go No Go Scores.

*/
public with sharing class CreateGoNoGoScoresController {
    
    /*

    @description: This method is used to fetch existing scores

    @param dateInput: Pass current question Id

    @return wrapper response which contains list of scores

    */
    @AuraEnabled
    public static ScoringWrapper getExistingScoresForQuestion(String questionId){
        ScoringWrapper scoringWrapper = new ScoringWrapper();
        scoringWrapper.dataType = 'Text';
        List<Go_No_Go_Question_Bank_Scoring__c> scoringList = new List<Go_No_Go_Question_Bank_Scoring__c>();
        try {
            Go_No_Go_Question_Bank__c questionRec = [select id,Data_Type__c from Go_No_Go_Question_Bank__c where id = :questionId WITH SECURITY_ENFORCED ORDER BY createddate asc LIMIT 1];
            if(questionRec != null){
                scoringWrapper.dataType = questionRec.Data_Type__c;
            }
            scoringList = [select Id, Value__c, Score__c from Go_No_Go_Question_Bank_Scoring__c where Go_No_Go_Question_Bank__c = :questionId WITH SECURITY_ENFORCED ORDER BY Score__c asc LIMIT 49999];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        scoringWrapper.scoringList = scoringList;
        return scoringWrapper;
    }

    /*

    @description: This method is used to save scoring scores

    @param dateInput: Pass json foramtted data of scoring and current question Id

    @return if scoring records saved successfully or not

    */
    @AuraEnabled
    public static ResultWrapper saveScoringRecords(String jsonString, String questionId){
        ResultWrapper resultWrapper = new ResultWrapper();
        resultWrapper.isSuccess = true;
        resultWrapper.errorMsg = 'Something went wrong. Please try again later.';
        try{
            List<ScoringRequest> scoringRequestList = new List<ScoringRequest>();
            scoringRequestList = (List<ScoringRequest>) JSON.deserialize((String)jsonString, List<ScoringRequest>.class);
            if(scoringRequestList != null && scoringRequestList.size() > 0){
                List<Go_No_Go_Question_Bank_Scoring__c> scoringRecordsListToInsert = new List<Go_No_Go_Question_Bank_Scoring__c>();
                List<Go_No_Go_Question_Bank_Scoring__c> scoringRecordsListToUpdate = new List<Go_No_Go_Question_Bank_Scoring__c>();
                for(ScoringRequest singleReq : scoringRequestList){
                    Go_No_Go_Question_Bank_Scoring__c scoreRec = new Go_No_Go_Question_Bank_Scoring__c();
                    scoreRec.Score__c = singleReq.score;
                    if(singleReq.scoreId != null){
                        scoreRec.Id = singleReq.scoreId;
                    }
                    if(singleReq.value != null){
                        scoreRec.Value__c = singleReq.value;
                    }
                    if(singleReq.scoreId != null){
                        scoringRecordsListToUpdate.add(scoreRec);
                    }
                    else{
                        scoreRec.Go_No_Go_Question_Bank__c = questionId;
                        scoringRecordsListToInsert.add(scoreRec);
                    }
                }
                if(scoringRecordsListToInsert.size() > 0){
                    if(Go_No_Go_Question_Bank_Scoring__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Question_Bank_Scoring__c.SObjectType.getDescribe().isCreateable() && Go_No_Go_Question_Bank_Scoring__c.SObjectType.getDescribe().isUpdateable() &&
                    Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Go_No_Go_Question_Bank__c.isAccessible() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Go_No_Go_Question_Bank__c.isCreateable() &&
                    Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Value__c.isAccessible() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Value__c.isCreateable() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Value__c.isUpdateable() &&
                    Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Score__c.isAccessible() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Score__c.isCreateable() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Score__c.isUpdateable()) {
                        insert scoringRecordsListToInsert;
                    }
                    else{
                        resultWrapper.isSuccess = false;
                    }
                }
                if(scoringRecordsListToUpdate.size() > 0){
                    if(Go_No_Go_Question_Bank_Scoring__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Question_Bank_Scoring__c.SObjectType.getDescribe().isCreateable() && Go_No_Go_Question_Bank_Scoring__c.SObjectType.getDescribe().isUpdateable() &&
                    Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Go_No_Go_Question_Bank__c.isAccessible() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Go_No_Go_Question_Bank__c.isCreateable() &&
                    Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Value__c.isAccessible() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Value__c.isCreateable() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Value__c.isUpdateable() &&
                    Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Score__c.isAccessible() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Score__c.isCreateable() && Schema.SObjectType.Go_No_Go_Question_Bank_Scoring__c.fields.Score__c.isUpdateable()) {
                        update scoringRecordsListToUpdate;
                    }
                    else{
                        resultWrapper.isSuccess = false;
                    }
                }
                
            }
        }
        catch(Exception e){
            resultWrapper.errorMsg = e.getMessage();
            resultWrapper.isSuccess = false;
        }
        return resultWrapper;
    }

    /*

    @description: This method is used to delete scoring scores

    @param dateInput: Pass score Id

    @return if scoring record deleted successfully or not

    */
    @AuraEnabled
    public static Boolean deleteScoreRecord(String scoreRecordId){
        Boolean isSuccess = true;
        try{
            if(scoreRecordId != null && String.isNotBlank(scoreRecordId)){
                Go_No_Go_Question_Bank_Scoring__c scoreRec = new Go_No_Go_Question_Bank_Scoring__c();
                scoreRec.Id = scoreRecordId;
                if(Go_No_Go_Question_Bank_Scoring__c.SObjectType.getDescribe().isAccessible() && Go_No_Go_Question_Bank_Scoring__c.SObjectType.getDescribe().isDeletable()) {
                    delete scoreRec;
                }
                else{
                    isSuccess = false;
                }
            }
        }
        catch(Exception e){
            isSuccess = false;
        }
        return isSuccess;
    }

    public with sharing class ScoringWrapper{
        @AuraEnabled public String dataType;
        @AuraEnabled public List<Go_No_Go_Question_Bank_Scoring__c> scoringList;
    }

    public with sharing class ScoringRequest{
        @AuraEnabled public String scoreId;
        @AuraEnabled public String value;
        @AuraEnabled public Integer score;
    }

    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMsg;
    }
}