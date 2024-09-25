public with sharing class ExternalScripts {
    public static void updateProjectQuestions(String projectId){
        List<avnio__ProjectQuestion__c> projequestionlist = new List<avnio__ProjectQuestion__c> ();
        projequestionlist = [select id,avnio__Question__c,avnio__Answer__c from avnio__ProjectQuestion__c where avnio__ProjectId__c =:projectId];
        Set<id> responseidset = new Set<id> ();
        for(avnio__ProjectQuestion__c pq : projequestionlist) {
            responseidset.add(pq.avnio__Question__c);
        }
        Map<id,avnio__Response__c> responseMap = new Map<id,avnio__Response__c> ();
        responseMap = new Map<id,avnio__Response__c> ([select id,avnio__Answer__c  from avnio__Response__c where ID IN:responseidset]);
        for(avnio__ProjectQuestion__c pq : projequestionlist) {
            String answer = responseMap.get(pq.avnio__Question__c).avnio__Answer__c;
            if(answer != null && answer.contains('/img>')){
                Integer imgCount = answer.countMatches('/img>');
                String existingAnswer = answer;
                Map<String,String> stringToReplaceMap = new Map<String,String>();
                for(Integer i = 0 ; i < imgCount ; i++){
                    String toReplace = existingAnswer.subStringBetween('<img','/img>');
                    existingAnswer = existingAnswer.remove('<img'+toReplace+'/img>');
                    if(toReplace.contains('src="')){
                        String urlToAdd = toReplace.subStringBetween('src="','"').replaceAll('&amp;','&');
                        if(toReplace.contains('alt=""')){
                            String repString = toReplace.replace('alt=""', 'alt="'+ urlToAdd +'"');
                            stringToReplaceMap.put(toReplace,repString);
                        }
                    }
                }
                for(String key : stringToReplaceMap.keySet()){
                    if(answer.contains(key)){
                        answer = answer.replace(key,stringToReplaceMap.get(key));
                    }
                }
            }
            pq.avnio__Answer__c = answer;
        }
        update projequestionlist;
    }
}