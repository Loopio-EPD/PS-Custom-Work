public with sharing class RequestContentController {
	@AuraEnabled
    public static ResponseWrapper savesyncrequest(String questionvalue, String needvalue, String priorityvalue){
        ResponseWrapper responseWrapper = new ResponseWrapper();
        responseWrapper.isSuccess = false;
        try{
            avnio__LibrarySyncRequest__c syncreq = new avnio__LibrarySyncRequest__c();
            syncreq.avnio__ChangesRequested__c = 'Request Content';
            syncreq.avnio__Question__c = questionvalue;
            syncreq.Priority__c = priorityvalue;
            syncreq.Reason_for_request__c = needvalue;
            insert syncreq;
            responseWrapper.recordId = syncreq.Id;
            responseWrapper.isSuccess = true;
        }
        catch(Exception e){}
        return responseWrapper;
    }
    
    public with sharing class ResponseWrapper{
        @AuraEnabled public String recordId;
        @AuraEnabled public Boolean isSuccess;
    }
}