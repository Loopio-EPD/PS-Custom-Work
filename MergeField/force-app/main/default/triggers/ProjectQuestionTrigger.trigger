trigger ProjectQuestionTrigger on avnio__ProjectQuestion__c (after update) 
{
    Map<string, string> responseKeywordMap = new Map<string,string> ();
    Map<string, string> responseKeywordToValueMap = new Map<string,string> ();
    Map<Id, avnio__ProjectQuestion__c> projectQuestionMap = new Map<Id,avnio__ProjectQuestion__c> ();
    List<Response_Merge_Field_Mapping__c> responseMergeFieldMappinglist = new List<Response_Merge_Field_Mapping__c> ();
    List<avnio__ProjectQuestion__c> PQLIST = new List<avnio__ProjectQuestion__c> ();
    List<avnio__ProjectQuestion__c> projectQuestionList = new List<avnio__ProjectQuestion__c> ();
    List<avnio__ProjectQuestion__c> projectQuestionListToUpdate = new List<avnio__ProjectQuestion__c>  ();
    String [] fieldarray = new String [] {};
    Set<String> fieldAPINameSet = new Set<String> ();
    
    
    responseMergeFieldMappinglist = [SELECT Keyword__c,Merge_Field_API_Name__c,Value__c from Response_Merge_Field_Mapping__c where Keyword__c != null];
    for(Response_Merge_Field_Mapping__c mergefieldMapping : responseMergeFieldMappinglist)
    {
        if(mergefieldMapping.Merge_Field_API_Name__c != null){
            responseKeywordMap.put(mergefieldMapping.Keyword__c, mergefieldMapping.Merge_Field_API_Name__c);
            fieldAPINameSet.add(mergefieldMapping.Merge_Field_API_Name__c);
        } 
        if(mergefieldMapping.Value__c != null){
            responseKeywordToValueMap.put(mergefieldMapping.Keyword__c, mergefieldMapping.Value__c);
        }   
    }
    
    
    for(String field : fieldAPINameSet) {
        fieldarray.add(field);
    }
    PQLIST = Trigger.new; 
    
    string query = 'select id,avnio__Answer__c,'+string.join(fieldarray,',')+ ' from avnio__ProjectQuestion__c where id IN:PQLIST';
    projectQuestionList = Database.query(query);

    projectQuestionMap = new Map<Id, avnio__ProjectQuestion__c>(projectQuestionList);
    
    
    for (avnio__ProjectQuestion__c pq: trigger.new) 
    {     
        if( String.isNotBlank(pq.avnio__Answer__c) && (pq.avnio__Answer__c != Trigger.oldMap.get( pq.Id ).avnio__Answer__c))
        {           
            
            if(pq.avnio__AnswerMethod__c.contains('Auto Responded')|| pq.avnio__AnswerMethod__c.contains('Suggested from Library'))
            {
                avnio__ProjectQuestion__c PQToUpdate = projectQuestionMap.get(pq.Id);
                sObject PQToUpdateclone = projectQuestionMap.get(pq.Id);
                Boolean isupdate = false;
                
                for(String mergekeyword : responseKeywordMap.keyset())
                {
                    
                    if(pq.avnio__Answer__c.CONTAINS(mergekeyword))
                    {
                        isupdate = true;
                        String mergefieldAPIName = responseKeywordMap.get(mergekeyword);
                        String fieldAPIName = mergefieldAPIName;
                        if(!fieldAPIName.contains('__r')) {
                            
                            PQToUpdate.avnio__Answer__c = PQToUpdate.avnio__Answer__c.replace(mergekeyword,(string)PQToUpdateclone.get(fieldAPIName));
                        } else {
                            Sobject parentsObject = PQToUpdateclone;
                            while(fieldAPIName.contains('__r')) {
                              
                                List<string> fieldAPIArray = fieldAPIName.split('\\.');
                                parentsObject = parentsObject.getSObject(fieldAPIArray[0]);
                                if(fieldAPIArray[1].indexOf('__r') != -1) {
                                    fieldAPIArray.remove(0);  
                                    fieldAPIName = string.join(fieldAPIArray,'.');
                                } else {
                                
                                    PQToUpdate.avnio__Answer__c = PQToUpdate.avnio__Answer__c.replace(mergekeyword,(string)parentsObject.get(fieldAPIArray[1]));
                                    
                                    fieldAPIName = fieldAPIArray[1];
                                }
                            }
                        }
            
                    }
                }

                for(String valuekeyword : responseKeywordToValueMap.keyset()){
                    if(pq.avnio__Answer__c.CONTAINS(valuekeyword)){
                        isupdate = true;
                        PQToUpdate.avnio__Answer__c = PQToUpdate.avnio__Answer__c.replaceAll(valuekeyword,responseKeywordToValueMap.get(valuekeyword));
                    }
                }
                
                if(isupdate) {
                    projectQuestionListToUpdate.add(PQToUpdate);
                }
            }
        }
        if(projectQuestionListToUpdate != null && projectQuestionListToUpdate.size() > 0) {
            update projectQuestionListToUpdate;
        }
    }
}