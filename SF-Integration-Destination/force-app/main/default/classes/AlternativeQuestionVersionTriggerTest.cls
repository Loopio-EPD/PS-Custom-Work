@istest
public class AlternativeQuestionVersionTriggerTest {
    public static testMethod void init() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com');      
        
        insert(u);
        avnio__Response__c  rsp = new avnio__Response__c  ();
        rsp.avnio__IsActive__c   = true;
        rsp.avnio__PrimaryReviewerId__c = u.id;
        insert rsp;
        
        avnio__ResponseVersion__c rve = new avnio__ResponseVersion__c ();
        rve.avnio__ResponseID__c = rsp.id;
        rve.avnio__PrimaryReviewerId__c = u.id;
        insert rve;
        
        avnio__AlternativeQuestionVersion__c avt = new avnio__AlternativeQuestionVersion__c ();
        avt.avnio__ResponseVersionId__c = rve.id;
        insert avt;
        
        
        update avt;
        delete avt;
        
      
    
        
    }
}