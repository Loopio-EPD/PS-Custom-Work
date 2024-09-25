@isTest
public with sharing class OpportunityTriggerControllerTest {

    @TestSetup
    static void setup(){
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
    public static void oppTriggerControllerTest(){
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
            Go_No_Go_Configuration__c config = new Go_No_Go_Configuration__c();
            config.Name = 'Test Config';
            insert config;
            
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getorgdefaults();
            gonogosetting.Assignee_Notification__c = true;
            gonogosetting.Default_Configuration_Name__c = 'Test Config';
            gonogosetting.Opportunity_Stage_For_Notification__c = 'Prospecting';
            Database.upsert(gonogosetting);

            Opportunity opp = new Opportunity();
            opp.Closedate= System.today();
            opp.Name = 'mytest';
            opp.StageName = 'Prospecting';
            insert opp;

            opp.StageName = 'IsWon';
            update opp;

            opp.StageName = 'Prospecting';
            update opp;
        }
    }
    
}