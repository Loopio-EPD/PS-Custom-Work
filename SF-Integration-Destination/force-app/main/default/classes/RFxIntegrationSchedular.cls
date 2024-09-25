public without sharing class RFxIntegrationSchedular implements Schedulable,Database.AllowsCallouts {
    
    public static Boolean actionFromSchedular = false;

    public void execute(SchedulableContext sc) {
        Set<String> objectAPINames = new Set<String>{'avnio__response__c'};
        String yesterdayDate = String.valueOf(System.today());
        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
        batchRecord.Batch_Start_Date__c = System.today();
        Database.insert(batchRecord);
        System.enqueueJob(new SaveDataQueue(objectAPINames,batchRecord.Id,yesterdayDate,null));
    }

    public class SaveDataQueue implements Queueable, Database.AllowsCallouts {
        public Set<String> objectAPINames;
        public Id batchId;
        public String yesterdayDate;
        public List<Id> responseIdForPublish;
        
        public SaveDataQueue(Set<String> objectAPINames, Id batchId, String yesterdayDate, List<Id> responseIdForPublish) {
            this.objectAPINames = objectAPINames;
            this.batchId = batchId;
            this.yesterdayDate = yesterdayDate;
            this.responseIdForPublish = responseIdForPublish;
        }
    
        public void execute(QueueableContext context) {
            try{
                if(objectAPINames != null && objectAPINames.size() > 0){
                 actionFromSchedular = true;
                    for(String objectName : objectAPINames){
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setMethod('GET');
                        request.setEndpoint('callout:RFx_Integration/services/apexrest/RFxIntegrationService/getData/' + objectName + '/' + yesterdayDate);        
                        HTTPResponse response = http.send(request);
                        String responseData = response.getBody();
                        if((response.getStatusCode() == 201 || response.getStatusCode() == 200) && responseData != null && String.isNotBlank(responseData)){
                            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(responseData);
                            if(jsonMap != null && jsonMap.size() > 0 && jsonMap.get(objectName) != null){
                               
                                Object objData = jsonMap.get(objectName);
                                switch on objectName {
                                    when 'avnio__category__c' {
                                        try{
                                            List<avnio__category__c> recordsData = (List<avnio__category__c>)JSON.deserialize((String) objData, List<avnio__category__c>.class);
                                            processCategoriesData(recordsData,batchId);
                                        }
                                        catch(Exception e){}
                                    }
                                    when 'avnio__tag__c' {
                                        try{
                                            List<avnio__tag__c> recordsData = (List<avnio__tag__c>)JSON.deserialize((String) objData, List<avnio__tag__c>.class);
                                            processTagsData(recordsData,batchId);
                                        }
                                        catch(Exception e){}
                                    }
                                    when 'avnio__response__c' {
                                        try{
                                            List<avnio__response__c> recordsData = (List<avnio__response__c>)JSON.deserialize((String) objData, List<avnio__response__c>.class);
                                            processResponsesData(recordsData,batchId);
                                        }
                                        catch(Exception e){}
                                    }
                                    when 'avnio__responsequestion__c' {
                                        try{
                                            List<avnio__responsequestion__c> recordsData = (List<avnio__responsequestion__c>)JSON.deserialize((String) objData, List<avnio__responsequestion__c>.class);
                                            processResponseQuestionsData(recordsData,batchId);
                                        }
                                        catch(Exception e){}
                                    }
                                    when 'avnio__alternativeanswer__c' {
                                        try{
                                            List<avnio__alternativeanswer__c> recordsData = (List<avnio__alternativeanswer__c>)JSON.deserialize((String) objData, List<avnio__alternativeanswer__c>.class);
                                            processAlternativeAnswersData(recordsData,batchId);
                                        }
                                        catch(Exception e){}
                                    }
                                    when 'avnio__responsecategory__c' {
                                        try{
                                            List<avnio__category__c> recordsData1 = (List<avnio__category__c>)JSON.deserialize((String) jsonMap.get('avnio__category__c'), List<avnio__category__c>.class);
                                            processCategoriesData(recordsData1,batchId);
                                            
                                            List<avnio__responsecategory__c> recordsData = (List<avnio__responsecategory__c>)JSON.deserialize((String) objData, List<avnio__responsecategory__c>.class);
                                            processResponseCategoriesData(recordsData,batchId);
                                        }
                                        catch(Exception e){}
                                    }
                                    when 'avnio__responsetag__c' {
                                        try{
                                            List<avnio__tag__c> recordsData1 = (List<avnio__tag__c>)JSON.deserialize((String) jsonMap.get('avnio__tag__c'), List<avnio__tag__c>.class);
                                            processTagsData(recordsData1,batchId);
                                            
                                            List<avnio__responsetag__c> recordsData = (List<avnio__responsetag__c>)JSON.deserialize((String) objData, List<avnio__responsetag__c>.class);
                                            processResponseTagsData(recordsData,batchId);
                                        }
                                        catch(Exception e){}
                                    }
                                    when 'deletedRecords' {
                                        try{
                                            List<Object> recordsData = (List<Object>) JSON.deserializeUntyped(String.valueOf(objData));
                                            processDeletedRecordsData(recordsData,batchId);
                                        }
                                        catch(Exception e){}
                                    }  
                                }
                            }
                            else if(objectName.equalsIgnoreCase('avnio__response__c')){
                                objectAPINames.addAll(new Set<String>{'avnio__responsequestion__c','avnio__alternativeanswer__c','avnio__responsecategory__c','avnio__responsetag__c','deletedRecords'});
                            }
                        }
                        objectAPINames.remove(objectName);
                        break;
                    }
                    if(objectAPINames.size() > 0){
                        System.enqueueJob(new SaveDataQueue(objectAPINames,batchId,yesterdayDate,responseIdForPublish));
                    }
                    else{
                        if(responseIdForPublish != null && responseIdForPublish.size() > 0){
                            RestRequest req = new RestRequest();
                            RestResponse resContx = new RestResponse();
                            req.requestURI = '/services/apexrest/avnio/Response';
                            req.httpMethod = 'PUT';
                            req.addHeader('Content-Type','application/json');
                            RestContext.request = req;
                            RestContext.response = resContx;
Boolean resPonseForPublish = avnio.ResponseService.publishResponse(responseIdForPublish);
                        }
                        RFX_Integration_Batch__c batchRecord = new RFX_Integration_Batch__c();
                        batchRecord.Id = batchId;
                        batchRecord.Batch_End_Date__c = System.today();
                        Database.update(batchRecord);
                    }
                }
            }catch(Exception e){}
        }

        public void processCategoriesData(List<avnio__category__c> recordsData, Id batchId){
            Set<Id> recordIds = new Set<Id>();
            for(avnio__category__c record : recordsData){
                recordIds.add(record.Id);
            }

            List<avnio__category__c> existingRecords = [select id, External_ID__c from avnio__category__c where External_ID__c IN :recordIds limit 49999];
            Map<String,String> externalIdToRecordIdMap = new Map<String,String>();
            if(existingRecords != null && existingRecords.size() > 0){
                for(avnio__category__c rec : existingRecords){
                    externalIdToRecordIdMap.put(rec.External_ID__c, rec.Id);
                }
            }

            List<avnio__category__c> recordsToUpsert = new List<avnio__category__c>();
            List<RFX_Integration_Log__c> logRecords = new List<RFX_Integration_Log__c>();
            for(avnio__category__c record : recordsData){
                avnio__category__c newRecord = new avnio__category__c();
                if(externalIdToRecordIdMap.get(String.valueOf(record.Id)) != null){
                    newRecord.Id = externalIdToRecordIdMap.get(String.valueOf(record.Id));
                }
                newRecord.name = record.Name;
                newRecord.External_ID__c = String.valueOf(record.Id);
                recordsToUpsert.add(newRecord);
            }
            Database.upsert(recordsToUpsert,false);

            for(avnio__category__c rec : recordsToUpsert){
                if(rec.Id != null){
                    RFX_Integration_Log__c logRecord = new RFX_Integration_Log__c();
                    logRecord.RFX_Integration_Batch__c = batchId;
                    logRecord.Category__c = rec.Id;
                    logRecord.Event__c = 'Create';
                    if(externalIdToRecordIdMap.get(String.valueOf(rec.External_ID__c)) != null){
                        logRecord.Event__c = 'Update';
                    }
                    logRecords.add(logRecord);
                }
            }
            Database.insert(logRecords,false);
        }

        public void processTagsData(List<avnio__tag__c> recordsData, Id batchId){
            Set<Id> recordIds = new Set<Id>();
            for(avnio__tag__c record : recordsData){
                recordIds.add(record.Id);
            }

            List<avnio__tag__c> existingRecords = [select id, External_ID__c from avnio__tag__c where External_ID__c IN :recordIds limit 49999];
            Map<String,String> externalIdToRecordIdMap = new Map<String,String>();
            if(existingRecords != null && existingRecords.size() > 0){
                for(avnio__tag__c rec : existingRecords){
                    externalIdToRecordIdMap.put(rec.External_ID__c, rec.Id);
                }
            }

            List<avnio__tag__c> recordsToUpsert = new List<avnio__tag__c>();
            List<RFX_Integration_Log__c> logRecords = new List<RFX_Integration_Log__c>();
            for(avnio__tag__c record : recordsData){
                avnio__tag__c newRecord = new avnio__tag__c();
                if(externalIdToRecordIdMap.get(String.valueOf(record.Id)) != null){
                    newRecord.Id = externalIdToRecordIdMap.get(String.valueOf(record.Id));
                }
                newRecord.name = record.Name;
                newRecord.External_ID__c = String.valueOf(record.Id);
                recordsToUpsert.add(newRecord);
            }
            Database.upsert(recordsToUpsert,false);

            for(avnio__tag__c rec : recordsToUpsert){
                if(rec.Id != null){
                    RFX_Integration_Log__c logRecord = new RFX_Integration_Log__c();
                    logRecord.RFX_Integration_Batch__c = batchId;
                    logRecord.Category__c = rec.Id;
                    logRecord.Event__c = 'Create';
                    if(externalIdToRecordIdMap.get(String.valueOf(rec.External_ID__c)) != null){
                        logRecord.Event__c = 'Update';
                    }
                    logRecords.add(logRecord);
                }
            }
            Database.insert(logRecords,false);
        }

        public void processResponsesData(List<avnio__response__c> recordsData, Id batchId){
            Set<Id> recordIds = new Set<Id>();
            for(avnio__response__c record : recordsData){
                recordIds.add(record.Id);
            }

            List<avnio__response__c> existingRecords = [select id, External_ID__c, avnio__Answer__c, avnio__PrimaryQuestion__c from avnio__response__c where External_ID__c IN :recordIds limit 49999];
            Map<String,avnio__response__c> externalIdToRecordMap = new Map<String,avnio__response__c>();
            if(existingRecords != null && existingRecords.size() > 0){
                for(avnio__response__c rec : existingRecords){
                    externalIdToRecordMap.put(rec.External_ID__c, rec);
                }
            }

            List<String> recordsToCreateVersion = new List<String>();
            List<avnio__response__c> recordsToUpsert = new List<avnio__response__c>();
            List<avnio__response__c> recordsToArchive = new List<avnio__response__c>();
            for(avnio__response__c record : recordsData){
                avnio__response__c newRecord = new avnio__response__c();
                if(externalIdToRecordMap.get(String.valueOf(record.Id)) != null){
                    newRecord.Id = externalIdToRecordMap.get(String.valueOf(record.Id)).Id;
                    if(record.avnio__Answer__c != externalIdToRecordMap.get(String.valueOf(record.Id)).avnio__Answer__c || record.avnio__PrimaryQuestion__c != externalIdToRecordMap.get(String.valueOf(record.Id)).avnio__PrimaryQuestion__c){
                        recordsToCreateVersion.add(externalIdToRecordMap.get(String.valueOf(record.Id)).Id);
                    }
                }
                newRecord.Alert_Text__c = record.Alert_Text__c;
                newRecord.avnio__Answer__c = record.avnio__Answer__c;
                newRecord.Last_Edited_Date__c = record.Last_Edited_Date__c;
                //newRecord.avnio__IsAutoSubmitForReviewCycle__c = record.avnio__IsAutoSubmitForReviewCycle__c;
                newRecord.avnio__HelpText__c = record.avnio__HelpText__c;
                newRecord.PS_Section_Name__c = record.PS_Section_Name__c;
                newRecord.avnio__PrimaryQuestion__c = record.avnio__PrimaryQuestion__c;
                //newRecord.Cloud_Formula__c = record.Cloud_Formula__c;
                //newRecord.Cloud__c = record.Cloud__c;
                newRecord.avnio__Source__c = record.avnio__Source__c;
                newRecord.Tags__c = record.Tags__c;
                newRecord.External_ID__c = String.valueOf(record.Id);
                newRecord.GSX_Integrated_Response__c = record.GSX_Integrated_Response__c;
                if(record.avnio__Status__c != null && record.avnio__Status__c.equalsIgnoreCase('Archived')){
                    newRecord.avnio__Status__c = 'Archived';
                    recordsToArchive.add(newRecord);
                }
                else{
                    recordsToUpsert.add(newRecord);
                }
            }

            if(recordsToArchive.size() > 0){
                Database.upsert(recordsToArchive,false);
            }

            if(recordsToUpsert.size() > 0){
                List<SObject> recordsForCallout = new List<SObject>();
                recordsForCallout.addAll((List<SObject>)recordsToUpsert);
                RFxIntegrationResponseBatch myBatchObject = new RFxIntegrationResponseBatch(recordsForCallout,'avnio__response__c',recordsToCreateVersion,batchId,yesterdayDate);
                Database.executeBatch(myBatchObject,1);
            }
        }

        public void processResponseQuestionsData(List<avnio__responsequestion__c> recordsData, Id batchId){
            Set<Id> recordIds = new Set<Id>();
            Set<Id> responseIds = new Set<Id>();
            for(avnio__responsequestion__c record : recordsData){
                recordIds.add(record.Id);
                responseIds.add(record.avnio__ResponseId__c);
            }

            //check if response present in current publish list
            if(responseIdForPublish != null && responseIdForPublish.size() > 0){
                Map<Id,Id> recordsToCreateDirectAltQuestions = new Map<Id,Id>();
                List<avnio__response__c> existingResponseRecords = [select id, External_ID__c from avnio__response__c where External_ID__c IN :responseIds limit 49999];
                if(existingResponseRecords != null && existingResponseRecords.size() > 0){
                    for(avnio__response__c res : existingResponseRecords){
                        if(responseIdForPublish.contains(res.Id)){
                            recordsToCreateDirectAltQuestions.put(res.External_ID__c,res.Id);
                        }
                    }

                    List<avnio__responsequestion__c> recordsToUpsert = new List<avnio__responsequestion__c>();
                    List<avnio__responsequestion__c> recordsToContinue = new List<avnio__responsequestion__c>();
                    for(avnio__responsequestion__c record : recordsData){
                        if(recordsToCreateDirectAltQuestions.containsKey(record.avnio__ResponseId__c)){
                            avnio__responsequestion__c newRecord = new avnio__responsequestion__c();
                            newRecord.avnio__ResponseId__c = recordsToCreateDirectAltQuestions.get(record.avnio__ResponseId__c);
                            newRecord.avnio__InitialDraft__c = record.avnio__InitialDraft__c;
                            newRecord.avnio__IsDeleted__c = record.avnio__IsDeleted__c;
                            newRecord.avnio__Question__c = record.avnio__Question__c;
                            newRecord.avnio__Source__c = record.avnio__Source__c;
                            newRecord.External_ID__c = String.valueOf(record.Id);
                            recordsToUpsert.add(newRecord);
                        }
                        else{
                            recordsToContinue.add(record);
                        }
                    }

                    if(recordsToUpsert.size() > 0){
                        Database.upsert(recordsToUpsert,false);
                    }

                    recordsData.clear();
                    if(recordsToContinue.size() > 0){
                        recordsData.addAll(recordsToContinue);
                    }
                    else{
                        return;
                    }
                }
            }

            List<avnio__responsequestion__c> existingRecords = [select id, External_ID__c ,avnio__ResponseId__c, avnio__Question__c from avnio__responsequestion__c where External_ID__c IN :recordIds limit 49999];
            Map<String,avnio__responsequestion__c> externalIdToRecordMap = new Map<String,avnio__responsequestion__c>();
            if(existingRecords != null && existingRecords.size() > 0){
                for(avnio__responsequestion__c rec : existingRecords){
                    externalIdToRecordMap.put(rec.External_ID__c, rec);
                }
            }

            List<avnio__responsequestion__c> recordsDataUpdated = new List<avnio__responsequestion__c>();
            //if draft version is present
            Map<Id,avnio__AlternativeQuestionVersion__c> altQuesExToAltQuestionIdMap = new Map<Id,avnio__AlternativeQuestionVersion__c>();
            Map<Id,Id> responseExToResponseVersionIdMapForDraft = new Map<Id,Id>();
            List<avnio__responseversion__c> responseVersions = [select id, avnio__responseId__c, avnio__responseId__r.External_ID__c, avnio__Answer__c from avnio__responseversion__c where avnio__Status__c = 'Draft' AND avnio__responseId__r.External_ID__c IN : responseIds limit 49999];
            if(responseVersions != null && responseVersions.size() > 0){
                for(avnio__responseversion__c rv : responseVersions){
                    if(rv.avnio__responseId__r.External_ID__c != null){
                        responseExToResponseVersionIdMapForDraft.put(rv.avnio__responseId__r.External_ID__c,rv.Id);
                    }
                }
                if(responseExToResponseVersionIdMapForDraft.size() > 0){
                    List<avnio__AlternativeQuestionVersion__c> alternativeQuestionVersionsExisting = [select id, avnio__RootAlternativeQuestionId__c, avnio__RootAlternativeQuestionId__r.External_ID__c from avnio__AlternativeQuestionVersion__c where avnio__ResponseVersionId__c IN :responseExToResponseVersionIdMapForDraft.values() limit 49999];
                    if(alternativeQuestionVersionsExisting != null && alternativeQuestionVersionsExisting.size() > 0){
                        for(avnio__AlternativeQuestionVersion__c aqv : alternativeQuestionVersionsExisting){
                            if(aqv.avnio__RootAlternativeQuestionId__r.External_ID__c != null){
                                altQuesExToAltQuestionIdMap.put(aqv.avnio__RootAlternativeQuestionId__r.External_ID__c,aqv);
                            }
                        }
                    }
                }
            }

            Set<Id> responseIdsToCreateVersion = new Set<Id>();
            List<avnio__AlternativeQuestionVersion__c> altQuestionVersionsToAdd = new List<avnio__AlternativeQuestionVersion__c>();
            
            //Added by sagar start
            // Map<id,avnio__ResponseQuestion__c> currentresponsquestionMap = new Map<id,avnio__ResponseQuestion__c> ();
            // for(avnio__responsequestion__c record : recordsData){
            //     currentresponsquestionMap.put(record.id,null);
            // }
            // List<avnio__ResponseQuestion__c> responsequestionlist = new List<avnio__ResponseQuestion__c> ();
            // responsequestionlist = [select id,External_ID__c from avnio__ResponseQuestion__c where External_ID__c =:currentresponsquestionMap.keyset()];
            // for(avnio__ResponseQuestion__c responsquestion : responsequestionlist) {
            //     currentresponsquestionMap.put(responsquestion.External_ID__c,responsquestion);
            // }
            //added by sagar end
            //system.debug('--->currentresponsquestionMap-->'+currentresponsquestionMap);
            for(avnio__responsequestion__c record : recordsData){
                if(responseExToResponseVersionIdMapForDraft.containsKey(record.avnio__ResponseId__c)){
                    avnio__AlternativeQuestionVersion__c altQVersion = new avnio__AlternativeQuestionVersion__c();
                    altQVersion.avnio__Question__c = record.avnio__Question__c;
                    altQVersion.avnio__ResponseVersionId__c = responseExToResponseVersionIdMapForDraft.get(record.avnio__ResponseId__c);
                    if(altQuesExToAltQuestionIdMap.get(record.Id) != null){
                        altQVersion.Id = altQuesExToAltQuestionIdMap.get(record.Id).Id;
                        altQVersion.avnio__RootAlternativeQuestionId__c = altQuesExToAltQuestionIdMap.get(record.Id).avnio__RootAlternativeQuestionId__c;
                    }
                    else{
                        altQVersion.External_ID_for_Integration__c = String.valueOf(record.Id);
                    }
                    //added by sagar start
                    // if(altQVersion.avnio__RootAlternativeQuestionId__c == null && currentresponsquestionMap != null &&
                    //     currentresponsquestionMap.get(record.Id) != null) {
                    //     altQVersion.avnio__RootAlternativeQuestionId__c = currentresponsquestionMap.get(record.Id).id;
                    // }
                     //added by sagar end
                    altQuestionVersionsToAdd.add(altQVersion);
                }
                else{
                    recordsDataUpdated.add(record);
                    responseIdsToCreateVersion.add(record.avnio__ResponseId__c);
                }
            }

            if(recordsDataUpdated.size() > 0){
                List<avnio__ResponseVersion__c> resVersionsToCreate = new List<avnio__ResponseVersion__c>();
                List<avnio__response__c> responsesForCreatingVersions = [select id, External_ID__c, avnio__Status__c, avnio__Answer__c, avnio__PrimaryQuestion__c from avnio__response__c where External_ID__c IN :responseIdsToCreateVersion limit 49999];
                if(responsesForCreatingVersions != null && responsesForCreatingVersions.size() > 0){
                    Map<Id,Id> responseIdToExrternalIdMap = new Map<Id,Id>();
                    if(responseIdForPublish == null){
                        responseIdForPublish = new List<Id>();
                    }
                    for(avnio__response__c rec : responsesForCreatingVersions){
                        avnio__ResponseVersion__c resVersions = new avnio__ResponseVersion__c();
                        resVersions.avnio__ResponseId__c = rec.Id;
                        resVersions.avnio__Question__c = rec.avnio__PrimaryQuestion__c;
                        resVersions.avnio__Answer__c = rec.avnio__Answer__c;
                        resVersions.avnio__Status__c = 'Draft';
                        resVersionsToCreate.add(resVersions);
                    }
                    insert resVersionsToCreate;
                    Map<Id,Id> responseExternalIdToVersionIdMap = new Map<Id,Id>();
                    for(avnio__ResponseVersion__c rvnew : resVersionsToCreate){
                        responseExternalIdToVersionIdMap.put(responseIdToExrternalIdMap.get(rvnew.avnio__ResponseId__c),rvnew.Id);
                        responseIdForPublish.add(rvnew.Id);
                    }

                    for(avnio__responsequestion__c record : recordsDataUpdated){
                        avnio__AlternativeQuestionVersion__c altQVersion = new avnio__AlternativeQuestionVersion__c();
                        altQVersion.avnio__Question__c = record.avnio__Question__c;
                        altQVersion.avnio__ResponseVersionId__c = responseExternalIdToVersionIdMap.get(record.External_ID__c);
                        altQVersion.External_ID_for_Integration__c = String.valueOf(record.Id);
                        
                        //added by sagar start
                        // if(altQVersion.avnio__RootAlternativeQuestionId__c == null && currentresponsquestionMap != null &&
                        //     currentresponsquestionMap.get(record.Id) != null) {
                        //     altQVersion.avnio__RootAlternativeQuestionId__c = currentresponsquestionMap.get(record.Id).id;
                        // }
                         //added by sagar end
                        altQuestionVersionsToAdd.add(altQVersion);
                    }
                }
            }

            if(altQuestionVersionsToAdd.size() > 0){
                upsert altQuestionVersionsToAdd;
            }
        }

        public void processAlternativeAnswersData(List<avnio__alternativeanswer__c> recordsData, Id batchId){
            Set<Id> recordIds = new Set<Id>();
            Set<Id> responseIds = new Set<Id>();
            for(avnio__alternativeanswer__c record : recordsData){
                recordIds.add(record.Id);
                responseIds.add(record.avnio__ResponseId__c);
            }

            //check if response present in current publish list
            if(responseIdForPublish != null && responseIdForPublish.size() > 0){
                Map<Id,Id> recordsToCreateDirectAltAnswers = new Map<Id,Id>();
                List<avnio__response__c> existingResponseRecords = [select id, External_ID__c from avnio__response__c where External_ID__c IN :responseIds limit 49999];
                if(existingResponseRecords != null && existingResponseRecords.size() > 0){
                    for(avnio__response__c res : existingResponseRecords){
                        if(responseIdForPublish.contains(res.Id)){
                            recordsToCreateDirectAltAnswers.put(res.External_ID__c,res.Id);
                        }
                    }

                    List<avnio__alternativeanswer__c> recordsToUpsert = new List<avnio__alternativeanswer__c>();
                    List<avnio__alternativeanswer__c> recordsToContinue = new List<avnio__alternativeanswer__c>();
                    for(avnio__alternativeanswer__c record : recordsData){
                        if(recordsToCreateDirectAltAnswers.containsKey(record.avnio__ResponseId__c)){
                            avnio__alternativeanswer__c newRecord = new avnio__alternativeanswer__c();
                            newRecord.avnio__ResponseId__c = recordsToCreateDirectAltAnswers.get(record.avnio__ResponseId__c);
                            newRecord.avnio__Title__c = record.avnio__Title__c;
                            newRecord.avnio__IsDeleted__c = record.avnio__IsDeleted__c;
                            newRecord.avnio__Answer__c = record.avnio__Answer__c;
                            newRecord.External_ID__c = String.valueOf(record.Id);
                            recordsToUpsert.add(newRecord);
                        }
                        else{
                            recordsToContinue.add(record);
                        }
                    }

                    if(recordsToUpsert.size() > 0){
                        Database.upsert(recordsToUpsert,false);
                    }

                    recordsData.clear();
                    if(recordsToContinue.size() > 0){
                        recordsData.addAll(recordsToContinue);
                    }
                    else{
                        return;
                    }
                }
            }

            List<avnio__alternativeanswer__c> existingRecords = [select id, External_ID__c ,avnio__ResponseId__c, avnio__Title__c, avnio__Answer__c  from avnio__alternativeanswer__c where External_ID__c IN :recordIds limit 49999];
            Map<String,avnio__alternativeanswer__c> externalIdToRecordMap = new Map<String,avnio__alternativeanswer__c>();
            if(existingRecords != null && existingRecords.size() > 0){
                for(avnio__alternativeanswer__c rec : existingRecords){
                    externalIdToRecordMap.put(rec.External_ID__c, rec);
                }
            }

            List<avnio__alternativeanswer__c> recordsDataUpdated = new List<avnio__alternativeanswer__c>();
            //if draft version is present
            Map<Id,avnio__AlternativeAnswerVersion__c> altAnsExToAltAnsIdMap = new Map<Id,avnio__AlternativeAnswerVersion__c>();
            Map<Id,Id> responseExToResponseVersionIdMapForDraft = new Map<Id,Id>();
            List<avnio__responseversion__c> responseVersions = [select id, avnio__responseId__c, avnio__responseId__r.External_ID__c, avnio__Answer__c from avnio__responseversion__c where avnio__Status__c = 'Draft' AND avnio__responseId__r.External_ID__c IN : responseIds limit 49999];
            if(responseVersions != null && responseVersions.size() > 0){
                for(avnio__responseversion__c rv : responseVersions){
                    if(rv.avnio__responseId__r.External_ID__c != null){
                        responseExToResponseVersionIdMapForDraft.put(rv.avnio__responseId__r.External_ID__c,rv.Id);
                    }
                }
                if(responseExToResponseVersionIdMapForDraft.size() > 0){
                    List<avnio__AlternativeAnswerVersion__c> alternativeAnswerVersionsExisting = [select id, avnio__RootAlternativeAnswerId__c, avnio__RootAlternativeAnswerId__r.External_ID__c from avnio__AlternativeAnswerVersion__c where avnio__ResponseVersionId__c IN :responseExToResponseVersionIdMapForDraft.values() limit 49999];
                    if(alternativeAnswerVersionsExisting != null && alternativeAnswerVersionsExisting.size() > 0){
                        for(avnio__AlternativeAnswerVersion__c aav : alternativeAnswerVersionsExisting){
                            if(aav.avnio__RootAlternativeAnswerId__r.External_ID__c != null){
                                altAnsExToAltAnsIdMap.put(aav.avnio__RootAlternativeAnswerId__r.External_ID__c,aav);
                            }
                        }
                    }
                }
            }

            Set<Id> responseIdsToCreateVersion = new Set<Id>();
            List<avnio__AlternativeAnswerVersion__c> altAnswerVersionsToAdd = new List<avnio__AlternativeAnswerVersion__c>();
            
           //Added by sagar start
            // Map<id,avnio__alternativeanswer__c> currentalternativeanswerMap = new Map<id,avnio__alternativeanswer__c> ();
            // for(avnio__alternativeanswer__c record : recordsData){
            //     currentalternativeanswerMap.put(record.id,null);
            // }
            // List<avnio__alternativeanswer__c> altanswerlist = new List<avnio__alternativeanswer__c> ();
            // altanswerlist = [select id,External_ID__c from avnio__alternativeanswer__c where External_ID__c =:currentalternativeanswerMap.keyset()];
            // for(avnio__alternativeanswer__c altanswer : altanswerlist) {
            //     currentalternativeanswerMap.put(altanswer.External_ID__c,altanswer);
            // }
            //added by sagar end
            
            for(avnio__alternativeanswer__c record : recordsData){
                if(responseExToResponseVersionIdMapForDraft.containsKey(record.avnio__ResponseId__c)){
                    avnio__AlternativeAnswerVersion__c altAnsVersion = new avnio__AlternativeAnswerVersion__c();
                    altAnsVersion.avnio__Answer__c = record.avnio__Answer__c;
                    altAnsVersion.avnio__Title__c = record.avnio__Title__c;
                    altAnsVersion.avnio__ResponseVersionId__c = responseExToResponseVersionIdMapForDraft.get(record.avnio__ResponseId__c);
                    if(altAnsExToAltAnsIdMap.get(record.Id) != null){
                        altAnsVersion.Id = altAnsExToAltAnsIdMap.get(record.Id).Id;
                        altAnsVersion.avnio__RootAlternativeAnswerId__c = altAnsExToAltAnsIdMap.get(record.Id).avnio__RootAlternativeAnswerId__c;
                    }
                    else{
                        altAnsVersion.External_ID_for_Integration__c = String.valueOf(record.Id);
                    }
                    
                     //added by sagar start
                    // if(altAnsVersion.avnio__RootAlternativeAnswerId__c == null && currentalternativeanswerMap != null &&
                    //     currentalternativeanswerMap.get(record.Id) != null) {
                    //     altAnsVersion.avnio__RootAlternativeAnswerId__c = currentalternativeanswerMap.get(record.Id).id;
                    // }
                     //added by sagar end
                     
                    altAnswerVersionsToAdd.add(altAnsVersion);
                }
                else{
                    recordsDataUpdated.add(record);
                    responseIdsToCreateVersion.add(record.avnio__ResponseId__c);
                }
            }

            if(recordsDataUpdated.size() > 0){
                List<avnio__ResponseVersion__c> resVersionsToCreate = new List<avnio__ResponseVersion__c>();
                List<avnio__response__c> responsesForCreatingVersions = [select id, External_ID__c, avnio__Status__c, avnio__Answer__c, avnio__PrimaryQuestion__c from avnio__response__c where External_ID__c IN :responseIdsToCreateVersion limit 49999];
                if(responsesForCreatingVersions != null && responsesForCreatingVersions.size() > 0){
                    Map<Id,Id> responseIdToExrternalIdMap = new Map<Id,Id>();
                    if(responseIdForPublish == null){
                        responseIdForPublish = new List<Id>();
                    }
                    for(avnio__response__c rec : responsesForCreatingVersions){
                        avnio__ResponseVersion__c resVersions = new avnio__ResponseVersion__c();
                        resVersions.avnio__ResponseId__c = rec.Id;
                        resVersions.avnio__Question__c = rec.avnio__PrimaryQuestion__c;
                        resVersions.avnio__Answer__c = rec.avnio__Answer__c;
                        resVersions.avnio__Status__c = 'Draft';
                        resVersionsToCreate.add(resVersions);
                    }
                    insert resVersionsToCreate;
                    Map<Id,Id> responseExternalIdToVersionIdMap = new Map<Id,Id>();
                    for(avnio__ResponseVersion__c rvnew : resVersionsToCreate){
                        responseExternalIdToVersionIdMap.put(responseIdToExrternalIdMap.get(rvnew.avnio__ResponseId__c),rvnew.Id);
                        responseIdForPublish.add(rvnew.Id);
                    }

                    for(avnio__alternativeanswer__c record : recordsDataUpdated){
                        avnio__AlternativeAnswerVersion__c altAnsVersion = new avnio__AlternativeAnswerVersion__c();
                        altAnsVersion.avnio__Answer__c = record.avnio__Answer__c;
                        altAnsVersion.avnio__Title__c = record.avnio__Title__c;
                        altAnsVersion.avnio__ResponseVersionId__c = responseExternalIdToVersionIdMap.get(record.External_ID__c);
                        altAnsVersion.External_ID_for_Integration__c = String.valueOf(record.Id);
                         //added by sagar start
                    // if(altAnsVersion.avnio__RootAlternativeAnswerId__c == null && currentalternativeanswerMap != null &&
                    //     currentalternativeanswerMap.get(record.Id) != null) {
                    //     altAnsVersion.avnio__RootAlternativeAnswerId__c = currentalternativeanswerMap.get(record.Id).id;
                    // }
                     //added by sagar end
                        altAnswerVersionsToAdd.add(altAnsVersion);
                    }
                }
            }

            if(altAnswerVersionsToAdd.size() > 0){
                upsert altAnswerVersionsToAdd;
            }
        }

        public void processResponseCategoriesData(List<avnio__responsecategory__c> recordsData, Id batchId){
            System.debug(recordsData);
            Set<Id> recordIds = new Set<Id>();
            Set<Id> categoryIds = new Set<Id>();
            Set<Id> responseIds = new Set<Id>();
            for(avnio__responsecategory__c record : recordsData){
                recordIds.add(record.Id);
                categoryIds.add(record.avnio__CategoryId__c);
                responseIds.add(record.avnio__ResponseId__c);
            }

            List<avnio__responsecategory__c> existingRecords = [select id, External_ID__c from avnio__responsecategory__c where External_ID__c IN :recordIds limit 49999];
            Map<String,String> externalIdToRecordIdMap = new Map<String,String>();
            if(existingRecords != null && existingRecords.size() > 0){
                for(avnio__responsecategory__c rec : existingRecords){
                    externalIdToRecordIdMap.put(rec.External_ID__c, rec.Id);
                }
            }

            List<avnio__category__c> existingCatRecords = [select id, External_ID__c from avnio__category__c where External_ID__c IN :categoryIds limit 49999];
            Map<String,String> externalIdToCategoryIdsMap = new Map<String,String>();
            if(existingCatRecords != null && existingCatRecords.size() > 0){
                for(avnio__category__c rec : existingCatRecords){
                    externalIdToCategoryIdsMap.put(rec.External_ID__c, rec.Id);
                }
            }

            List<avnio__response__c> existingResponseRecords = [select id, External_ID__c from avnio__response__c where External_ID__c IN :responseIds limit 49999];
            Map<String,String> externalIdToResponseIdsMap = new Map<String,String>();
            if(existingResponseRecords != null && existingResponseRecords.size() > 0){
                for(avnio__response__c rec : existingResponseRecords){
                    externalIdToResponseIdsMap.put(rec.External_ID__c, rec.Id);
                }
            }

            List<avnio__responsecategory__c> recordsToUpsert = new List<avnio__responsecategory__c>();
            List<RFX_Integration_Log__c> logRecords = new List<RFX_Integration_Log__c>();
            for(avnio__responsecategory__c record : recordsData){
                if(record.avnio__CategoryId__c != null && record.avnio__ResponseId__c != null && externalIdToCategoryIdsMap.get(record.avnio__CategoryId__c) != null && externalIdToResponseIdsMap.get(record.avnio__ResponseId__c) != null){
                    avnio__responsecategory__c newRecord = new avnio__responsecategory__c();
                    if(externalIdToRecordIdMap.get(String.valueOf(record.Id)) != null){
                        newRecord.Id = externalIdToRecordIdMap.get(String.valueOf(record.Id));
                    }
                    newRecord.avnio__CategoryId__c = externalIdToCategoryIdsMap.get(record.avnio__CategoryId__c);
                    newRecord.avnio__ResponseId__c = externalIdToResponseIdsMap.get(record.avnio__ResponseId__c);
                    newRecord.External_ID__c = String.valueOf(record.Id);
                    recordsToUpsert.add(newRecord);
                }
            }
            Database.upsert(recordsToUpsert,false);

            for(avnio__responsecategory__c rec : recordsToUpsert){
                if(rec.Id != null){
                    RFX_Integration_Log__c logRecord = new RFX_Integration_Log__c();
                    logRecord.RFX_Integration_Batch__c = batchId;
                    logRecord.Response_Category__c = rec.Id;
                    logRecord.Event__c = 'Create';
                    if(externalIdToRecordIdMap.get(String.valueOf(rec.External_ID__c)) != null){
                        logRecord.Event__c = 'Update';
                    }
                    logRecords.add(logRecord);
                }
            }
            Database.insert(logRecords,false);

        }

        public void processResponseTagsData(List<avnio__responsetag__c> recordsData, Id batchId){
            Set<Id> recordIds = new Set<Id>();
            Set<Id> tagIds = new Set<Id>();
            Set<Id> responseIds = new Set<Id>();
            for(avnio__responsetag__c record : recordsData){
                recordIds.add(record.Id);
                tagIds.add(record.avnio__TagId__c);
                responseIds.add(record.avnio__ResponseId__c);
            }

            List<avnio__responsetag__c> existingRecords = [select id, External_ID__c from avnio__responsetag__c where External_ID__c IN :recordIds limit 49999];
            Map<String,String> externalIdToRecordIdMap = new Map<String,String>();
            if(existingRecords != null && existingRecords.size() > 0){
                for(avnio__responsetag__c rec : existingRecords){
                    externalIdToRecordIdMap.put(rec.External_ID__c, rec.Id);
                }
            }

            List<avnio__tag__c> existingTagRecords = [select id, External_ID__c from avnio__tag__c where External_ID__c IN :tagIds limit 49999];
            Map<String,String> externalIdToTagIdsMap = new Map<String,String>();
            if(existingTagRecords != null && existingTagRecords.size() > 0){
                for(avnio__tag__c rec : existingTagRecords){
                    externalIdToTagIdsMap.put(rec.External_ID__c, rec.Id);
                }
            }

            List<avnio__response__c> existingResponseRecords = [select id, External_ID__c from avnio__response__c where External_ID__c IN :responseIds limit 49999];
            Map<String,String> externalIdToResponseIdsMap = new Map<String,String>();
            if(existingResponseRecords != null && existingResponseRecords.size() > 0){
                for(avnio__response__c rec : existingResponseRecords){
                    externalIdToResponseIdsMap.put(rec.External_ID__c, rec.Id);
                }
            }

            List<avnio__responsetag__c> recordsToUpsert = new List<avnio__responsetag__c>();
            List<RFX_Integration_Log__c> logRecords = new List<RFX_Integration_Log__c>();
            for(avnio__responsetag__c record : recordsData){
                if(record.avnio__TagId__c != null && record.avnio__ResponseId__c != null && externalIdToTagIdsMap.get(record.avnio__TagId__c) != null && externalIdToResponseIdsMap.get(record.avnio__ResponseId__c) != null){
                    avnio__responsetag__c newRecord = new avnio__responsetag__c();
                    if(externalIdToRecordIdMap.get(String.valueOf(record.Id)) != null){
                        newRecord.Id = externalIdToRecordIdMap.get(String.valueOf(record.Id));
                    }
                    newRecord.avnio__TagId__c = externalIdToTagIdsMap.get(record.avnio__TagId__c);
                    newRecord.avnio__ResponseId__c = externalIdToResponseIdsMap.get(record.avnio__ResponseId__c);
                    newRecord.External_ID__c = String.valueOf(record.Id);
                    recordsToUpsert.add(newRecord);
                }
            }
            Database.upsert(recordsToUpsert,false);

            for(avnio__responsetag__c rec : recordsToUpsert){
                if(rec.Id != null){
                    RFX_Integration_Log__c logRecord = new RFX_Integration_Log__c();
                    logRecord.RFX_Integration_Batch__c = batchId;
                    logRecord.Response_Tag__c = rec.Id;
                    logRecord.Event__c = 'Create';
                    if(externalIdToRecordIdMap.get(String.valueOf(rec.External_ID__c)) != null){
                        logRecord.Event__c = 'Update';
                    }
                    logRecords.add(logRecord);
                }
            }
            Database.insert(logRecords,false);
        }

        public void processDeletedRecordsData(List<Object> recordsData, Id batchId){
            Set<Id> categoryIds = new Set<Id>();
            Set<Id> tagIds = new Set<Id>();
            Set<Id> responseIds = new Set<Id>();
            Set<Id> responseQuestionIds = new Set<Id>();
            Set<Id> alternativeAnswerIds = new Set<Id>();
            Set<Id> responseCategoryIds = new Set<Id>();
            Set<Id> responseTagIds = new Set<Id>();
            for(Object record : recordsData){
                Map<String, Object> deletedRecordMap = (Map<String, Object>)record;
                String recordId = String.valueOf(deletedRecordMap.get('Record_ID__c'));
                String objectAPIName = String.valueOf(deletedRecordMap.get('Object_API_Name__c')).toLowercase();
                if(recordId != null && String.isNotBlank(recordId) && objectAPIName != null && String.isNotBlank(objectAPIName)){
                    switch on objectAPIName {
                        when 'avnio__category__c' {
                            categoryIds.add(recordId);
                        }
                        when 'avnio__tag__c' {
                            tagIds.add(recordId);
                        }
                        when 'avnio__response__c' {
                            responseIds.add(recordId);
                        }
                        when 'avnio__responsequestion__c' {
                            responseQuestionIds.add(recordId);
                            system.debug('--->responseQuestionIds'+responseQuestionIds);
                        }
                        when 'avnio__alternativeanswer__c' {
                            alternativeAnswerIds.add(recordId);
                        }
                        when 'avnio__responsecategory__c' {
                            responseCategoryIds.add(recordId);
                        }
                        when 'avnio__responsetag__c' {
                            responseTagIds.add(recordId);
                        }
                    }
                }
            }

            if(categoryIds.size() > 0){
                List<avnio__category__c> existingRecords = [select id, External_ID__c from avnio__category__c where External_ID__c IN :categoryIds limit 10000];
                if(existingRecords != null && existingRecords.size() > 0){
                    delete existingRecords;
                }
            }
            if(tagIds.size() > 0){
                List<avnio__tag__c> existingRecords = [select id, External_ID__c from avnio__tag__c where External_ID__c IN :tagIds limit 10000];
                if(existingRecords != null && existingRecords.size() > 0){
                    delete existingRecords;
                }
            }
            if(responseIds.size() > 0){
                List<avnio__response__c> existingRecords = [select id, External_ID__c, avnio__Status__c from avnio__response__c where External_ID__c IN :responseIds limit 10000];
                if(existingRecords != null && existingRecords.size() > 0){
                    for(avnio__response__c response : existingRecords){
                        response.avnio__Status__c = 'Archived';
                    }
                    update existingRecords;
                }
            }
            if(responseQuestionIds.size() > 0){
                List<avnio__responsequestion__c> existingRecords = [select id, External_ID__c, avnio__ResponseId__c, avnio__ResponseId__r.avnio__PrimaryQuestion__c, avnio__ResponseId__r.avnio__Answer__c from avnio__responsequestion__c where External_ID__c IN :responseQuestionIds limit 10000];
                system.debug('processAltQuestionsDeleteData_new--->'+existingRecords);
                if(existingRecords != null && existingRecords.size() > 0){
                    processAltQuestionsDeleteData_new(existingRecords);
                }
            }
            if(alternativeAnswerIds.size() > 0){
                List<avnio__alternativeanswer__c> existingRecords = [select id, External_ID__c, avnio__ResponseId__c, avnio__ResponseId__r.avnio__PrimaryQuestion__c, avnio__ResponseId__r.avnio__Answer__c from avnio__alternativeanswer__c where External_ID__c IN :alternativeAnswerIds limit 10000];
                if(existingRecords != null && existingRecords.size() > 0){
                    processAltAnswerDeleteData_new(existingRecords);
                }
            }
            if(responseCategoryIds.size() > 0){
                List<avnio__responsecategory__c> existingRecords = [select id, External_ID__c from avnio__responsecategory__c where External_ID__c IN :responseCategoryIds limit 10000];
                if(existingRecords != null && existingRecords.size() > 0){
                    delete existingRecords;
                }
            }
            if(responseTagIds.size() > 0){
                List<avnio__responsetag__c> existingRecords = [select id, External_ID__c from avnio__responsetag__c where External_ID__c IN :responseTagIds limit 10000];
                if(existingRecords != null && existingRecords.size() > 0){
                    delete existingRecords;
                }
            }
        }
        
       //added by sagar - start
         public void processAltQuestionsDeleteData_new (List<avnio__responsequestion__c> recordsData){
            if(recordsData != null && recordsData.size() > 0) {
                Set<id> deletedrecordidset = new Set<id> ();
                for(avnio__responsequestion__c resq : recordsData) {
                    deletedrecordidset.add(resq.id);
                }
                List<avnio__AlternativeQuestionVersion__c> existingalternativequestionversionlist = new List<avnio__AlternativeQuestionVersion__c> ();
                existingalternativequestionversionlist = [select id from avnio__AlternativeQuestionVersion__c  where avnio__RootAlternativeQuestionId__r.id IN:deletedrecordidset];
                system.debug('---->existingalternativequestionversionlist'+existingalternativequestionversionlist);
                if(existingalternativequestionversionlist != null && existingalternativequestionversionlist.size() > 0) {
                    
                    delete existingalternativequestionversionlist;
                }
            }
        }
        
        //added by sagar - end
        
        
        //added by sagar - start
         public void processAltAnswerDeleteData_new (List<avnio__alternativeanswer__c> recordsData){
            if(recordsData != null && recordsData.size() > 0) {
                Set<id> deletedrecordidset = new Set<id> ();
                for(avnio__alternativeanswer__c resq : recordsData) {
                    deletedrecordidset.add(resq.id);
                }
                List<avnio__AlternativeAnswerVersion__c> existingalternativanswerversionlist = new List<avnio__AlternativeAnswerVersion__c> ();
                existingalternativanswerversionlist = [select id from avnio__AlternativeAnswerVersion__c  where avnio__RootAlternativeAnswerId__r.id IN:deletedrecordidset];
                system.debug('---->existingalternativequestionversionlist'+existingalternativanswerversionlist);
                if(existingalternativanswerversionlist != null && existingalternativanswerversionlist.size() > 0) {
                    
                    delete existingalternativanswerversionlist;
                }
            }
        }
        
        //added by sagar - end
        
       
        
        /*public void processAltQuestionsDeleteData(List<avnio__responsequestion__c> recordsData){
            Set<Id> recordIds = new Set<Id>();
            Set<Id> responseIds = new Set<Id>();
            for(avnio__responsequestion__c record : recordsData){
                recordIds.add(record.Id);
                responseIds.add(record.avnio__ResponseId__c);
            }
    
            if(responseIdForPublish != null && responseIdForPublish.size() > 0){
                List<Id> recordsToDeleteDirectly = new List<Id>();
                List<avnio__response__c> existingResponseRecords = [select id, External_ID__c from avnio__response__c where Id IN :responseIds limit 49999];
                if(existingResponseRecords != null && existingResponseRecords.size() > 0){
                    for(avnio__response__c res : existingResponseRecords){
                        if(responseIdForPublish.contains(res.Id)){
                            recordsToDeleteDirectly.add(res.Id);
                        }
                    }
                    List<avnio__responsequestion__c> recordsToDelete = new List<avnio__responsequestion__c>();
                    List<avnio__responsequestion__c> recordsToContinue = new List<avnio__responsequestion__c>();
                    for(avnio__responsequestion__c record : recordsData){
                        if(recordsToDeleteDirectly.contains(record.avnio__ResponseId__c)){
                            recordsToDelete.add(record);
                        }
                        else{
                            recordsToContinue.add(record);
                        }
                    }
        
                    if(recordsToDelete.size() > 0){
                        Database.delete(recordsToDelete,false);
                    }
        
                    recordsData.clear();
                    if(recordsToContinue.size() > 0){
                        recordsData.addAll(recordsToContinue);
                    }
                    else{
                        return;
                    }
                }
            }
    
            if(recordsData.size() > 0){
                Set<Id> recordIdsNew = new Set<Id>();
                for(avnio__responsequestion__c record : recordsData){
                    recordIdsNew.add(record.Id);
                }
                //if draft version is present
                List<avnio__AlternativeQuestionVersion__c> alternativeQuestionVersionsExisting = [select id, avnio__RootAlternativeQuestionId__c from avnio__AlternativeQuestionVersion__c where avnio__ResponseVersionId__r.avnio__Status__c = 'Draft' AND avnio__ResponseVersionId__r.avnio__responseId__c IN : recordIdsNew limit 49999];
                List<Id> recordIdsToDelete = new List<ID>();
                if(alternativeQuestionVersionsExisting != null && alternativeQuestionVersionsExisting.size() > 0){
                    for(avnio__AlternativeQuestionVersion__c aqv : alternativeQuestionVersionsExisting){
                        recordIdsToDelete.add(aqv.avnio__RootAlternativeQuestionId__c);
                    }
                    delete alternativeQuestionVersionsExisting;
                }
    
                List<avnio__responsequestion__c> finalDataToDelete = new List<avnio__responsequestion__c>();
                for(avnio__responsequestion__c record : recordsData){
                    if(!recordIdsToDelete.contains(record.Id)){
                        finalDataToDelete.add(record);
                    }
                }
    
                //create responseVersion and delete
                if(finalDataToDelete.size() > 0){
                    recordIdsNew.clear();
                    List<avnio__ResponseVersion__c> resVersionsToCreate = new List<avnio__ResponseVersion__c>();
                    for(avnio__responsequestion__c record : finalDataToDelete){
                        avnio__ResponseVersion__c resVersions = new avnio__ResponseVersion__c();
                        resVersions.avnio__ResponseId__c = record.avnio__ResponseId__c;
                        resVersions.avnio__Question__c = record.avnio__ResponseId__r.avnio__PrimaryQuestion__c;
                        resVersions.avnio__Answer__c = record.avnio__ResponseId__r.avnio__Answer__c;
                        resVersions.avnio__Status__c = 'Draft';
                        resVersionsToCreate.add(resVersions);
                        recordIdsNew.add(record.avnio__ResponseId__c);
                    }
                    insert resVersionsToCreate;
    
                    Map<Id,Id> responseIdToVersionIdMap = new Map<Id,Id>();
                    for(avnio__ResponseVersion__c rvnew : resVersionsToCreate){
                        responseIdForPublish.add(rvnew.Id);
                        responseIdToVersionIdMap.put(rvnew.avnio__ResponseId__c,rvnew.Id);
                    }
    
                    //create all alt questions version again
                    List<avnio__responsequestion__c> altQuestions = [select id, avnio__ResponseId__c, avnio__Question__c, External_ID__c from avnio__responsequestion__c where avnio__ResponseId__c IN : recordIdsNew limit 49999];
                    if(altQuestions != null && altQuestions.size() > 0){
                        List<avnio__AlternativeQuestionVersion__c> altQuestionVersionsToAdd = new List<avnio__AlternativeQuestionVersion__c>();
                        for(avnio__responsequestion__c aq : altQuestions){
                            if(!recordIds.contains(aq.Id)){
                                avnio__AlternativeQuestionVersion__c altQVersion = new avnio__AlternativeQuestionVersion__c();
                                altQVersion.avnio__Question__c = aq.avnio__Question__c;
                                altQVersion.avnio__ResponseVersionId__c = responseIdToVersionIdMap.get(aq.avnio__ResponseId__c);
                                altQVersion.External_ID_for_Integration__c = aq.External_ID__c;
                                altQuestionVersionsToAdd.add(altQVersion);
                            }
                        }
                        if(altQuestionVersionsToAdd.size() > 0){
                            insert altQuestionVersionsToAdd;
                        }
                    }
    
                    //create all alt answer version again
                    List<avnio__alternativeanswer__c> altAnswers = [select id, avnio__ResponseId__c, avnio__Answer__c, avnio__Title__c, External_ID__c from avnio__alternativeanswer__c where avnio__ResponseId__c IN : recordIdsNew limit 49999];
                    if(altAnswers != null && altAnswers.size() > 0){
                        List<avnio__AlternativeAnswerVersion__c> altAnswerVersionsToAdd = new List<avnio__AlternativeAnswerVersion__c>();
                        for(avnio__alternativeanswer__c aa : altAnswers){
                            avnio__AlternativeAnswerVersion__c altAVersion = new avnio__AlternativeAnswerVersion__c();
                            altAVersion.avnio__Answer__c = aa.avnio__Answer__c;
                            altAVersion.avnio__Title__c = aa.avnio__Title__c;
                            altAVersion.avnio__ResponseVersionId__c = responseIdToVersionIdMap.get(aa.avnio__ResponseId__c);
                            altAVersion.External_ID_for_Integration__c = aa.External_ID__c;
                            altAnswerVersionsToAdd.add(altAVersion);
                        }
                        if(altAnswerVersionsToAdd.size() > 0){
                            insert altAnswerVersionsToAdd;
                        }
                    }
                }
            }        
        }
    
        public void processAltAnswersDeleteData(List<avnio__alternativeanswer__c> recordsData){
            Set<Id> recordIds = new Set<Id>();
            Set<Id> responseIds = new Set<Id>();
            for(avnio__alternativeanswer__c record : recordsData){
                recordIds.add(record.Id);
                responseIds.add(record.avnio__ResponseId__c);
            }
        
            if(responseIdForPublish != null && responseIdForPublish.size() > 0){
                List<Id> recordsToDeleteDirectly = new List<Id>();
                List<avnio__response__c> existingResponseRecords = [select id, External_ID__c from avnio__response__c where Id IN :responseIds limit 49999];
                if(existingResponseRecords != null && existingResponseRecords.size() > 0){
                    for(avnio__response__c res : existingResponseRecords){
                        if(responseIdForPublish.contains(res.Id)){
                            recordsToDeleteDirectly.add(res.Id);
                        }
                    }
                    List<avnio__alternativeanswer__c> recordsToDelete = new List<avnio__alternativeanswer__c>();
                    List<avnio__alternativeanswer__c> recordsToContinue = new List<avnio__alternativeanswer__c>();
                    for(avnio__alternativeanswer__c record : recordsData){
                        if(recordsToDeleteDirectly.contains(record.avnio__ResponseId__c)){
                            recordsToDelete.add(record);
                        }
                        else{
                            recordsToContinue.add(record);
                        }
                    }
        
                    if(recordsToDelete.size() > 0){
                        Database.delete(recordsToDelete,false);
                    }
        
                    recordsData.clear();
                    if(recordsToContinue.size() > 0){
                        recordsData.addAll(recordsToContinue);
                    }
                    else{
                        return;
                    }
                }
            }
        
            if(recordsData.size() > 0){
                Set<Id> recordIdsNew = new Set<Id>();
                for(avnio__alternativeanswer__c record : recordsData){
                    recordIdsNew.add(record.Id);
                }
                //if draft version is present
                List<avnio__AlternativeAnswerVersion__c> alternativeAnswerVersionsExisting = [select id, avnio__RootAlternativeAnswerId__c from avnio__AlternativeAnswerVersion__c where avnio__ResponseVersionId__r.avnio__Status__c = 'Draft' AND avnio__ResponseVersionId__r.avnio__responseId__c IN : recordIdsNew limit 49999];
                List<Id> recordIdsToDelete = new List<ID>();
                if(alternativeAnswerVersionsExisting != null && alternativeAnswerVersionsExisting.size() > 0){
                    for(avnio__AlternativeAnswerVersion__c aqv : alternativeAnswerVersionsExisting){
                        recordIdsToDelete.add(aqv.avnio__RootAlternativeAnswerId__c);
                    }
                    delete alternativeAnswerVersionsExisting;
                }
        
                List<avnio__alternativeanswer__c> finalDataToDelete = new List<avnio__alternativeanswer__c>();
                for(avnio__alternativeanswer__c record : recordsData){
                    if(!recordIdsToDelete.contains(record.Id)){
                        finalDataToDelete.add(record);
                    }
                }
        
                //create responseVersion and delete
                if(finalDataToDelete.size() > 0){
                    recordIdsNew.clear();
                    List<avnio__ResponseVersion__c> resVersionsToCreate = new List<avnio__ResponseVersion__c>();
                    for(avnio__alternativeanswer__c record : finalDataToDelete){
                        avnio__ResponseVersion__c resVersions = new avnio__ResponseVersion__c();
                        resVersions.avnio__ResponseId__c = record.avnio__ResponseId__c;
                        resVersions.avnio__Question__c = record.avnio__ResponseId__r.avnio__PrimaryQuestion__c;
                        resVersions.avnio__Answer__c = record.avnio__ResponseId__r.avnio__Answer__c;
                        resVersions.avnio__Status__c = 'Draft';
                        resVersionsToCreate.add(resVersions);
                        recordIdsNew.add(record.avnio__ResponseId__c);
                    }
                    insert resVersionsToCreate;
        
                    Map<Id,Id> responseIdToVersionIdMap = new Map<Id,Id>();
                    for(avnio__ResponseVersion__c rvnew : resVersionsToCreate){
                        responseIdForPublish.add(rvnew.Id);
                        responseIdToVersionIdMap.put(rvnew.avnio__ResponseId__c,rvnew.Id);
                    }
        
                    //create all alt answer version again
                    List<avnio__alternativeanswer__c> altAnswers = [select id, avnio__ResponseId__c, avnio__Answer__c, avnio__Title__c, External_ID__c from avnio__alternativeanswer__c where avnio__ResponseId__c IN : recordIdsNew limit 49999];
                    if(altAnswers != null && altAnswers.size() > 0){
                        List<avnio__AlternativeAnswerVersion__c> altAnswerVersionsToAdd = new List<avnio__AlternativeAnswerVersion__c>();
                        for(avnio__alternativeanswer__c aa : altAnswers){
                            if(!recordIds.contains(aa.Id)){
                                avnio__AlternativeAnswerVersion__c altAVersion = new avnio__AlternativeAnswerVersion__c();
                                altAVersion.avnio__Answer__c = aa.avnio__Answer__c;
                                altAVersion.avnio__Title__c = aa.avnio__Title__c;
                                altAVersion.avnio__ResponseVersionId__c = responseIdToVersionIdMap.get(aa.avnio__ResponseId__c);
                                altAVersion.External_ID_for_Integration__c = aa.External_ID__c;
                                altAnswerVersionsToAdd.add(altAVersion);
                            }
                        }
                        if(altAnswerVersionsToAdd.size() > 0){
                            insert altAnswerVersionsToAdd;
                        }
                    }
        
                    //create all alt questions version again
                    List<avnio__responsequestion__c> altQuestions = [select id, avnio__ResponseId__c, avnio__Question__c, External_ID__c from avnio__responsequestion__c where avnio__ResponseId__c IN : recordIdsNew limit 49999];
                    if(altQuestions != null && altQuestions.size() > 0){
                        List<avnio__AlternativeQuestionVersion__c> altQuestionVersionsToAdd = new List<avnio__AlternativeQuestionVersion__c>();
                        for(avnio__responsequestion__c aq : altQuestions){
                            avnio__AlternativeQuestionVersion__c altQVersion = new avnio__AlternativeQuestionVersion__c();
                            altQVersion.avnio__Question__c = aq.avnio__Question__c;
                            altQVersion.avnio__ResponseVersionId__c = responseIdToVersionIdMap.get(aq.avnio__ResponseId__c);
                            altQVersion.External_ID_for_Integration__c = aq.External_ID__c;
                            altQuestionVersionsToAdd.add(altQVersion);
                        }
                        if(altQuestionVersionsToAdd.size() > 0){
                            insert altQuestionVersionsToAdd;
                        }
                    }
                }
            }
        }*/
    }
    
    @AuraEnabled
    public static Boolean runIntegrationBatch() {
        Boolean isRun = false;
        try{
            RFxIntegrationSchedular sc = new RFxIntegrationSchedular();
            sc.execute(null);
            isRun = true;
        }
        catch(Exception e){}
        return isRun;
    }
}