trigger AlternativeQuestionVersionTrigger on avnio__AlternativeQuestionVersion__c (after insert, after update, after delete) {
        
    Set<avnio__ResponseVersion__c> responseVersionsToUpdate = new Set<avnio__ResponseVersion__c>();

    List<avnio__AlternativeQuestionVersion__c> alternativeQuestionVersionList = new List<avnio__AlternativeQuestionVersion__c> ();
    
    String currentUserId15Digit = UserInfo.getUserId().substring(0, 15);
    
    if(Trigger.isInsert){
        alternativeQuestionVersionList = Trigger.New;
        for(avnio__AlternativeQuestionVersion__c altquesversion : alternativeQuestionVersionList) {
            String primaryReviewer = altquesversion.Primary_Reviewer_Response_Version__c;
            String secondaryReviewer = altquesversion.Secondary_Reviewer_Response_Version__c;
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
                if(altquesversion.avnio__ClonedFromId__c == null && altquesversion.avnio__ResponseVersionId__c != null && altquesversion.Review_Status_Response__c != 'Submitted' && altquesversion.Review_Status_Response__c != 'In Progress'){
                    avnio__ResponseVersion__c rv = new avnio__ResponseVersion__c();
                    rv.Id = altquesversion.avnio__ResponseVersionId__c;
                    rv.avnio__ReviewStatus__c = 'Review Required';
                    responseVersionsToUpdate.add(rv);
                }
            }
             if(altquesversion.Review_Stage_Response__c == 'Cycle Review - Secondary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer)) {
                altquesversion.addError('Response is in Cycle Review with Secondary Reviewer. You will not be able to make any changes');
            }
            
            if(altquesversion.Review_Stage_Response__c == 'Cycle Review - Primary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer) && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer)) {
                altquesversion.addError('Response is in Cycle Review with Primary Reviewer. You will not be able to make any changes');
            }
        }
    }
    else if(Trigger.isUpdate){
        alternativeQuestionVersionList = Trigger.New;
        Map<id,avnio__AlternativeQuestionVersion__c> alternativeQuestionVersionOldMap = new Map<id,avnio__AlternativeQuestionVersion__c> ();
        alternativeQuestionVersionOldMap = Trigger.oldMap;
        for(avnio__AlternativeQuestionVersion__c altquesversion : alternativeQuestionVersionList) {
            String primaryReviewer = altquesversion.Primary_Reviewer_Response_Version__c;
            String secondaryReviewer = altquesversion.Secondary_Reviewer_Response_Version__c;
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
                if(altquesversion.avnio__ResponseVersionId__c != null && altquesversion.Review_Status_Response__c != 'Submitted' && altquesversion.Review_Status_Response__c != 'In Progress' && altquesversion.avnio__Question__c != alternativeQuestionVersionOldMap.get(altquesversion.id).avnio__Question__c){
                    avnio__ResponseVersion__c rv = new avnio__ResponseVersion__c();
                    rv.Id = altquesversion.avnio__ResponseVersionId__c;
                    rv.avnio__ReviewStatus__c = 'Review Required';
                    responseVersionsToUpdate.add(rv);
                }
            }
            if(altquesversion.Review_Stage_Response__c == 'Cycle Review - Secondary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer)) {
                altquesversion.addError('Response is in Cycle Review with Secondary Reviewer. You will not be able to make any changes');
            }
            
            if(altquesversion.Review_Stage_Response__c == 'Cycle Review - Primary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer) && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer)) {
                altquesversion.addError('Response is in Cycle Review with Primary Reviewer. You will not be able to make any changes');
            }
        }
        
        Set<id> altquestionversionIDSet = new Set<id> ();
         for(avnio__AlternativeQuestionVersion__c altquestionversion : alternativeQuestionVersionList) {
            
            if(altquestionversion.External_ID_for_Integration__c != null && altquestionversion.avnio__RootAlternativeQuestionId__c != null &&
                altquestionversion.avnio__RootAlternativeQuestionId__c != Trigger.oldMap.get(altquestionversion.id).avnio__RootAlternativeQuestionId__c) {
               altquestionversionIDSet.add(altquestionversion.External_ID_for_Integration__c);
            }
        }
        system.debug('--altquestionversionIDSet-->'+altquestionversionIDSet);
        if(altquestionversionIDSet != null && altquestionversionIDSet.size() > 0) {
            List<avnio__ResponseQuestion__c> alternativequestiontoupdate = new List<avnio__ResponseQuestion__c> ();
            List<avnio__ResponseQuestion__c> existingResponsewithExternalID = new List<avnio__ResponseQuestion__c> ();
            existingResponsewithExternalID = [select id,External_ID__c from avnio__ResponseQuestion__c where External_ID__c IN:altquestionversionIDSet];
            Map<id,avnio__ResponseQuestion__c> existingexternalID = new Map<id,avnio__ResponseQuestion__c> ();
            for (avnio__ResponseQuestion__c resque : existingResponsewithExternalID) {
                existingexternalID.put(resque.External_ID__c,resque);
            }
            system.debug('--->existingexternalID--'+existingexternalID);
            for(avnio__AlternativeQuestionVersion__c altquestionversion : alternativeQuestionVersionList) {
                
                if(altquestionversion.External_ID_for_Integration__c != null && altquestionversion.avnio__RootAlternativeQuestionId__c != null &&
                    altquestionversion.avnio__RootAlternativeQuestionId__c != Trigger.oldMap.get(altquestionversion.id).avnio__RootAlternativeQuestionId__c
                    && !existingexternalID.containskey(altquestionversion.External_ID_for_Integration__c)) {
                    alternativequestiontoupdate.add(new avnio__ResponseQuestion__c(id=altquestionversion.avnio__RootAlternativeQuestionId__c, External_ID__c =altquestionversion.External_ID_for_Integration__c));
                }
            }
            if(alternativequestiontoupdate != null && alternativequestiontoupdate.size() > 0 ) {
            RFxIntegrationSchedular.actionFromSchedular = true;
            system.debug('--->alternativequestiontoupdate'+alternativequestiontoupdate);
               Database.update(alternativequestiontoupdate,true);
            }
        }
        
        
      /*  Set<id> altquestionversionIDSet = new Set<id> ();
         for(avnio__AlternativeQuestionVersion__c altquestionversion : alternativeQuestionVersionList) {
            
            if(altquestionversion.External_ID_for_Integration__c != null && altquestionversion.avnio__RootAlternativeQuestionId__c != null &&
                altquestionversion.avnio__RootAlternativeQuestionId__c != Trigger.oldMap.get(altquestionversion.id).avnio__RootAlternativeQuestionId__c) {
               altquestionversionIDSet.add(altquestionversion.id);
            }
        }
        if(altquestionversionIDSet != null && altquestionversionIDSet.size() > 0) {
            UpdateExternalIDForIntegration.updateAltQuestion(altquestionversionIDSet);
        }*/
    }
    else if(Trigger.isDelete){
        alternativeQuestionVersionList = Trigger.Old;
        for(avnio__AlternativeQuestionVersion__c altquesversion : alternativeQuestionVersionList) {
            String primaryReviewer = altquesversion.Primary_Reviewer_Response_Version__c;
            String secondaryReviewer = altquesversion.Secondary_Reviewer_Response_Version__c;
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
                if(altquesversion.avnio__ResponseVersionId__c != null && altquesversion.Review_Status_Response__c != 'Submitted' && altquesversion.Review_Status_Response__c != 'In Progress'){
                    avnio__ResponseVersion__c rv = new avnio__ResponseVersion__c();
                    rv.Id = altquesversion.avnio__ResponseVersionId__c;
                    rv.avnio__ReviewStatus__c = 'Review Required';
                    responseVersionsToUpdate.add(rv);
                }
            }
             if(altquesversion.Review_Stage_Response__c == 'Cycle Review - Secondary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer)) {
                altquesversion.addError('Response is in Cycle Review with Secondary Reviewer. You will not be able to make any changes');
            }
            
            if(altquesversion.Review_Stage_Response__c == 'Cycle Review - Primary Reviewer' && !currentUserId15Digit.equalsIgnoreCase(secondaryReviewer) && !currentUserId15Digit.equalsIgnoreCase(primaryReviewer)) {
                altquesversion.addError('Response is in Cycle Review with Primary Reviewer. You will not be able to make any changes');
            }
        }
    }
    
    if(responseVersionsToUpdate.size() > 0){
        Database.update(new List<avnio__ResponseVersion__c>(responseVersionsToUpdate));
    }
}