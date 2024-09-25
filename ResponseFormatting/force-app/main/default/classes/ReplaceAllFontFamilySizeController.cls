public with sharing class ReplaceAllFontFamilySizeController {
    
    @AuraEnabled
    public static Boolean replaceFontSizeAndStyle(List<String> responseIds, String fontstyle, String fontsize){
        if(responseIds != null && responseIds.size() > 0){
            String query = 'select id,avnio__Answer__c from avnio__Response__c where id IN :responseIds limit 49999';
            List<SObject> scope = Database.query(query);
            if(scope != null && scope.size() > 0){
                for(SObject sobj : scope){
                    if(sobj != null && sobj.get('avnio__Answer__c') != null && String.valueOf(sobj.get('avnio__Answer__c')) != null){
                        String answer = String.valueOf(sobj.get('avnio__Answer__c'));
        
                        if(fontsize != null && String.isNotBlank(fontsize)){
                            Set<String> fontsSet = new Set<String>();
                            String answerForFontSize = answer;
                            do{
                                if(answerForFontSize.contains('font-size:')){
                                    Integer startPoint = answerForFontSize.indexOf('font-size:');
                                    for(Integer i = startPoint; i < answerForFontSize.length() ; i++){
                                        if(answerForFontSize.substring(i,i+1) == ';'){
                                            String fontString = answerForFontSize.substring(startPoint,i+1);
                                            Integer startIndexOfSize = fontString.indexOf(':');
                                            Integer endIndexOfSize = fontString.indexOf(';');
                                            String finalFontSizeToAdd = fontString.substring(startIndexOfSize+1,endIndexOfSize) != null ? fontString.substring(startIndexOfSize+1,endIndexOfSize).trim() : null;
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
                                for(String siz : fontsSet){
                                    answer = answer.replace(siz,fontsize + 'px');
                                }
                            }
                        }
        
                        if(fontstyle != null && String.isNotBlank(fontstyle)){
                            Set<String> stylesSet = new Set<String>();
                            String answerForFontStyle = answer;
                            do{
                                if(answerForFontStyle.contains('font-family:')){
                                    Integer startPoint = answerForFontStyle.indexOf('font-family:');
                                    for(Integer i = startPoint; i < answerForFontStyle.length() ; i++){
                                        if(answerForFontStyle.substring(i,i+1) == ';'){
                                            String fontStyleinner = answerForFontStyle.substring(startPoint,i+1);
                                            Integer startIndexOfSize = fontStyleinner.indexOf(':');
                                            Integer endIndexOfSize = fontStyleinner.indexOf(';');
                                            String finalFontStyleToAdd = fontStyleinner.substring(startIndexOfSize+1,endIndexOfSize) != null ? fontStyleinner.substring(startIndexOfSize+1,endIndexOfSize).trim() : null;
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
                                for(String sty : stylesSet){
                                    answer = answer.replace(sty,fontstyle);
                                }
                            }
                        }
                        sobj.put('avnio__Answer__c',answer);
                    }
                }

                update scope;
                return true;
            }
        }
        return false;
    }

    @AuraEnabled
    public static Boolean removeFontSizeAndStyle(List<String> responseIds, Boolean removeFontSize, Boolean removeFontFamily){
        if(responseIds != null && responseIds.size() > 0){
            String query = 'select id,avnio__Answer__c from avnio__Response__c where id IN :responseIds limit 49999';
            List<SObject> scope = Database.query(query);
            if(scope != null && scope.size() > 0){
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
                return true;
            }
        }
        return false;
    }

    @AuraEnabled
    public static Boolean replaceSelectedFontSizeAndStyle(List<String> responseIds, String fontstyleold, String fontsizeold, String fontstyle, String fontsize){
        if(responseIds != null && responseIds.size() > 0){
            String query = 'select id,avnio__Answer__c from avnio__Response__c where id IN :responseIds limit 49999';
            List<SObject> scope = Database.query(query);
            if(scope != null && scope.size() > 0){
                for(SObject sobj : scope){
                    if(sobj != null && sobj.get('avnio__Answer__c') != null && String.valueOf(sobj.get('avnio__Answer__c')) != null){
                        String answer = String.valueOf(sobj.get('avnio__Answer__c'));
                        if(fontstyleold != null && String.isNotBlank(fontstyleold) && fontstyle != null && String.isNotBlank(fontstyle)){
                            answer = answer.replace(fontstyleold,fontstyle);
                        }
                        if(fontsizeold != null && String.isNotBlank(fontsizeold) && fontsize != null && String.isNotBlank(fontsize)){
                            answer = answer.replace(fontsizeold + 'px',fontsize + 'px');
                        }
                        sobj.put('avnio__Answer__c',answer);
                    }
                }
                update scope;
                return true;
            }
        }
        return false;
    }
}