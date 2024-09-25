/**
 * Author : Avnio
 * Created Date : 19th October 2022
 * Class Name : ProjQueReviewNotificationBatch
 * Details : This Class is Project Question Review Notification batch
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   19-10-2022   SagarJ   Initial Version
 */
global class ProjQueReviewNotificationBatch implements Schedulable {

   global void execute(SchedulableContext ctx) {
        List<avnio__Project__c> projectlist = new List<avnio__Project__c> ();
        projectlist = [select id,avnio__Status__c from avnio__Project__c where avnio__Status__c != 'Submitted'];
        List<id> projectidlist = new List<id> ();
        if(projectlist != null && projectlist.size() > 0) {
           for(avnio__Project__c proj : projectlist) {
               projectidlist.add(proj.id);
           }
           avnio.ReviewerNotificationJob obj = new avnio.ReviewerNotificationJob(null,projectidlist);
           Database.executeBatch(obj,200);
        }
        
   }   
}