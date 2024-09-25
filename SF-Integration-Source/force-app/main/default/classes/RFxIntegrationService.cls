@RestResource(urlMapping='/RFxIntegrationService/*')
global without sharing class RFxIntegrationService {

    @HttpGet
    global static Map<String, String> getData(){

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestURI = req.requestURI;
        String fromDateStr = requestURI.substring(requestURI.lastIndexOf('/')+1);
        requestURI = requestURI.substring(0,requestURI.lastIndexOf('/'));
        String objectAPIName = requestURI.substring(requestURI.lastIndexOf('/')+1);
        System.debug('fromDateStr'+fromDateStr);
        System.debug('objectAPIName'+objectAPIName);
        String whereClause = '';
        if(fromDateStr != null && String.isNotBlank(fromDateStr)){
            Date fromDate = Date.valueOf(fromDateStr);
            whereClause = ' WHERE LastModifiedDate >= :fromDate';
        }

        Map<String, String> returnMap = new Map<String, String>();
        Set<String> statusToInclude = new Set<String> ();
        statusToInclude.add('Published');
        statusToInclude.add('Archived');

        switch on objectAPIName {
            when 'avnio__category__c' {
                String categoryQuery = 'select id, name from avnio__Category__c ' + whereClause + ' LIMIT 10000';
                List<avnio__Category__c> categories = Database.query(categoryQuery);
                if(categories != null && categories.size() > 0){
                    returnMap.put('avnio__category__c',JSON.serialize(categories));
                }
            }
            when 'avnio__tag__c' {
                String tagQuery = 'select id, name from avnio__Tag__c ' + whereClause + ' LIMIT 10000';
                List<avnio__Tag__c> tags = Database.query(tagQuery);
                if(tags != null && tags.size() > 0){
                    returnMap.put('avnio__tag__c',JSON.serialize(tags));
                }
            }
            when 'avnio__response__c' {
                String responseQuery = 'select id, Alert_Text__c, avnio__Answer__c,avnio__Status__c, Last_Edited_Date__c, avnio__IsAutoSubmitForReviewCycle__c, avnio__HelpText__c, PS_Section_Name__c, avnio__PrimaryQuestion__c, Cloud_Formula__c, Cloud__c, avnio__Source__c, Tags__c, OwnerID, GSX_Integrated_Response__c from avnio__Response__c ' + whereClause + ' AND GSX_Integrated_Response__c = true AND avnio__Status__c IN :statusToInclude'+ ' LIMIT 10000';
                List<avnio__Response__c> responses = Database.query(responseQuery);
                if(responses != null && responses.size() > 0){
                    returnMap.put('avnio__response__c',JSON.serialize(responses));
                }
            }
            when 'avnio__responsequestion__c' {
                String responseQuestionQuery = 'select id, avnio__InitialDraft__c, avnio__IsDeleted__c, avnio__Question__c, avnio__ResponseId__c, avnio__Source__c from avnio__ResponseQuestion__c ' + whereClause + ' AND avnio__ResponseId__r.GSX_Integrated_Response__c = true AND avnio__ResponseId__r.avnio__Status__c IN :statusToInclude ' + ' LIMIT 10000';
                List<avnio__ResponseQuestion__c> responseQuestions = Database.query(responseQuestionQuery);
                if(responseQuestions != null && responseQuestions.size() > 0){
                    returnMap.put('avnio__responsequestion__c',JSON.serialize(responseQuestions));
                }
            }
            when 'avnio__alternativeanswer__c' {
                String alternativeAnswerQuery = 'select id, avnio__Answer__c, avnio__IsDeleted__c, avnio__ResponseId__c, avnio__Title__c from avnio__AlternativeAnswer__c ' + whereClause + ' AND avnio__ResponseId__r.GSX_Integrated_Response__c = true AND avnio__ResponseId__r.avnio__Status__c IN :statusToInclude ' + ' LIMIT 10000';
                List<avnio__AlternativeAnswer__c> alternativeAnswers = Database.query(alternativeAnswerQuery);
                if(alternativeAnswers != null && alternativeAnswers.size() > 0){
                    returnMap.put('avnio__alternativeanswer__c',JSON.serialize(alternativeAnswers));
                }
            }
            when 'avnio__responsecategory__c' {
                String responseCategoryQuery = 'select id, avnio__ResponseId__c, avnio__CategoryId__c from avnio__ResponseCategory__c ' + whereClause + ' AND avnio__ResponseId__r.GSX_Integrated_Response__c = true AND avnio__ResponseId__r.avnio__Status__c IN :statusToInclude' + ' LIMIT 10000';
                List<avnio__ResponseCategory__c> responseCategories = Database.query(responseCategoryQuery);
                if(responseCategories != null && responseCategories.size() > 0){
                    returnMap.put('avnio__responsecategory__c',JSON.serialize(responseCategories));
                    Set<Id> categoryIds = new Set<Id>();
                    for(avnio__ResponseCategory__c resCat : responseCategories){
                        if(resCat.avnio__CategoryId__c != null){
                            categoryIds.add(resCat.avnio__CategoryId__c);
                        }
                    }
                    if(categoryIds.size() > 0){
                        String categoryQuery = 'select id, name from avnio__Category__c ' + whereClause + ' AND Id IN :categoryIds LIMIT 10000';
                        List<avnio__Category__c> categories = Database.query(categoryQuery);
                        if(categories != null && categories.size() > 0){
                            returnMap.put('avnio__category__c',JSON.serialize(categories));
                        }
                    }
                }
            }
            when 'avnio__responsetag__c' {
                String responseTagQuery = 'select id, avnio__ResponseId__c, avnio__TagId__c from avnio__ResponseTag__c ' + whereClause + ' AND avnio__ResponseId__r.GSX_Integrated_Response__c = true AND avnio__ResponseId__r.avnio__Status__c IN :statusToInclude' + ' LIMIT 10000';
                List<avnio__ResponseTag__c> responseTags = Database.query(responseTagQuery);
                if(responseTags != null && responseTags.size() > 0){
                    returnMap.put('avnio__responsetag__c',JSON.serialize(responseTags));
                    Set<Id> tagIds = new Set<Id>();
                    for(avnio__ResponseTag__c resTag : responseTags){
                        if(resTag.avnio__TagId__c != null){
                            tagIds.add(resTag.avnio__TagId__c);
                        }
                    }
                    if(tagIds.size() > 0){
                        String tagQuery = 'select id, name from avnio__Tag__c ' + whereClause + ' AND Id IN :tagIds LIMIT 10000';
                        List<avnio__Tag__c> tags = Database.query(tagQuery);
                        if(tags != null && tags.size() > 0){
                            returnMap.put('avnio__tag__c',JSON.serialize(tags));
                        }
                    }
                }
            }
            when 'deletedRecords' {
                String deletedRecordsQuery = 'select id, Record_ID__c, Object_API_Name__c from RFX_Integration_Data_Delete_Log__c ' + whereClause + ' LIMIT 10000';
                List<RFX_Integration_Data_Delete_Log__c> deletedRecords = Database.query(deletedRecordsQuery);
                if(deletedRecords != null && deletedRecords.size() > 0){
                    returnMap.put('deletedRecords',JSON.serialize(deletedRecords));
                }
            }
        }

        return returnMap;
    }
}