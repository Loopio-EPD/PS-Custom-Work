/**
 * Author : Avnio
 * Created Date : 19th October 2022
 * Class Name : ProjQueAssignmentNotificationBatchTest
 * Details : This Class is test class for ProjQueAssignmentNotificationBatch
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   19-10-2022   SagarJ   Initial Version
 */
@istest
public class ProjQueAssignmentNotificationBatchTest {
    public static testMethod void init() {
        
        avnio__Project__c  proj = new avnio__Project__c  ();
        proj.avnio__ProjectName__c = 'test proj';
        insert proj;
        String sch1 = '0 0 * * * ?';
        ProjQueAssignmentNotificationBatch  sqrb1 = new ProjQueAssignmentNotificationBatch ();
        system.schedule('Project question assignment 0 min', sch1, sqrb1);
    }
}