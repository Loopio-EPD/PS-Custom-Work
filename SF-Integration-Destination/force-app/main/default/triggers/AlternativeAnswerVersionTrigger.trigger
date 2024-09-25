trigger AlternativeAnswerVersionTrigger on avnio__AlternativeAnswerVersion__c (after insert, after update, after delete) {

    Set<avnio__ResponseVersion__c> responseVersionsToUpdate = new Set<avnio__ResponseVersion__c>();

    List<avnio__AlternativeAnswerVersion__c> alternativeAnswerVersionList = new List<avnio__AlternativeAnswerVersion__c> ();
    
    String currentUserId15Digit = UserInfo.getUserId().substring(0, 15);

    if(Trigger.isInsert){
        alternativeAnswerVersionList = Trigger.New;
        for(avnio__AlternativeAnswerVersion__c altansversion : alternativeAnswerVersionList) {
            String primaryReviewer = altansversion.Primary_Reviewer_Response_Version__c;
            String secondaryReviewer = altansversion.Secondary_Reviewer_Response_Version__c;
            //If you have Primary Reviewer + Secondary Reviewer on Response Version and you are Secondary Reviewer then Review Status will not change
            if(primaryReviewer != null && secondaryReviewer != null && currentUserId15Digit.equalsIgnoreCase(secondaryReviewer)){
                continue;
            }
            //If you have Only Primary Reviewer on Response Version and you are making changes then Review Status will not change
            if(primaryReviewer != null && secondaryReviewer == null && currentUserId15Digit.equalsIgnoreCase(primaryReviewer)){
                continue;
            }
            //If you have Primary Reviewer + Secondary Reviewer on Response Version and you are Primary Reviewer then Review Status will become Review Required
            //jo banda change kar raha he primary nahi he or secondary bhi nahi he and kuch change kr raha he then review status change hoga
            if((primaryReviewer != null && secondaryReviewer != null && currentUserId15Digit.equalsIgnoreCase(primaryReviewer)) 
            || (primaryReviewer != null && secondaryReviewer != null && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer) && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer))
             || (primaryReviewer != null && secondaryReviewer == null && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer) )){
                if(altansversion.avnio__ClonedFromId__c == null && altansversion.avnio__ResponseVersionId__c != null && altansversion.Review_Status_Response__c != 'Submitted' && altansversion.Review_Status_Response__c != 'In Progress'){
                    avnio__ResponseVersion__c rv = new avnio__ResponseVersion__c();
                    rv.Id = altansversion.avnio__ResponseVersionId__c;
                    rv.avnio__ReviewStatus__c = 'Review Required';
                    responseVersionsToUpdate.add(rv);
                }
            }
            
            if(altansversion.Review_Stage_Response__c == 'Cycle Review - Secondary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer)) {
                altansversion.addError('Response is in Cycle Review with Secondary Reviewer. You will not be able to make any changes');
            }
            
            if(altansversion.Review_Stage_Response__c == 'Cycle Review - Primary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer) && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer)) {
                altansversion.addError('Response is in Cycle Review with Primary Reviewer. You will not be able to make any changes');
            }
        }
    }
    else if(Trigger.isUpdate){
        alternativeAnswerVersionList = Trigger.New;
        Map<id,avnio__AlternativeAnswerVersion__c> alternativeAnswerVersionOldMap = new Map<id,avnio__AlternativeAnswerVersion__c> ();
        alternativeAnswerVersionOldMap = Trigger.oldMap;
        for(avnio__AlternativeAnswerVersion__c altansversion : alternativeAnswerVersionList) {
            String primaryReviewer = altansversion.Primary_Reviewer_Response_Version__c;
            String secondaryReviewer = altansversion.Secondary_Reviewer_Response_Version__c;
            //If you have Primary Reviewer + Secondary Reviewer on Response Version and you are Secondary Reviewer then Review Status will not change
            if(primaryReviewer != null && secondaryReviewer != null && currentUserId15Digit.equalsIgnoreCase(secondaryReviewer)){
                continue;
            }
            //If you have Only Primary Reviewer on Response Version and you are making changes then Review Status will not change
            if(primaryReviewer != null && secondaryReviewer == null && currentUserId15Digit.equalsIgnoreCase(primaryReviewer)){
                continue;
            }
            //If you have Primary Reviewer + Secondary Reviewer on Response Version and you are Primary Reviewer then Review Status will become Review Required
            //jo banda change kar raha he primary nahi he or secondary bhi nahi he and kuch change kr raha he then review status change hoga
            if((primaryReviewer != null && secondaryReviewer != null && currentUserId15Digit.equalsIgnoreCase(primaryReviewer)) ||
             (primaryReviewer != null && secondaryReviewer != null && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer) && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer))
              || (primaryReviewer != null && secondaryReviewer == null && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer) )){
                if(altansversion.avnio__ResponseVersionId__c != null && altansversion.Review_Status_Response__c != 'Submitted' && altansversion.Review_Status_Response__c != 'In Progress' && altansversion.avnio__Answer__c != alternativeAnswerVersionOldMap.get(altansversion.id).avnio__Answer__c){
                    avnio__ResponseVersion__c rv = new avnio__ResponseVersion__c();
                    rv.Id = altansversion.avnio__ResponseVersionId__c;
                    rv.avnio__ReviewStatus__c = 'Review Required';
                    responseVersionsToUpdate.add(rv);
                }
            }
             if(altansversion.Review_Stage_Response__c == 'Cycle Review - Secondary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer)) {
                altansversion.addError('Response is in Cycle Review with Secondary Reviewer. You will not be able to make any changes');
            }
            
            if(altansversion.Review_Stage_Response__c == 'Cycle Review - Primary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer) && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer)) {
                altansversion.addError('Response is in Cycle Review with Primary Reviewer. You will not be able to make any changes');
            }
        }
        
       
        Set<id> altanswerversionIDSet = new Set<id> ();
        for(avnio__AlternativeAnswerVersion__c altansversion : alternativeAnswerVersionList) {
            
            if(altansversion.External_ID_for_Integration__c != null && altansversion.avnio__RootAlternativeAnswerId__c != null &&
                altansversion.avnio__RootAlternativeAnswerId__c != Trigger.oldMap.get(altansversion.id).avnio__RootAlternativeAnswerId__c) {
                altanswerversionIDSet.add(altansversion.External_ID_for_Integration__c);
            }
            
        }
        system.debug('--altanswerversionIDSet'+altanswerversionIDSet);
        if(altanswerversionIDSet != null && altanswerversionIDSet.size() > 0) {
            List<avnio__AlternativeAnswer__c> alternativeanswertoupdate = new List<avnio__AlternativeAnswer__c> ();
            List<avnio__AlternativeAnswer__c> existingAltanswithExternalID = new List<avnio__AlternativeAnswer__c> ();
            existingAltanswithExternalID = [select id,External_ID__c from avnio__AlternativeAnswer__c where External_ID__c IN:altanswerversionIDSet];
            Map<id,avnio__AlternativeAnswer__c> existinaltanswerMap = new Map<id,avnio__AlternativeAnswer__c> (existingAltanswithExternalID);
           
            for(avnio__AlternativeAnswerVersion__c altansversion : alternativeAnswerVersionList) {
                
                if(altansversion.External_ID_for_Integration__c != null && altansversion.avnio__RootAlternativeAnswerId__c != null &&
                    altansversion.avnio__RootAlternativeAnswerId__c != Trigger.oldMap.get(altansversion.id).avnio__RootAlternativeAnswerId__c
                    && !existinaltanswerMap.containskey(altansversion.avnio__RootAlternativeAnswerId__c)) {
                    alternativeanswertoupdate.add(new avnio__AlternativeAnswer__c(id=altansversion.avnio__RootAlternativeAnswerId__c, External_ID__c =altansversion.External_ID_for_Integration__c));
                }
            }
            if(alternativeanswertoupdate != null && alternativeanswertoupdate.size() > 0 ) {
                RFxIntegrationSchedular.actionFromSchedular = true;
                system.debug('--->alternativeanswertoupdate'+alternativeanswertoupdate);
                Database.update(alternativeanswertoupdate,true);
            }
        }
        /*
        Set<id> altanswerversionIDSet = new Set<id> ();
        for(avnio__AlternativeAnswerVersion__c altansversion : alternativeAnswerVersionList) {
            
            if(altansversion.External_ID_for_Integration__c != null && altansversion.avnio__RootAlternativeAnswerId__c != null &&
                altansversion.avnio__RootAlternativeAnswerId__c != Trigger.oldMap.get(altansversion.id).avnio__RootAlternativeAnswerId__c) {
                altanswerversionIDSet.add(altansversion.id);
            }
        }
        if(altanswerversionIDSet != null && altanswerversionIDSet.size() > 0) {
            UpdateExternalIDForIntegration.updateAltAnswer(altanswerversionIDSet);
        }
        */
    }
    else if(Trigger.isDelete){
        alternativeAnswerVersionList = Trigger.Old;
        for(avnio__AlternativeAnswerVersion__c altansversion : alternativeAnswerVersionList) {
            String primaryReviewer = altansversion.Primary_Reviewer_Response_Version__c;
            String secondaryReviewer = altansversion.Secondary_Reviewer_Response_Version__c;
            //If you have Primary Reviewer + Secondary Reviewer on Response Version and you are Secondary Reviewer then Review Status will not change
            if(primaryReviewer != null && secondaryReviewer != null && currentUserId15Digit.equalsIgnoreCase(secondaryReviewer)){
                continue;
            }
            //If you have Only Primary Reviewer on Response Version and you are making changes then Review Status will not change
            if(primaryReviewer != null && secondaryReviewer == null && currentUserId15Digit.equalsIgnoreCase(primaryReviewer)){
                continue;
            }
            //If you have Primary Reviewer + Secondary Reviewer on Response Version and you are Primary Reviewer then Review Status will become Review Required
            //jo banda change kar raha he primary nahi he or secondary bhi nahi he and kuch change kr raha he then review status change hoga
            if((primaryReviewer != null && secondaryReviewer != null && currentUserId15Digit.equalsIgnoreCase(primaryReviewer)) 
            || (primaryReviewer != null && secondaryReviewer != null && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer) && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer))
            || (primaryReviewer != null && secondaryReviewer == null && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer) )){
                if(altansversion.avnio__ResponseVersionId__c != null && altansversion.Review_Status_Response__c != 'Submitted' && altansversion.Review_Status_Response__c != 'In Progress'){
                    avnio__ResponseVersion__c rv = new avnio__ResponseVersion__c();
                    rv.Id = altansversion.avnio__ResponseVersionId__c;
                    rv.avnio__ReviewStatus__c = 'Review Required';
                    responseVersionsToUpdate.add(rv);
                }
            }
             if(altansversion.Review_Stage_Response__c == 'Cycle Review - Secondary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer)) {
                altansversion.addError('Response is in Cycle Review with Secondary Reviewer. You will not be able to make any changes');
            }
            
            if(altansversion.Review_Stage_Response__c == 'Cycle Review - Primary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer) && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer)) {
                altansversion.addError('Response is in Cycle Review with Primary Reviewer. You will not be able to make any changes');
            }
        }
    }
    
    if(responseVersionsToUpdate.size() > 0){
        Database.update(new List<avnio__ResponseVersion__c>(responseVersionsToUpdate));
    }
}