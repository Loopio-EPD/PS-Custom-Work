public with sharing class ReplaceLinksBatch implements Database.Batchable<sObject> {
    
    private String objectAPIName;

    public ReplaceLinksBatch(String objectAPIName) {
        this.objectAPIName = objectAPIName;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id,avnio__Answer__c,Links_Formatting_Required__c  from ' + objectAPIName + ' where Links_Formatting_Required__c = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {

        if(scope == null || scope.isEmpty()){
            return;
        }

        for(SObject sobj : scope){
            if(sobj != null && sobj.get('avnio__Answer__c') != null && String.valueOf(sobj.get('avnio__Answer__c')) != null){
                String answer = String.valueOf(sobj.get('avnio__Answer__c'));
                Set<String> linksToReplace = new Set<String>();
                String answerForHttp = answer;
                do{
                    if(answerForHttp.contains('http://')){
                        Integer startPoint = answerForHttp.indexOf('http://');
                        Boolean isImageUrl = false, isAnchorUrl = false;
                        if(startPoint > 0 && answerForHttp.substring(startPoint-1,startPoint) == '"'){
                            if(startPoint > 5 && answerForHttp.substring(startPoint-5,startPoint) == 'src="'){
                                isImageUrl = true;
                            }
                            if(startPoint > 6 && answerForHttp.substring(startPoint-6,startPoint) == 'href="'){
                                isAnchorUrl = true;
                                String answerForHttpTemp = answerForHttp.substring(startPoint,answerForHttp.length());
                                Integer anchorCloseIndex = answerForHttpTemp.indexOf('</a>');
                                if(anchorCloseIndex != null && anchorCloseIndex != -1){
                                    answerForHttp = answerForHttp.substring(startPoint+anchorCloseIndex+4,answerForHttp.length());
                                    continue;
                                }
                            }
                        }
                        for(Integer i = startPoint; i < answerForHttp.length() ; i++){
                            if(isImageUrl && answerForHttp.substring(i,i+1) == '"'){
                                answerForHttp = answerForHttp.substring(i+1,answerForHttp.length());
                                break;
                            }
                            else if(isAnchorUrl && answerForHttp.substring(i,i+1) == '"'){
                                String urlString = answerForHttp.substring(startPoint,i);
                                answerForHttp = answerForHttp.substring(i+1,answerForHttp.length());
                                break;
                            }
                            else if(i+4 <= answerForHttp.length() && answerForHttp.substring(i,i+4) == '</a>'){
                                answerForHttp = answerForHttp.substring(i+4,answerForHttp.length());
                                break;
                            }
                            else if(answerForHttp.substring(i,i+1) == ' ' ||  answerForHttp.substring(i,i+1) == '<' || answerForHttp.substring(i,i+2) == '.<'){
                                linksToReplace.add(answerForHttp.substring(startPoint,i));
                                answerForHttp = answerForHttp.substring(i+1,answerForHttp.length());
                                break;
                            }
                        }
                    }
                } while(answerForHttp.contains('http://'));

                String answerForHttps = answer;
                do{
                    if(answerForHttps.contains('https://')){
                        Integer startPoint = answerForHttps.indexOf('https://');
                        Boolean isImageUrl = false, isAnchorUrl = false;
                        if(startPoint > 0 && answerForHttps.substring(startPoint-1,startPoint) == '"'){
                            if(startPoint > 5 && answerForHttps.substring(startPoint-5,startPoint) == 'src="'){
                                isImageUrl = true;
                            }
                            if(startPoint > 6 && answerForHttps.substring(startPoint-6,startPoint) == 'href="'){
                                isAnchorUrl = true;
                                String answerForHttpsTemp = answerForHttps.substring(startPoint,answerForHttps.length());
                                Integer anchorCloseIndex = answerForHttpsTemp.indexOf('</a>');
                                if(anchorCloseIndex != null && anchorCloseIndex != -1){
                                    answerForHttps = answerForHttps.substring(startPoint+anchorCloseIndex+4,answerForHttps.length());
                                    continue;
                                }
                            }
                        }
                        for(Integer i = startPoint; i < answerForHttps.length() ; i++){
                            if(isImageUrl && answerForHttps.substring(i,i+1) == '"'){
                                answerForHttps = answerForHttps.substring(i+1,answerForHttps.length());
                                break;
                            }
                            else if(isAnchorUrl && answerForHttps.substring(i,i+1) == '"'){
                                String urlString = answerForHttps.substring(startPoint,i);
                                answerForHttps = answerForHttps.substring(i+1,answerForHttps.length());
                                break;
                            }
                            else if(i+4 <= answerForHttps.length() && answerForHttps.substring(i,i+4) == '</a>'){
                                answerForHttps = answerForHttps.substring(i+4,answerForHttps.length());
                                break;
                            }
                            else if(answerForHttps.substring(i,i+1) == ' ' || answerForHttps.substring(i,i+1) == '<' || answerForHttps.substring(i,i+2) == '.<'){
                                linksToReplace.add(answerForHttps.substring(startPoint,i));
                                answerForHttps = answerForHttps.substring(i+1,answerForHttps.length());
                                break;
                            }
                        }
                    }
                } while(answerForHttps.contains('https://'));

                if(linksToReplace.size() > 0){
                    for(String url : linksToReplace){
                        String urlWithSpace = url + ' ';
                        String urlWithCloseTag = url + '<';
                        String urlWithDot = url + '.<';
                        String formattedUrl = '<a href="' + url + '" target="_blank">' + url + '</a>';
                        answer = answer.replace(urlWithCloseTag,formattedUrl+'<');
                        answer = answer.replace(urlWithSpace,formattedUrl+' ');
                        answer = answer.replace(urlWithDot,formattedUrl+'.<');
                    }
                    sobj.put('avnio__Answer__c',answer);
                }
                System.debug('answer : '+answer);
            }
        }

        update scope;
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}