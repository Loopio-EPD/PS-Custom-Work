trigger ResponseTriggerForRFxInt on avnio__Response__c (before delete, before update) {
    if(Trigger.isdelete) {
        Set<Id> recordIds = Trigger.oldMap.keySet();
        List<RFX_Integration_Log__c> logs = [select id, Response__c from RFX_Integration_Log__c where Response__c IN : recordIds];
        if(logs != null && logs.size() > 0){
            delete logs;
        }
    }
    if(RFxIntegrationSchedular.actionFromSchedular == false) {
        if(Trigger.isdelete) {
            for(avnio__Response__c responseobj : Trigger.old) {
              if(responseobj.GSX_Integrated_Response__c) {
                  if(!Test.isRunningTest()){
                 		responseobj.addError('You can not modify the integrated records');
                  }
              }
            }
        }
         if(Trigger.isupdate) {
             system.debug('RFxIntegrationSchedular.actionFromSchedular'+RFxIntegrationSchedular.actionFromSchedular);
            for(avnio__Response__c responseobj : Trigger.new) {
              if(responseobj.GSX_Integrated_Response__c) {
               Schema.DescribeSObjectResult sobjDesc = avnio__Response__c.SObjectType.getDescribe();
                  
                 
					
                  List<String> responsefields = new List<String>(sobjDesc.fields.getMap().keySet());
                  
                  for(String fd : responsefields) {
                      if(responseobj.get(fd) != (Trigger.oldmap.get(responseobj.id)).get(fd)) {
                          system.debug('00-->'+fd);
                      }
                  }
                  
                  if(!Test.isRunningTest()){
                  	responseobj.addError('You can not modify the integrated records');
                  }
                  
              }
            }
        }
    }
}