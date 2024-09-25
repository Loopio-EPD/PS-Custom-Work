public with sharing class RetriveCategoriesAndTagsBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String queryStr = 'select id, name, Categories__c, Tags__c ,(select id, name, avnio__CategoryId__c,avnio__CategoryId__r.name, avnio__ResponseId__c from avnio__ResponseCategories__r), '+
                            '(select id, name, avnio__TagId__c, avnio__TagId__r.name, avnio__ResponseId__c from avnio__ResponseTags__r) from avnio__Response__c';
        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext BC, List<avnio__Response__c> scope) {
        if(scope == null) return;

        try{
            Map<Id,List<String>> resToCategoriesMap = new Map<Id,List<String>>();
            Map<Id,List<String>> resToTagsMap = new Map<Id,List<String>>();
            for(avnio__Response__c resobj : scope) {

                //for Categories
                List<String> categoriesToAdd = new List<String>();
                if(resobj.Categories__c != null && !String.isEmpty(resobj.Categories__c)){
                    try{
                        categoriesToAdd = resobj.Categories__c.split(',');
                    }catch(Exception e1){}
                }
                if (resobj.avnio__ResponseCategories__r != null && !resobj.avnio__ResponseCategories__r.isEmpty()) {
                    for(avnio__ResponseCategory__c responseCategory : resobj.avnio__ResponseCategories__r){
                        if(responseCategory.avnio__CategoryId__c != null && responseCategory.avnio__CategoryId__r.name != null && !String.isEmpty(responseCategory.avnio__CategoryId__r.name) && !categoriesToAdd.contains(responseCategory.avnio__CategoryId__r.name)){
                            categoriesToAdd.add(responseCategory.avnio__CategoryId__r.name);
                        }
                    }
                }
                if(!categoriesToAdd.isEmpty()){
                    String categoriesCommaSeparated = String.join(categoriesToAdd, ',');
                    resobj.Categories__c = categoriesCommaSeparated;
                }

                //for Tags
                List<String> tagsToAdd = new List<String>();
                if(resobj.Tags__c != null && !String.isEmpty(resobj.Tags__c)){
                    try{
                        tagsToAdd = resobj.Tags__c.split(',');
                    }catch(Exception e2){}
                }
                if (resobj.avnio__ResponseTags__r != null && !resobj.avnio__ResponseTags__r.isEmpty()) {
                    for(avnio__ResponseTag__c responseTag : resobj.avnio__ResponseTags__r){
                        if(responseTag.avnio__TagId__c != null && responseTag.avnio__TagId__r.name != null && !String.isEmpty(responseTag.avnio__TagId__r.name) && !tagsToAdd.contains(responseTag.avnio__TagId__r.name)){
                            tagsToAdd.add(responseTag.avnio__TagId__r.name);
                        }
                    }
                }
                if(!tagsToAdd.isEmpty()){
                    String tagsCommaSeparated = String.join(tagsToAdd, ',');
                    resobj.Tags__c = tagsCommaSeparated;
                }
            }

            Database.upsert(scope);

        }catch (Exception e){}
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}