public with sharing class ProcessCompaniesResponseBatch implements Database.Batchable<HubspotUtility.Result>, Database.Stateful{

    private List<HubspotUtility.Result> responseResults;
    
    public ProcessCompaniesResponseBatch(List<HubspotUtility.Result> responseResults) {
        this.responseResults = responseResults;
    }
    
    public Iterable<HubspotUtility.Result> start(Database.BatchableContext BC){
        return responseResults;
    }
    
    public void execute(Database.BatchableContext info, List<HubspotUtility.Result> resultList) {

        Set<String> externalIds = new Set<String>();
        Map<String,Id> externalKeyToIdMap = new Map<String,Id>();
        for(HubspotUtility.Result singleResult : resultList){
            if(singleResult.id != null){
                externalIds.add(singleResult.id);
            }
        }
        List<Account> existingAccounts = [SELECT id, Hubspot_Company_Id__c from Account WHERE Hubspot_Company_Id__c IN :externalIds];
        for(Account existingAcc : existingAccounts){
            externalKeyToIdMap.put(existingAcc.Hubspot_Company_Id__c ,existingAcc.Id);
        }


        if(resultList != null && resultList.size() > 0){
            List<Account> accountList = new List<Account>();
            for(HubspotUtility.Result singleResult : resultList){
                Account account = HubspotUtility.getAccountFromWrapper(singleResult);
                if(account != null){
                    if(singleResult.id != null && externalKeyToIdMap.keySet().contains(singleResult.id)){
                        account.Id = externalKeyToIdMap.get(singleResult.id);
                    }
                    accountList.add(account);
                }
            }
            Database.upsert(accountList , false);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}