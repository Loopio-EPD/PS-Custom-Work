public with sharing class RetrieveCompaniesSchedular implements Schedulable,Database.AllowsCallouts {

    public void execute(SchedulableContext sc) {
        makeCalloutToRetrieveAccounts();
    }
    
    @future(callout=true)
    public static void makeCalloutToRetrieveAccounts(){
        Datetime dateTimeNow = System.now();
        Date dateNow = dateTimeNow.dateGMT();
        dateNow = dateNow.addDays(-1);
        Datetime newDateTime = dateNow;
        String newDateTimeUnix = String.valueOf(newDateTime.getTime());
        hubspot_integration__c integrationSetting = hubspot_integration__c.getOrgDefaults();
        String hubSpotAccessToken, endPoint;
        Boolean existingRetrived;
        if(integrationSetting != null){
            hubSpotAccessToken = integrationSetting.Access_Token__c;
            endPoint = integrationSetting.API_Endpoint__c;
            existingRetrived = integrationSetting.Existing_Companies_Retrieved__c;
        }
        if(hubSpotAccessToken != null && endPoint != null && existingRetrived != null){
            String propertiesString = '"properties": [ "name","domain","phone","address","city","state","zip","country","numberofemployees","type" ]';
            endPoint = endPoint + 'crm/v3/objects/companies/search';
            String reqBody = '';
            if(existingRetrived){
                reqBody = '{"filterGroups":[{"filters":[{"propertyName":"createdate","operator":"GTE","value":"'+newDateTimeUnix+'"}]}],'+propertiesString+'}';
            }
            else{
                reqBody = '{'+propertiesString+'}';
            }
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setHeader('Authorization', 'Bearer ' + hubSpotAccessToken);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-type', 'application/json');
            req.setMethod('POST');
            req.setBody(reqBody);
            Http http = new Http();        
            HttpResponse res = new HttpResponse();
            res = http.send(req);
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                String response = res.getBody();
                if(response != null && !String.isBlank(response)){
                    try{
                        HubspotUtility.CompaniesResponse companiesResponse = (HubspotUtility.CompaniesResponse)JSON.deserialize(response, HubspotUtility.CompaniesResponse.class);
                        if(companiesResponse != null && companiesResponse.results != null && companiesResponse.results.size() > 0){
                            List<HubspotUtility.Result> responseResults = companiesResponse.results;
                            System.enqueueJob(new HubspotUtility.CreateAccountsQueue(responseResults));
                        }
                    }
                    catch(Exception e){}
                }
            }
        }
    }
}