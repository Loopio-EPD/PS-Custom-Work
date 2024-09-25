public with sharing class ReplaceFormattedAnswerBatch implements Database.Batchable<sObject> {
    
    private String objectAPIName;
    private Boolean addDefaultSizeAndFamily;

    public ReplaceFormattedAnswerBatch(String objectAPIName, Boolean addDefaultSizeAndFamily) {
        this.objectAPIName = objectAPIName;
        this.addDefaultSizeAndFamily = addDefaultSizeAndFamily;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id,avnio__Answer__c,FontSizes__c,FontStyles__c from ' + objectAPIName;
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {

        if(scope == null || scope.isEmpty()){
            return;
        }

        String sizeToReplace = '10pt';
        String styleToReplace = 'Roboto';

        for(SObject sobj : scope){
            if(sobj != null && sobj.get('avnio__Answer__c') != null && String.valueOf(sobj.get('avnio__Answer__c')) != null){
                String answer = String.valueOf(sobj.get('avnio__Answer__c'));
                Boolean noFontSizePresent = true, noFontStylePresent = true;
                if(sobj.get('FontSizes__c') != null && String.valueOf(sobj.get('FontSizes__c')) != null){
                    String fontsizevalue = String.valueOf(sobj.get('FontSizes__c'));
                    List<String> sizeList = fontsizevalue.split(',');
                    for(String siz : sizeList){
                        answer = answer.replace(siz,sizeToReplace);
                    }
                    noFontSizePresent = false;
                }

                if(sobj.get('FontStyles__c') != null && String.valueOf(sobj.get('FontStyles__c')) != null){
                    String fontstylevalue = String.valueOf(sobj.get('FontStyles__c'));
                    List<String> styleList = fontstylevalue.split(',');
                    for(String styl : styleList){
                        answer = answer.replace(styl,styleToReplace);
                    }
                    noFontStylePresent = false;
                }

                if(addDefaultSizeAndFamily && (noFontSizePresent || noFontStylePresent)){
                    if(answer.startsWith('<p>')){
                        answer = '<p style="font-size: ' + sizeToReplace + '; font-family: ' + styleToReplace + ';">' + answer.substring(3);
                    }
                    else{
                        answer = '<p style="font-size: ' + sizeToReplace + '; font-family: ' + styleToReplace + ';">' + answer + '</p>';
                    }
                }

                sobj.put('avnio__Answer__c',answer);
            }
        }

        update scope;
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}