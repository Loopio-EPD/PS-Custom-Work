public with sharing class RemoveFormattedAnswerBatch implements Database.Batchable<sObject> {
    
    private String objectAPIName;
    private Boolean removeFontSize,removeFontFamily;

    public RemoveFormattedAnswerBatch(String objectAPIName, Boolean removeFontSize, Boolean removeFontFamily) {
        this.objectAPIName = objectAPIName;
        this.removeFontSize = removeFontSize;
        this.removeFontFamily = removeFontFamily;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id,avnio__Answer__c from ' + objectAPIName;
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {

        if(scope == null || scope.isEmpty()){
            return;
        }

        for(SObject sobj : scope){
            if(sobj != null && sobj.get('avnio__Answer__c') != null && String.valueOf(sobj.get('avnio__Answer__c')) != null){
                String answer = String.valueOf(sobj.get('avnio__Answer__c'));

                if(removeFontSize){
                    Set<String> fontsSet = new Set<String>();
                    String answerForFontSize = answer;
                    do{
                        if(answerForFontSize.contains('font-size:')){
                            Integer startPoint = answerForFontSize.indexOf('font-size:');
                            for(Integer i = startPoint; i < answerForFontSize.length() ; i++){
                                if(answerForFontSize.substring(i,i+1) == ';'){
                                    String fontString = answerForFontSize.substring(startPoint,i+1);
                                    Integer endIndexOfSize = fontString.indexOf(';');
                                    String finalFontSizeToAdd = fontString.substring(0,endIndexOfSize+1) != null ? fontString.substring(0,endIndexOfSize+1) : null;
                                    if(finalFontSizeToAdd != null){
                                        fontsSet.add(finalFontSizeToAdd);
                                    }
                                    answerForFontSize = answerForFontSize.substring(i+1,answerForFontSize.length());
                                    break;
                                }
                            }
                        }
                    } while(answerForFontSize.contains('font-size:'));

                    if(fontsSet.size() > 0){
                        for(String fontToRemove : fontsSet){
                            answer = answer.remove(fontToRemove);
                        }
                    }
                }

                //remove font family
                if(removeFontFamily){
                    Set<String> stylesSet = new Set<String>();
                    String answerForFontStyle = answer;
                    do{
                        if(answerForFontStyle.contains('font-family:')){
                            Integer startPoint = answerForFontStyle.indexOf('font-family:');
                            for(Integer i = startPoint; i < answerForFontStyle.length() ; i++){
                                if(answerForFontStyle.substring(i,i+1) == ';'){
                                    String fontStyle = answerForFontStyle.substring(startPoint,i+1);
                                    Integer startIndexOfSize = fontStyle.indexOf(':');
                                    Integer endIndexOfSize = fontStyle.indexOf(';');
                                    String finalFontStyleToAdd = fontStyle.substring(0,endIndexOfSize+1) != null ? fontStyle.substring(0,endIndexOfSize+1) : null;
                                    if(finalFontStyleToAdd != null){
                                        stylesSet.add(finalFontStyleToAdd);
                                    }
                                    answerForFontStyle = answerForFontStyle.substring(i+1,answerForFontStyle.length());
                                    break;
                                }
                            }
                        }
                    } while(answerForFontStyle.contains('font-family:'));

                    if(stylesSet.size() > 0){
                        for(String styleToRemove : stylesSet){
                            answer = answer.remove(styleToRemove);
                        }
                    }
                }
                //remove empty styles
                if(answer.contains(' style=""')){
                    answer = answer.remove(' style=""');
                }
                if(answer.contains(' style=" "')){
                    answer = answer.remove(' style=" "');
                }
                if(answer.contains(' style="  "')){
                    answer = answer.remove(' style="  "');
                }
                sobj.put('avnio__Answer__c',answer);
            }
        }

        update scope;
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}