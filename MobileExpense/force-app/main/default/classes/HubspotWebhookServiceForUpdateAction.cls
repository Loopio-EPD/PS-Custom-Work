/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : HubspotWebhookServiceForUpdateAction
* Details : Rest Resource for deal updation in hubspot
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

@RestResource(urlMapping='/updateRequiredRecord/*')
global with sharing class HubspotWebhookServiceForUpdateAction {
    
    @HttpPost
    global static void updateRecord(){
        Map<String,String> stagesMap = HubspotUtility.getStagesMap();
        Map<String,String> fieldsMap = HubspotUtility.getFieldsMap();
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String descr = request.requestBody.toString();

        String dealRecordId,dealStage;
        Integer dealSize;
        JsonParser parser = JSON.createParser(descr);
        
        while (parser.nextToken() != null) {
            if (parser.getText() == fieldsMap.get('dealRecordId')) {
                parser.nextToken();
                dealRecordId = (String)parser.readValueAs(String.class);
            }            
            if (parser.getText() == fieldsMap.get('dealStage')) {
                parser.nextToken();
                dealStage = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('dealSize')) {
                parser.nextToken();
                dealSize = (Integer)parser.readValueAs(Integer.class);
            }
        }
        
        if(dealRecordId != null){
            List<avnio__Project__c> projectListToUpdate = [select id,Based_on_the_RFx_information_what_is_th__c, Hubspot_Deal_Id__c, Hubspot_Deal_stage__c, Hubspot_Deal_size__c from avnio__Project__c where Hubspot_Deal_Id__c =: dealRecordId];
            if(projectListToUpdate != null && projectListToUpdate.size() > 0){
                for(avnio__Project__c project : projectListToUpdate){
                    if(dealStage != null){
                        project.Hubspot_Deal_stage__c = stagesMap.get(dealStage) != null ? stagesMap.get(dealStage) : dealStage;
                    }
                    project.Hubspot_Deal_size__c = dealSize;
                    if(project.Hubspot_Deal_size__c <= 20000) {
                        project.Based_on_the_RFx_information_what_is_th__c = '0-20 k€';
                    }
                    if(project.Hubspot_Deal_size__c > 20000 && project.Hubspot_Deal_size__c <=50000) {
                        project.Based_on_the_RFx_information_what_is_th__c = '20-50 k€';
                    }
                    if(project.Hubspot_Deal_size__c > 50000 && project.Hubspot_Deal_size__c <=100000) {
                        project.Based_on_the_RFx_information_what_is_th__c = '50-100 k€';
                    }
                    if(project.Hubspot_Deal_size__c > 100000) {
                        project.Based_on_the_RFx_information_what_is_th__c = '100+ k€';
                    }
                }
                ProjectTriggerForHubspotController.allowToUpdateDealStage = true;         
                HubspotWithoutSharingClass.updateProjects(projectListToUpdate);
            }
        }
    }
}