public without sharing class RFxIntegrationResponseBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public List<SObject> responseRecords;
    public String objectName;
    public List<String> recordsToCreateVersion;
    public Id batchId;
    public String yesterdayDate;
    public List<Id> responseIdFoRInsert = new List<Id>();
    public List<Id> responseIdFoUpdate = new List<Id>();

    public RFxIntegrationResponseBatch(List<SObject> responseRecords, String objectName, List<String> recordsToCreateVersion, Id batchId, String yesterdayDate) {
        this.responseRecords = responseRecords;
        this.objectName = objectName;
        this.recordsToCreateVersion = recordsToCreateVersion;
        this.batchId = batchId;
        this.yesterdayDate = yesterdayDate;
    }
    
    public Iterable<sObject> start(Database.BatchableContext bc){
        return responseRecords;
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        if(scope == null || scope.size() == 0){
            return;
        }
        
        Id ownerIdForResponse;
        List<User> users = [select id,name,email,IsActive from user  where email = 'denise.nelson@salesforce.com' and IsActive = true limit 1];
        if(users != null && users.size() > 0){
            ownerIdForResponse = users[0].Id;
        }

        RFxIntegrationSchedular.actionFromSchedular = true;
        for(sObject obj : scope){
            if(objectName != null && objectName.equalsIgnoreCase('avnio__response__c')){
                avnio__response__c responseObj = (avnio__response__c) obj;
                avnio__response__c responseObjClone = new avnio__response__c();
                responseObjClone.Alert_Text__c = responseObj.Alert_Text__c;
                responseObjClone.Last_Edited_Date__c = responseObj.Last_Edited_Date__c;
                //responseObjClone.avnio__IsAutoSubmitForReviewCycle__c = responseObj.avnio__IsAutoSubmitForReviewCycle__c;
                responseObjClone.avnio__HelpText__c = responseObj.avnio__HelpText__c;
                responseObjClone.PS_Section_Name__c = responseObj.PS_Section_Name__c;
                responseObjClone.avnio__Source__c = responseObj.avnio__Source__c;
                responseObjClone.Tags__c = responseObj.Tags__c;
                responseObjClone.External_ID__c = responseObj.External_ID__c;
                responseObjClone.GSX_Integrated_Response__c = responseObj.GSX_Integrated_Response__c;

                if(responseObj.Id != null){
                    if((recordsToCreateVersion != null && recordsToCreateVersion.contains(responseObj.Id)) || Test.isRunningTest()){
                        List<avnio__ResponseQuestion__c> responsequestionlist = new List<avnio__ResponseQuestion__c> ();
                        responsequestionlist = [select id, avnio__Source__c, avnio__Question__c,avnio__ResponseId__c from avnio__ResponseQuestion__c where avnio__ResponseId__c =:responseObj.Id];
                        List<avnio.DTOAlternativeQuestion> altquestionlist = new List<avnio.DTOAlternativeQuestion> ();
                        for(avnio__ResponseQuestion__c responsequestion : responsequestionlist) {
                            avnio.DTOAlternativeQuestion DTOAltquestion = new avnio.DTOAlternativeQuestion ();
                            DTOAltquestion.id = responsequestion.id;
                            DTOAltquestion.responseId = responsequestion.avnio__ResponseId__c;
                            DTOAltquestion.question = responsequestion.avnio__Question__c;
                            DTOAltquestion.source=responsequestion.avnio__Source__c;
                            altquestionlist.add(DTOAltquestion);
                        }
                        
                        List< avnio__AlternativeAnswer__c> alternativeanswerlist = new List< avnio__AlternativeAnswer__c> ();
                        alternativeanswerlist =[select id,avnio__Answer__c,avnio__ResponseId__c,avnio__Title__c from avnio__AlternativeAnswer__c where avnio__ResponseId__c=:responseObj.Id];
                        List<avnio.DTOAlternativeAnswer> altanswerlist = new List<avnio.DTOAlternativeAnswer> ();
                        
                        for(avnio__AlternativeAnswer__c altanswer : alternativeanswerlist) {
                            avnio.DTOAlternativeAnswer DTOAltanswer = new avnio.DTOAlternativeAnswer ();
                            DTOAltanswer.id = altanswer.id;
                            DTOAltanswer.responseId = altanswer.avnio__ResponseId__c;
                            DTOAltanswer.answer = altanswer.avnio__Answer__c;
                            DTOAltanswer.title=altanswer.avnio__Title__c;
                            altanswerlist.add(DTOAltanswer);
                        }
                        
                        avnio.DTOResponse res = new avnio.DTOResponse();
                        res.question = responseObj.avnio__PrimaryQuestion__c;
                        res.answer = responseObj.avnio__Answer__c;
                        if(altquestionlist != null && altquestionlist.size() > 0) {
                            res.alternativeQuestions = altquestionlist;
                        }
                         if(altanswerlist != null && altanswerlist.size() > 0) {
                            res.alternativeAnswers = altanswerlist;
                        }
                        RestRequest req = new RestRequest();
                        RestResponse resContx = new RestResponse();
                        req.requestURI = '/services/apexrest/avnio/Response/'+String.valueOf(responseObj.Id);
                        req.httpMethod = 'PATCH';
                        req.addHeader('Content-Type','application/json');
                        RestContext.request = req;
                        RestContext.response = resContx;
                        String responseId = avnio.ResponseService.updateResponse(res);
                        if(responseId != null && responseId.contains('A draft version already exists.')){
                            List<avnio__ResponseVersion__c> resVersions = [select id, avnio__Question__c, avnio__Answer__c from avnio__ResponseVersion__c where avnio__ResponseId__c =: responseObj.Id AND avnio__Status__c = 'Draft' limit 1];
                            if(resVersions != null && resVersions.size() > 0){
                                resVersions[0].avnio__Question__c = responseObj.avnio__PrimaryQuestion__c;
                                resVersions[0].avnio__Answer__c = responseObj.avnio__Answer__c;
                                update resVersions;
                                responseIdFoUpdate.add(resVersions[0].Id);
                            }
                        }
                        else{
                            List<avnio__ResponseVersion__c> resVersions = [select id, avnio__Question__c, avnio__Answer__c from avnio__ResponseVersion__c where avnio__ResponseId__c =: responseObj.Id AND avnio__Status__c = 'Draft' limit 1];
                            if(resVersions != null && resVersions.size() > 0){
                                responseIdFoUpdate.add(resVersions[0].Id);
                            }
                        }
                        
                        if(responseObj.Id != null){
                            RFX_Integration_Log__c logRecord = new RFX_Integration_Log__c();
                            logRecord.RFX_Integration_Batch__c = batchId;
                            logRecord.Response__c =  responseObj.Id;
                            logRecord.Event__c = 'Update';
                            insert logRecord;
                        }
                    }
                    
                    responseObjClone.Id = responseObj.Id;
                    Database.update(responseObjClone);
                }
                else{
                    avnio.DTOResponse res = new avnio.DTOResponse();
                    res.question = responseObj.avnio__PrimaryQuestion__c;
                    res.answer = responseObj.avnio__Answer__c;
                    RestRequest req = new RestRequest();
                    RestResponse resContx = new RestResponse();
                    req.requestURI = '/services/apexrest/avnio/Response';
                    req.httpMethod = 'POST';
                    req.addHeader('Content-Type','application/json');
                    RestContext.request = req;
                    RestContext.response = resContx;
                    String responseId = avnio.ResponseService.createResponse(res);
                    responseObj.Id = responseId;

                    responseIdFoRInsert.add(responseId);
                    
                    responseObjClone.Id = responseObj.Id;
                    if(ownerIdForResponse != null){
                        responseObjClone.ownerId = ownerIdForResponse;
                    }
                    responseObjClone.Cloud_Formula__c = 'Public Sector';
                    responseObjClone.Cloud__c = 'Public Sector';
                    if(!Test.isRunningTest()){
                    	Database.update(responseObjClone);
                    }
                    
                    if(responseObj.Id != null){
                        RFX_Integration_Log__c logRecord = new RFX_Integration_Log__c();
                        logRecord.RFX_Integration_Batch__c = batchId;
                        logRecord.Response__c = responseObj.Id;
                        logRecord.Event__c = 'Create';
                        insert logRecord;
                    }
                }
            }
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
        if(responseIdFoRInsert != null && responseIdFoRInsert.size() > 0){
            RFxIntegrationSchedular.actionFromSchedular = true;
            Id categoryId;
            List<avnio__Category__c> categoryList = [select id,name from avnio__Category__c where name = 'GSX Content' limit 1];
            if(categoryList != null && categoryList.size() > 0){
                categoryId = categoryList[0].Id;
            }
            else{
                avnio__Category__c newCat = new avnio__Category__c();
                newCat.name = 'GSX Content';
                insert newCat;
                categoryId = newCat.Id;
            }
            if (categoryId != null){
                List<avnio__responsecategory__c> resCatList = new List<avnio__responsecategory__c>();
                for(Id resId : responseIdFoRInsert){
                    avnio__responsecategory__c resCat = new avnio__responsecategory__c();
                    resCat.avnio__CategoryId__c = categoryId;
                    resCat.avnio__ResponseId__c = resId;
                    resCatList.add(resCat);
                }
                insert resCatList;
            }
        }

        //publish responses both insert and update
        if(responseIdFoUpdate != null && responseIdFoUpdate.size() > 0){
            responseIdFoRInsert.addAll(responseIdFoUpdate);
        }

        Set<String> objectAPINames = new Set<String>{'avnio__responsequestion__c','avnio__alternativeanswer__c','avnio__responsecategory__c','avnio__responsetag__c','deletedRecords'};        
        System.enqueueJob(new RFxIntegrationSchedular.SaveDataQueue(objectAPINames,batchId,yesterdayDate,responseIdFoRInsert));
    }
}