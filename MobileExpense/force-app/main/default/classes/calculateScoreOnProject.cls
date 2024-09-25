/*
* Author : Avnio
* Created Date : 4th January 2022
* Class Name : calculateScoreOnProject
* Details : To calculate bid score on project
* Modification Log: 
* Ver   Date          Author    Modification
* 1.0   04-01-2023    Avnio     Initial Version
*/

public class calculateScoreOnProject {
    public static void calculate(List<avnio__Project__c> projectlist, Map<id,avnio__Project__c> oldMap) {
        List<Bid_No_Bid_Score__c> scorelist = new List<Bid_No_Bid_Score__c> ();
        scorelist = [select id, Field_API_Name__c,score__c,value__c,Status__c  from Bid_No_Bid_Score__c];
        Map<string,List<Bid_No_Bid_Score__c>> scoreMap = new Map<String,List<Bid_No_Bid_Score__c>> ();
        for(Bid_No_Bid_Score__c score : scorelist) {
            List<Bid_No_Bid_Score__c> slist = new List<Bid_No_Bid_Score__c> ();
            if(scoreMap.get(score.Field_API_Name__c) != null) {
                slist = scoreMap.get(score.Field_API_Name__c);
            }
            slist.add(score);
            scoreMap.put(score.Field_API_Name__c,slist);
        }
        
        for(sobject proj : projectlist) {
            Decimal totalscore = 0;
            for(String field : scoreMap.keyset()) {
                
                for(Bid_No_Bid_Score__c bs : scoreMap.get(field)) {
                    if(bs.value__c == (string)proj.get(field)) {
                        totalscore = totalscore + bs.score__c;
                        if(oldMap != null && (((boolean)proj.get('Bid_No_Bid_Submitted__c') == true && bs.Status__c != null 
                                               && proj.get(field) != oldMap.get((id)proj.get('id')).get(field)) ||
                                              (bs.Status__c != null && (boolean)proj.get('Bid_No_Bid_Submitted__c') == true && oldMap.get((id)proj.get('id')).Bid_No_Bid_Submitted__c != (boolean)proj.get('Bid_No_Bid_Submitted__c')))) {
                            proj.put('avnio__Status__c',bs.Status__c );
                        }
                   
                    }
                }
            }
            proj.put('Bid_score__c', totalscore);
        }
    } 
}