@isTest
public with sharing class GoNoGoAnswerTriggerTest {

    @TestSetup
    static void setup() {
        Profile p = [select id from profile where name='System Administrator'];
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        while (randomString.length() < 10) {
           Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randomString += chars.substring(index, index+1);
        }
        String uname = 'test' + randomString + '@testEmail.com';
        User u = new User(alias = 'ftestusr', 
            email='test@loopio.com', 
            emailencodingkey='UTF-8', 
            firstname ='Testing',
            lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', 
            profileid = p.Id, 
            isActive = true,
            timezonesidkey='America/Los_Angeles', 
            username = uname); 
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Go_No_Go_Permission_set'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
    }

    @isTest
    public static void updateAnswerTest(){
        String userQuery = 'SELECT Id, lastname FROM User';
        List<User> userList = Database.query(userQuery);
        User u;
        if(userList != null && userList.size() > 0){
            for(User us : userList){
                if(us.get('lastname') != null && String.valueOf(us.get('lastname')).equalsIgnoreCase('Testing')){
                    u = us;
                }
            }
        }
        System.runAs(u) {
            Opportunity opp = new Opportunity();
            opp.Closedate= System.today();
            opp.Name = 'test';
            opp.StageName = 'IsWon';
            insert opp;
            
            Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
            answer.Opportunity__c = opp.Id;
            insert answer;
            
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getOrgDefaults();
            gonogosetting.Disable_Answer_Trigger__c = false;
            gonogosetting.Auto_Submit_for_Approval__c = true;
            gonogosetting.Threshold_Score_for_Approval__c = 50;
            gonogosetting.Default_Configuration_Name__c = 'Test';
            insert gonogosetting;
            
            answer.Go_No_Go_Score__c = 30;
            update answer;

            List<ProcessInstance> approvalSentList = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE Status = 'Pending' and TargetObjectId IN (select id from Go_No_Go_Answer__c where id = :answer.Id)];
            System.Assert(approvalSentList !=  null);
        }
    }
}