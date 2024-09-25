/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : HubspotWebhookService
* Details : Rest Resource for deal creation in hubspot
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

@RestResource(urlMapping='/createRequiredRecord/*')
global with sharing class HubspotWebhookService {
    
    @HttpPost
    global static void createRecord(){
        Map<String,String> stagesMap = HubspotUtility.getStagesMap();
        Map<String,String> sizeMap = HubspotUtility.getSizeMap();
        Map<String,String> fieldsMap = HubspotUtility.getFieldsMap();
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String descr = request.requestBody.toString();

        String dealRecordId,ownerId,dealStage,dealName,sharepointLink,recordType,rfpRecord,rfiRecord,cqRecord,sqRecord,status,winInformation,winReason,dealType,receivedDate;
        Integer dealSize;
        JsonParser parser = JSON.createParser(descr);
        
        while (parser.nextToken() != null) {
            if (parser.getText() == fieldsMap.get('dealRecordId')) {
                parser.nextToken();
                dealRecordId = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('ownerId')) {
                parser.nextToken();
                ownerId = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('dealStage')) {
                parser.nextToken();
                dealStage = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('dealName')) {
                parser.nextToken();
                dealName = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('dealSize')) {
                parser.nextToken();
                dealSize = (Integer)parser.readValueAs(Integer.class);
            }
            if (parser.getText() == fieldsMap.get('sharepointLink')) {
                parser.nextToken();
                sharepointLink = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('recordType')) {
                parser.nextToken();
                recordType = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('rfpRecord')) {
                parser.nextToken();
                rfpRecord = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('rfiRecord')) {
                parser.nextToken();
                rfiRecord = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('cqRecord')) {
                parser.nextToken();
                cqRecord = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('sqRecord')) {
                parser.nextToken();
                sqRecord = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('status')) {
                parser.nextToken();
                status = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('winInformation')) {
                parser.nextToken();
                winInformation = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('winReason')) {
                parser.nextToken();
                winReason = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('dealType')) {
                parser.nextToken();
                dealType = (String)parser.readValueAs(String.class);
            }
            if (parser.getText() == fieldsMap.get('receivedDate')) {
                parser.nextToken();
                receivedDate = (String)parser.readValueAs(String.class);
            }
        }
        
        avnio__Project__c project = new avnio__Project__c();
        project.avnio__ProjectName__c = dealName;
        //project.avnio__DueDate__c = Datetime.now();
        //project.avnio__Description__c = descr;
        project.Hubspot_Deal_owner__c = ownerId;
        //project.Hubspot_Deal_size__c = sizeMap.get(dealSize) != null ? sizeMap.get(dealSize) : dealSize;
        project.Hubspot_Deal_size__c = dealSize;
        if(project.Hubspot_Deal_size__c != null) {
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
        project.Hubspot_Deal_stage__c = stagesMap.get(dealStage) != null ? stagesMap.get(dealStage) : dealStage;
        project.Hubspot_Deal_Id__c = dealRecordId;
        //project.Sharepoint_Link__c = sharepointLink;
        //project.Win_Information__c = winInformation;
        //project.Win_Reason__c = winReason;
        project.Hubspot_Deal_Type__c = dealType;  
        
        if(sharepointLink != null && sharepointLink.length() > 0){
            String sharepointLinkToAdd = '<p><a href="' + sharepointLink + '" target="_blank">' + sharepointLink + '</a></p>';
            project.DMS_Link_RT__c = sharepointLinkToAdd;
        }

        //if(status != null && !String.isBlank(status)){
        //    project.avnio__Status__c = status;
        //}
        //else{
        //    project.avnio__Status__c = 'Request';
        //}

        //Assign record type
        if(recordType == null || String.isBlank(recordType)){
            recordType = 'RFP';
        }
        try{
            Id recordTypeIdToUse = Schema.SObjectType.avnio__project__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            project.recordTypeId = recordTypeIdToUse;
        }
        catch(Exception e){}

        //Attach other related project deals
        if(!recordType.equalsIgnoreCase('RFP') && rfpRecord != null && !String.isBlank(rfpRecord)){
            project.Related_RFP_Record__c = rfpRecord;
        }
        if(!recordType.equalsIgnoreCase('RFI') && rfiRecord != null && !String.isBlank(rfiRecord)){
            project.Related_RFI_Record__c = rfiRecord;
        }
        if(!recordType.equalsIgnoreCase('CQ') && cqRecord != null && !String.isBlank(cqRecord)){
            project.Related_CQ_Record__c = cqRecord;
        }
        if(!recordType.equalsIgnoreCase('SQ') && sqRecord != null && !String.isBlank(sqRecord)){
            project.Related_SQ_Record__c = sqRecord;
        }

        //Assign owner as Queue
        try{
            String queueName = recordType;
            if(recordType.equalsIgnoreCase('RFP') || recordType.equalsIgnoreCase('RFQ')){
                queueName = 'RFx';
            }
            List<Group> queues = [SELECT Id, Name, Type FROM Group WHERE Type = 'Queue' AND Name = :queueName];
            if(queues != null && queues.size() > 0){
                project.ownerId = queues[0].id;
            }
        }
        catch(Exception e1){}

        //Assign created by as hubspot user
        try{
            if(ownerId != null){
                List<User> users = [SELECT id from User WHERE hubspot_owner_id__c =: ownerId];
                if(users != null && users.size() > 0){
                    project.Hubspot_Created_By__c = users[0].id;
                }
            }
        }
        catch(Exception e2){}
        
        if(receivedDate != null){
            try{
                Long timestamp = Long.valueOf(receivedDate);
                DateTime gmtDatetime = DateTime.newInstance(timestamp);
                project.avnio__ReceivedDate__c = date.newinstance(gmtDatetime.year(), gmtDatetime.month(), gmtDatetime.day());
            }
            catch(Exception e3){}
        }

        if(dealRecordId != null){
            updateCompanyOnProject(project,dealRecordId);
        }
    }
    
    @TestVisible
    private static void updateCompanyOnProject(avnio__Project__c project, String hubspotDealId){
        try{        
            hubspot_integration__c integrationSetting = hubspot_integration__c.getOrgDefaults();
            String hubSpotAccessToken, endPoint;
            if(integrationSetting != null){
                hubSpotAccessToken = integrationSetting.Access_Token__c;
                endPoint = integrationSetting.API_Endpoint__c;
                String hubspotOrgURL = integrationSetting.Hubspot_Org_URL__c;
                if(hubspotOrgURL != null){
                    project.Hubspot_Deal_Link__c = hubspotOrgURL+'deal/'+hubspotDealId;
                }
            }
            if(hubSpotAccessToken != null && endPoint != null){
                endPoint = endPoint + 'crm/v3/objects/';
                String endPointForCompanyId = endPoint + 'deals/'+ hubspotDealId +'/associations/Company/?limit=1';
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endPointForCompanyId);
                req.setHeader('Authorization', 'Bearer ' + hubSpotAccessToken);
                req.setHeader('Accept', 'application/json');
                req.setHeader('Content-type', 'application/json');
                req.setMethod('GET');
                Http http = new Http();        
                HttpResponse res = new HttpResponse();
                res = http.send(req);
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                    String companyId;
                    String body = res.getBody();
                    JsonParser parser = JSON.createParser(body);
                    while (parser.nextToken() != null) {
                        if (parser.getText() == 'id') {
                            parser.nextToken();
                            companyId = (String)parser.readValueAs(String.class);
                            break;
                        }
                    }
                    if(companyId != null){
                        List<Account> existingAccounts = [SELECT id, Name, Hubspot_Company_Id__c from Account WHERE Hubspot_Company_Id__c = :companyId];
                        if(existingAccounts != null && existingAccounts.size() > 0){
                            project.avnio__AccountId__c = existingAccounts[0].id;
                            project.Hubspot_Company_Name__c = existingAccounts[0].name;
                            insert project;
                        }
                        else{
                            String propertiesString = '/?properties=name&properties=domain&properties=phone&properties=address&properties=city&properties=state&properties=zip&properties=country&properties=numberofemployees&properties=type';
                            String endPointForCompanyInformation = endPoint + 'companies/'+ companyId + propertiesString +'&limit=1';
                            HttpRequest req1 = new HttpRequest();
                            req1.setEndpoint(endPointForCompanyInformation);
                            req1.setHeader('Authorization', 'Bearer ' + hubSpotAccessToken);
                            req1.setHeader('Accept', 'application/json');
                            req1.setHeader('Content-type', 'application/json');
                            req1.setMethod('GET');
                            Http http1 = new Http();        
                            HttpResponse res1 = new HttpResponse();
                            res1 = http1.send(req1);
                            if(res1.getStatusCode() == 200 || res1.getStatusCode() == 201){
                                String response = res1.getBody();
                                if(response != null && !String.isBlank(response)){
                                    HubspotUtility.Result companyResponse = (HubspotUtility.Result)JSON.deserialize(response, HubspotUtility.Result.class);
                                    if(companyResponse != null){
                                        Account account = HubspotUtility.getAccountFromWrapper(companyResponse);
                                        if(account != null){
                                            insert account;
                                            //project.avnio__AccountId__c = account.id;
                                            project.Hubspot_Company_Name__c = companyResponse.properties.name;
                                        }
                                        insert project;
                                        if(account != null && account.id != null){
                                            updateAccountOnProjectFuture(account.id, project.Id);
                                        }
                                    }
                                    else{
                                        insert project;
                                    }
                                }
                                else{
                                    insert project;
                                }
                            }
                            else{
                                insert project;
                            }
                        }
                    }
                    else{
                        insert project;
                    }
                }
                else{
                    insert project;
                }
            }
            else{
                insert project;
            }
        }catch(Exception e){
            insert project;
        }
        
        //syncProjectIdBackTOHubspot(JSON.serialize(project), hubspotDealId);
    }

    @future(callout=true)
    public static void updateAccountOnProjectFuture(Id accountId, Id projectId){
        List<avnio__Project__c> projectListToUpdate = [select id, avnio__AccountId__c from avnio__Project__c where id =: projectId];
        for(avnio__Project__c project : projectListToUpdate){
            project.avnio__AccountId__c = accountId;
        }
        HubspotWithoutSharingClass.updateProjects(projectListToUpdate);
    }

    // @future(callout=true)
    // private static void syncProjectIdBackTOHubspot(String serializedProject, String dealId){
    //     avnio__Project__c project = (avnio__Project__c)JSON.deserialize(serializedProject, avnio__Project__c.class);
        
    //     hubspot_integration__c integrationSetting = hubspot_integration__c.getOrgDefaults();
    //     String hubSpotAccessToken, endPoint;
    //     if(integrationSetting != null){
    //         hubSpotAccessToken = integrationSetting.Access_Token__c;
    //         endPoint = integrationSetting.API_Endpoint__c;
    //     }
    //     if(hubSpotAccessToken == null || endPoint == null){
    //         throw new ApplicationException('Required parameters cannot be null.');
    //     }
    //     endPoint = endPoint + 'deals/v1/deal/' + dealId;
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint(endPoint);
    //     req.setHeader('Authorization', 'Bearer ' + hubSpotAccessToken);
    //     req.setHeader('Accept', 'application/json');
    //     req.setHeader('Content-type', 'application/json');
    //     req.setMethod('PUT');
    //     PropertiesRequest propertiesRequest = new PropertiesRequest();
    //     propertiesRequest.properties = new List<Properties>();
    //     String projectURL = URL.getSalesforceBaseUrl().toExternalForm();
    //     projectURL = projectURL + '/' + project.Id;
    //     Properties p = new Properties();
    //     p.name = 'projectid';
    //     p.value = projectURL;
    //     propertiesRequest.properties.add(p);
    //     Properties p1 = new Properties();
    //     p1.name = 'project_status';
    //     p1.value = project.avnio__Status__c;
    //     propertiesRequest.properties.add(p1);
    //     Datetime dueDateTime = project.avnio__DueDate__c;
    //     if(dueDateTime != null){
    //         try{
    //             Date dueDate = dueDateTime.dateGMT();
    //             Datetime newDueDateTime = dueDate;
    //             Properties p2 = new Properties();
    //             p2.name = 'rfp_due_date__c';
    //             p2.value = String.valueOf(newDueDateTime.getTime());
    //             propertiesRequest.properties.add(p2);
    //         }
    //         catch(Exception e){}
    //     }
    //     System.debug(JSON.serialize(propertiesRequest));
    //     req.setBody(JSON.serialize(propertiesRequest));
    //     Http http = new Http();        
    //     HttpResponse res = new HttpResponse();
    //     res = http.send(req);
    //     if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
            
    //     }
    // }
    
    // public class PropertiesRequest{
    // 	public List<Properties> properties;
    // }
    // public class Properties{
    //     public String name;
    //     public String value;
    // }
    
}