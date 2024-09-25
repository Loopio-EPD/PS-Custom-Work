@isTest
public with sharing class CreateGoNoGoScoresControllerTest {
	
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
    public static void getExistingScoresForQuestionTest(){
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
            
            Go_No_Go_Section__c section = new Go_No_Go_Section__c();
            section.Name = 'Test Section';
            section.Go_No_Go_Configuration__c = config.Id;
            insert section;
            
            Go_No_Go_Question_Bank__c question = new Go_No_Go_Question_Bank__c();
            question.Go_No_Go_Section__c = section.Id;
            question.Question_Label__c = 'Test Question';
            insert question;
            
            CreateGoNoGoScoresController.ScoringWrapper scoringWrapper = CreateGoNoGoScoresController.getExistingScoresForQuestion(String.valueOf(question.Id));
            System.Assert(scoringWrapper != null);
        }
    }
    
    @isTest
    public static void saveScoringRecordsTest(){
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
            
            Go_No_Go_Section__c section = new Go_No_Go_Section__c();
            section.Name = 'Test Section';
            section.Go_No_Go_Configuration__c = config.Id;
            insert section;
            
            Go_No_Go_Question_Bank__c question = new Go_No_Go_Question_Bank__c();
            question.Go_No_Go_Section__c = section.Id;
            question.Question_Label__c = 'Test Question';
            insert question;
            
            Go_No_Go_Question_Bank_Scoring__c scoring = new Go_No_Go_Question_Bank_Scoring__c();
            scoring.Go_No_Go_Question_Bank__c = question.Id;
            scoring.Score__c = 1;
            scoring.Value__c = 'Yes';
            insert scoring;
            
            CreateGoNoGoScoresController.ScoringRequest scoring1 = new CreateGoNoGoScoresController.ScoringRequest();
            scoring1.score = 1;
            scoring1.value = 'Yes';
            scoring1.scoreId = String.valueOf(scoring.Id);
            
            List<CreateGoNoGoScoresController.ScoringRequest> scoringList = new List<CreateGoNoGoScoresController.ScoringRequest>();
            scoringList.add(scoring1);
            
            CreateGoNoGoScoresController.ResultWrapper response = CreateGoNoGoScoresController.saveScoringRecords(JSON.serialize(scoringList), String.valueOf(question.Id));
            System.Assert(response.isSuccess == true);
        }
    }
    
    @isTest
    public static void deleteScoreRecordTest(){
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
            
            Go_No_Go_Section__c section = new Go_No_Go_Section__c();
            section.Name = 'Test Section';
            section.Go_No_Go_Configuration__c = config.Id;
            insert section;
            
            Go_No_Go_Question_Bank__c question = new Go_No_Go_Question_Bank__c();
            question.Go_No_Go_Section__c = section.Id;
            question.Question_Label__c = 'Test Question';
            insert question;
            
            Go_No_Go_Question_Bank_Scoring__c scoring = new Go_No_Go_Question_Bank_Scoring__c();
            scoring.Go_No_Go_Question_Bank__c = question.Id;
            scoring.Score__c = 1;
            scoring.Value__c = 'Yes';
            insert scoring;
            
            Boolean response = CreateGoNoGoScoresController.deleteScoreRecord(String.valueOf(scoring.Id));
            System.Assert(response == true);
        }
    }
}