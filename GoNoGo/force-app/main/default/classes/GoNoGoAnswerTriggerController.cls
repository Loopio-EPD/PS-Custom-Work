/*

*@description: This is handler class for GoNoGoAnswerTrigger.

*/
public with sharing class GoNoGoAnswerTriggerController {
    /*

    @description: This method is used to send go no go answer record for approval

    @param dateInput: Pass list of Go_No_Go_Answer__c records

    @return void

    */
    public static void sendForApproval(List<Go_No_Go_Answer__c> newItems){
        GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getorgdefaults();
        if(gonogosetting != null && !gonogosetting.Disable_Answer_Trigger__c && gonogosetting.Auto_Submit_for_Approval__c && gonogosetting.Threshold_Score_for_Approval__c != null){
            Integer thresholdvalue = Integer.valueOf(gonogosetting.Threshold_Score_for_Approval__c);
            for(Go_No_Go_Answer__c gonogoanswer : newItems){
                if(gonogoanswer.Go_No_Go_Score__c == null || Integer.valueOf(gonogoanswer.Go_No_Go_Score__c) <= thresholdvalue){
                    Boolean result = GoNoGoController.submitForApproval(String.valueOf(gonogoanswer.Id));
                }
            }
        }
    }
}