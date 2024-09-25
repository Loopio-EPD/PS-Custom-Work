/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : HubspotUtility
* Details : Utility class for HubspotWebhookService and HubspotWebhookServiceForUpdateAction
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

public with sharing class HubspotUtility {

    public static Account getAccountFromWrapper(HubspotUtility.Result singleResult){
        Account account = new Account();
        account.Hubspot_Company_Id__c = singleResult.id;
        account.Name = singleResult.properties.name;
        account.Website = singleResult.properties.domain;
        account.Phone = singleResult.properties.phone;
        account.ShippingStreet = singleResult.properties.address;
        account.BillingStreet = singleResult.properties.address;
        account.ShippingCity = singleResult.properties.city;
        account.BillingCity = singleResult.properties.city;
        account.ShippingState = singleResult.properties.state;
        account.BillingState = singleResult.properties.state;
        account.ShippingPostalCode = singleResult.properties.zip;
        account.BillingPostalCode = singleResult.properties.zip;
        account.ShippingCountry = singleResult.properties.country;
        account.BillingCountry = singleResult.properties.country;
        if(singleResult.properties.numberofemployees != null){
            account.NumberOfEmployees = Integer.valueOf(singleResult.properties.numberofemployees);
        }
        account.Hubspot_Company_Type__c = singleResult.properties.type;
        return account;
    }

    public static Map<String,String> getStagesMap(){
        Map<String,String> stagesMap = new Map<String,String>();
        List<Hubspot_Deal_Stage__mdt> stageObjects = [select id, MasterLabel, Deal_Stage__c from Hubspot_Deal_Stage__mdt];
        if(stageObjects != null && !stageObjects.isEmpty()){
            for(Hubspot_Deal_Stage__mdt stage : stageObjects) {
                stagesMap.put(stage.MasterLabel, stage.Deal_Stage__c);
            }
        }
        return stagesMap;
    }

    public static Map<String,String> getSizeMap(){
        Map<String,String> sizesMap = new Map<String,String>();
        List<Hubspot_Deal_Size__mdt> sizeObjects = [select id, MasterLabel, Size_With_Description__c from Hubspot_Deal_Size__mdt];
        if(sizeObjects != null && !sizeObjects.isEmpty()){
            for(Hubspot_Deal_Size__mdt size : sizeObjects) {
                sizesMap.put(size.MasterLabel, size.Size_With_Description__c);
            }
        }
        return sizesMap;
    }

    public static Map<String,String> getFieldsMap(){
        Map<String,String> fieldsMap = new Map<String,String>();
        List<Hubspot_Field_Mapping__mdt> fieldObjects = [select id, MasterLabel, Hubspot_Field_Name__c from Hubspot_Field_Mapping__mdt];
        if(fieldObjects != null && !fieldObjects.isEmpty()){
            for(Hubspot_Field_Mapping__mdt field : fieldObjects) {
                fieldsMap.put(field.MasterLabel, field.Hubspot_Field_Name__c);
            }
        }
        return fieldsMap;
    }

	public with sharing class CreateAccountsQueue implements Queueable {
        List<HubspotUtility.Result> responseResults;
        
        public CreateAccountsQueue(List<HubspotUtility.Result> responseResults) {
            this.responseResults = responseResults;
        }
        public void execute(QueueableContext context) {
            try {
                //ProcessCompaniesResponseBatch processCompaniesResponseBatch = new ProcessCompaniesResponseBatch(responseResults);
                //Id jobId = Database.executeBatch(processCompaniesResponseBatch,200);
            }
            catch(Exception e) {}
        }
    }

    public class CompaniesResponse{
        public Integer total;
        public List<Result> results;
    }
    
    public class Result{
        public String id;
        public Properties properties;
		public String createdAt;
		public String updatedAt;
		public Boolean archived;
    }
    
    public class Properties{
        public String address;
		public String city;
		public String country;
		public String createdate;
		public String domain;
		public String hs_lastmodifieddate;
		public String hs_object_id;
		public String name;
		public String numberofemployees;
		public String phone;
		public String state;
		public String zip;
        public String type;
    }
}