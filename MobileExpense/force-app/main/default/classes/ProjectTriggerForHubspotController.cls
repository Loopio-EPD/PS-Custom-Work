/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : ProjectTriggerForHubspotController
* Details : Trigger handler class for projecttrigger
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

public with sharing class ProjectTriggerForHubspotController {

    public static Map<String,String> fieldsMap = HubspotUtility.getFieldsMap();
    public static boolean allowToUpdateDealStage = false;

    public static void onInsertProjectBefore(List<avnio__Project__c> newProjectList){
        for(avnio__Project__c newProject : newProjectList){
            if(newProject.avnio__ReceivedDate__c == null){
                newProject.avnio__ReceivedDate__c = System.today();
            }
        }
    }
    
    public static void onUpdateProjectBefore(Map<id,avnio__Project__c> oldProjectMap, List<avnio__Project__c> newProjectList){
        for(avnio__Project__c newProject : newProjectList){
            //Deal Stage changed
            if(!allowToUpdateDealStage){
                String oldStage = oldProjectMap.get(newProject.id) != null ? oldProjectMap.get(newProject.id).Hubspot_Deal_stage__c : null;
                if(newProject.Hubspot_Deal_stage__c == null){
                    if(oldStage != null){
                        newProject.addError('You cannot change deal stage manually.');
                    }
                }
                else{
                    if(oldStage == null){
                        newProject.addError('You cannot change deal stage manually.');
                    }
                    else if(!oldStage.equalsIgnoreCase(newProject.Hubspot_Deal_stage__c)){
                        newProject.addError('You cannot change deal stage manually.');
                    }
                }
            }
        }
    }

    public static void onInsertProjectAfter(List<avnio__Project__c> newProjectList){

        List<PropertiesRequest> propertiesRequestList = new List<PropertiesRequest>();
        Map<String,String> recordTypeTOHubspotField = getRecordTypeMap();

        for(avnio__Project__c newProject : newProjectList){
            if(newProject.Hubspot_Deal_Id__c != null){
                PropertiesRequest propertiesRequest = new PropertiesRequest();
                propertiesRequest.objectId = newProject.Hubspot_Deal_Id__c;
                propertiesRequest.properties = new List<Properties>();
                if(newProject.avnio__RecordType__c != null && recordTypeTOHubspotField.containsKey(newProject.avnio__RecordType__c)){
                    String projectURL = System.Url.getOrgDomainUrl().toExternalForm();
                    projectURL = projectURL + '/' + newProject.Id;
                    Properties p = new Properties();
                    p.name = recordTypeTOHubspotField.get(newProject.avnio__RecordType__c);
                    p.value = projectURL;
                    propertiesRequest.properties.add(p);
                }
                Properties p1 = new Properties();
                p1.name = fieldsMap.get('status');
                p1.value = newProject.avnio__Status__c;
                propertiesRequest.properties.add(p1);
                Datetime dueDateTime = newProject.avnio__DueDate__c;
                if(dueDateTime != null){
                    try{
                        Date dueDate = dueDateTime.dateGMT();
                        Datetime newDueDateTime = dueDate;
                        Properties p2 = new Properties();
                        p2.name = fieldsMap.get('dueDate');
                        p2.value = String.valueOf(newDueDateTime.getTime());
                        propertiesRequest.properties.add(p2);
                    }
                    catch(Exception e){}
                }
                Properties p3 = new Properties();
                p3.name = fieldsMap.get('createAvnioProject');
                p3.value = null;
                propertiesRequest.properties.add(p3);

                propertiesRequestList.add(propertiesRequest);
            }
        }

        if(propertiesRequestList.size() > 0 && !system.isFuture() && !system.isBatch()){
            makeCallout(JSON.serialize(propertiesRequestList),'deals/v1/batch-async/update');
        }

        //Attach newly created project to related project deals
        try{
            Set<String> hubspotDealIdsSet = new Set<String>();
            Map<String,Map<String,Id>> hubspotIdToProjectRecordMap = new Map<String,Map<String,Id>> ();
            for(avnio__Project__c newProjectInserted : newProjectList){
                if(newProjectInserted.Hubspot_Deal_Id__c != null && newProjectInserted.avnio__RecordType__c != null){
                    Map<String,Id> hubspotIdTorecordIdMap = hubspotIdToProjectRecordMap.get(newProjectInserted.Hubspot_Deal_Id__c) != null ? hubspotIdToProjectRecordMap.get(newProjectInserted.Hubspot_Deal_Id__c) : new Map<String,id>();
                    hubspotIdTorecordIdMap.put(newProjectInserted.avnio__RecordType__c, newProjectInserted.id);
                    hubspotIdToProjectRecordMap.put(newProjectInserted.Hubspot_Deal_Id__c, hubspotIdTorecordIdMap);
                    hubspotDealIdsSet.add(newProjectInserted.Hubspot_Deal_Id__c);
                }
            }
            if(hubspotDealIdsSet.size() > 0){
                List<avnio__Project__c> existingProjectsForDeal = [select id, Hubspot_Deal_Id__c, avnio__RecordType__c, Related_RFI_Record__c, Related_RFP_Record__c, Related_CQ_Record__c, Related_SQ_Record__c from avnio__Project__c where Hubspot_Deal_Id__c IN :hubspotDealIdsSet];
                if(existingProjectsForDeal != null && existingProjectsForDeal.size() > 0){
                    String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
                    baseUrl = baseUrl + '/';
                    for(avnio__Project__c existingProject : existingProjectsForDeal){
                        if(existingProject.Hubspot_Deal_Id__c != null && hubspotIdToProjectRecordMap.get(existingProject.Hubspot_Deal_Id__c) != null){
                            String recordType = existingProject.avnio__RecordType__c;
                            if(!recordType.equalsIgnoreCase('RFP') && hubspotIdToProjectRecordMap.get(existingProject.Hubspot_Deal_Id__c).get('RFP') != null){
                                existingProject.Related_RFP_Record__c = baseUrl + hubspotIdToProjectRecordMap.get(existingProject.Hubspot_Deal_Id__c).get('RFP');
                            }
                            if(!recordType.equalsIgnoreCase('RFI') && hubspotIdToProjectRecordMap.get(existingProject.Hubspot_Deal_Id__c).get('RFI') != null){
                                existingProject.Related_RFI_Record__c = baseUrl + hubspotIdToProjectRecordMap.get(existingProject.Hubspot_Deal_Id__c).get('RFI');
                            }
                            if(!recordType.equalsIgnoreCase('CQ') && hubspotIdToProjectRecordMap.get(existingProject.Hubspot_Deal_Id__c).get('CQ') != null){
                                existingProject.Related_CQ_Record__c = baseUrl + hubspotIdToProjectRecordMap.get(existingProject.Hubspot_Deal_Id__c).get('CQ');
                            }
                            if(!recordType.equalsIgnoreCase('SQ') && hubspotIdToProjectRecordMap.get(existingProject.Hubspot_Deal_Id__c).get('SQ') != null){
                                existingProject.Related_SQ_Record__c = baseUrl + hubspotIdToProjectRecordMap.get(existingProject.Hubspot_Deal_Id__c).get('SQ');
                            }
                        }
                    }
                    HubspotWithoutSharingClass.updateProjects(existingProjectsForDeal);
                }
            }
        }
        catch(Exception upsertException){}
        if(!system.isFuture() && !system.isBatch()) {
            sendEmails(JSON.serialize(newProjectList));  
        }      
    }

    public static void onUpdateProjectAfter(Map<id,avnio__Project__c> oldProjectMap, List<avnio__Project__c> newProjectList){

        List<PropertiesRequest> propertiesRequestList = new List<PropertiesRequest>();

        for(avnio__Project__c newProject : newProjectList){
            if(newProject.Hubspot_Deal_Id__c != null){
                PropertiesRequest propertiesRequest = new PropertiesRequest();
                propertiesRequest.objectId = newProject.Hubspot_Deal_Id__c;
                propertiesRequest.properties = new List<Properties>();
                Boolean addToList = false;

                //Status changed
                String oldStatus = oldProjectMap.get(newProject.id) != null ? oldProjectMap.get(newProject.id).avnio__Status__c : null;
                Properties p1 = new Properties();
                p1.name = fieldsMap.get('status');
                p1.value = newProject.avnio__Status__c;
                propertiesRequest.properties.add(p1);

                if(newProject.avnio__Status__c == null){
                    if(oldStatus != null){
                        addToList = true;
                    }
                }
                else{
                    if(oldStatus == null){
                        addToList = true;
                    }
                    else if(!oldStatus.equalsIgnoreCase(newProject.avnio__Status__c)){
                        addToList = true;
                    }
                }

                if(addToList){
                    propertiesRequestList.add(propertiesRequest); 
                }
            }
        }

        if(propertiesRequestList.size() > 0 && !system.isFuture() && !system.isBatch()){
            makeCallout(JSON.serialize(propertiesRequestList),'deals/v1/batch-async/update');
        }
    }
    
    
    @future(callout=true)
    public static void makeCallout(String jsonRequestBody, String extendedEndpoint){
        try{
            hubspot_integration__c integrationSetting = hubspot_integration__c.getOrgDefaults();
            String hubSpotAccessToken, endPoint;
            if(integrationSetting != null){
                hubSpotAccessToken = integrationSetting.Access_Token__c;
                endPoint = integrationSetting.API_Endpoint__c;
            }
            if(hubSpotAccessToken == null || endPoint == null){
                throw new ApplicationException('Required parameters cannot be null.');
            }
            endPoint = endPoint + extendedEndpoint;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setHeader('Authorization', 'Bearer ' + hubSpotAccessToken);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-type', 'application/json');
            req.setMethod('POST');
            
            req.setBody(jsonRequestBody);
            Http http = new Http();        
            HttpResponse res = new HttpResponse();
            res = http.send(req);
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202){
                
            }
        }
        catch(Exception callException){}
    }

    @future(callout=true)
    public static void sendEmails(String serializedProjects){
        try{
            List<avnio__Project__c> projectsList = (List<avnio__Project__c>)JSON.deserialize(serializedProjects, List<avnio__Project__c>.class);
            if(projectsList != null && projectsList.size() > 0){
                String emailTemplateName = 'Project Created Notification';
                EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE name =:emailTemplateName];
                List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                Set<Id> userIdsToMail = new Set<Id>();
                OrgWideEmailAddress owea;
                try{
                    String orgWideEmailName = System.Label.Avnio_Org_Wide_Email_Name;
                    List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
                    oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:orgWideEmailName];
                    if(oweaList != null && oweaList.size() > 0){
                        owea = oweaList[0];
                    }
                }
                catch(Exception emailExc){}
                for(avnio__Project__c singleProject : projectsList){
                    //userId           
                    if(singleProject.Hubspot_Created_By__c != null && !userIdsToMail.contains(singleProject.Hubspot_Created_By__c)){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                        mail.setTargetObjectId(singleProject.Hubspot_Created_By__c);
                        //Template ID
                        mail.setTemplateId(et.id); 
                        //Project Id
                        mail.setWhatId(singleProject.id); 
                        mail.setBccSender(false); 
                        mail.setUseSignature(false); 
                        mail.setSaveAsActivity(false); 
                        if(owea != null){
                            mail.setOrgWideEmailAddressId(owea.Id);
                        }
                        emailMessageList.add(mail);
                        userIdsToMail.add(singleProject.Hubspot_Created_By__c);
                    }
                    try{
                        if(singleProject.ownerId != null && (singleProject.Hubspot_Created_By__c == null || (singleProject.Hubspot_Created_By__c != null && singleProject.Hubspot_Created_By__c != singleProject.ownerId))){
                            String sobjectType = singleProject.ownerId.getSObjectType().getDescribe().getName();
                            if(sobjectType != null && sobjectType.equalsIgnoreCase('Group')){
                                Id queueId = singleProject.ownerId;
                                List<GroupMember> queueMembers = [SELECT UserOrGroupId, GroupId,Group.Type FROM GroupMember WHERE GroupId = :queueId AND Group.Type = 'Queue'];
                                if(queueMembers != null && queueMembers.size() > 0){
                                    for(GroupMember gm : queueMembers){
                                        if(gm.UserOrGroupId != null && gm.UserOrGroupId.getSObjectType().getDescribe().getName().equalsIgnoreCase('User') && !userIdsToMail.contains(gm.UserOrGroupId)){
                                            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage(); 
                                            mail1.setTargetObjectId(gm.UserOrGroupId);
                                            //Template ID
                                            mail1.setTemplateId(et.id); 
                                            //Project Id
                                            mail1.setWhatId(singleProject.id); 
                                            mail1.setBccSender(false); 
                                            mail1.setUseSignature(false); 
                                            mail1.setSaveAsActivity(false); 
                                            if(owea != null){
                                                mail1.setOrgWideEmailAddressId(owea.Id);
                                            }
                                            emailMessageList.add(mail1);
                                            userIdsToMail.add(gm.UserOrGroupId);
                                        }
                                        else if(gm.UserOrGroupId != null && gm.UserOrGroupId.getSObjectType().getDescribe().getName().equalsIgnoreCase('Group')){
                                            Id groupId = gm.UserOrGroupId;
                                            List<GroupMember> groupMembers = [SELECT UserOrGroupId, GroupId,Group.Type FROM GroupMember WHERE GroupId = :groupId AND Group.Type = 'Regular'];
                                            if(groupMembers != null && groupMembers.size() > 0){
                                                for(GroupMember gmem : groupMembers){
                                                    if(gmem.UserOrGroupId != null && gmem.UserOrGroupId.getSObjectType().getDescribe().getName().equalsIgnoreCase('User') && !userIdsToMail.contains(gmem.UserOrGroupId)){
                                                        Messaging.SingleEmailMessage mail3 = new Messaging.SingleEmailMessage(); 
                                                        mail3.setTargetObjectId(gmem.UserOrGroupId);
                                                        //Template ID
                                                        mail3.setTemplateId(et.id); 
                                                        //Project Id
                                                        mail3.setWhatId(singleProject.id); 
                                                        mail3.setBccSender(false); 
                                                        mail3.setUseSignature(false); 
                                                        mail3.setSaveAsActivity(false); 
                                                        if(owea != null){
                                                            mail3.setOrgWideEmailAddressId(owea.Id);
                                                        }
                                                        emailMessageList.add(mail3);
                                                        userIdsToMail.add(gmem.UserOrGroupId);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else if(sobjectType != null && sobjectType.equalsIgnoreCase('User') && !userIdsToMail.contains(singleProject.ownerId)){
                                Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage(); 
                                mail2.setTargetObjectId(singleProject.ownerId);
                                //Template ID
                                mail2.setTemplateId(et.id); 
                                //Project Id
                                mail2.setWhatId(singleProject.id); 
                                mail2.setBccSender(false); 
                                mail2.setUseSignature(false); 
                                mail2.setSaveAsActivity(false); 
                                if(owea != null){
                                    mail2.setOrgWideEmailAddressId(owea.Id);
                                }
                                emailMessageList.add(mail2);
                                userIdsToMail.add(singleProject.ownerId);
                            }  
                        }
                    }
                    catch(Exception e){}
                }
                if(emailMessageList.size() > 0){
                    Messaging.sendEmail(emailMessageList);
                }
            }
        }
        catch(Exception callException){}
    }
    
    private static Map<String,String> getRecordTypeMap(){
        Map<String,String> recordTypeMap = new Map<String,String>();
        recordTypeMap.put('RFP',fieldsMap.get('rfpRecord'));
        recordTypeMap.put('RFI',fieldsMap.get('rfiRecord'));
        recordTypeMap.put('CQ',fieldsMap.get('cqRecord'));
        recordTypeMap.put('SQ',fieldsMap.get('sqRecord'));
        return recordTypeMap;
    }

    public class PropertiesRequest{
        public String objectId;
        public List<Properties> properties;
    }
   
    public class Properties{
        public String name;
        public String value;
    }
}