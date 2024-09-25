@isTest
public with sharing class GoNoGoControllerTest {


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
    public static void getGoNoGOQuestionsFromConfigurationTest(){
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
            
            List<GoNoGoController.SectionWrapper> response = GoNoGoController.getGoNoGOQuestionsFromConfiguration(config.Name,null);
            System.Assert(response != null);
        }
    }

    @isTest
    public static void getGoNoGOQuestionsFromConfigurationTest2(){
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

            Opportunity opp = new Opportunity();
            opp.Closedate= System.today();
            opp.Name = 'test';
            opp.StageName = 'IsWon';
            insert opp;
            
            Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
            answer.Opportunity__c = opp.Id;
            insert answer;
            
            List<GoNoGoController.SectionWrapper> response = GoNoGoController.getGoNoGOQuestionsFromConfiguration(config.Name,answer.Id);
            System.Assert(response != null);
        }
    }
    
    @isTest
    public static void saveAnswerRecordsTest(){
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
            
            List<GoNoGoController.ScoringWrapper> scoringRecords = new List<GoNoGoController.ScoringWrapper>();
            GoNoGoController.ScoringWrapper scoreWrapper = new GoNoGoController.ScoringWrapper();
            scoreWrapper.scoringId = scoring.Id;
            scoreWrapper.value = 'anse';
            scoreWrapper.score = 1;
            scoringRecords.add(scoreWrapper);
            
            List<GoNoGoController.QuestionWrapper> questionRecords = new List<GoNoGoController.QuestionWrapper>();
            GoNoGoController.QuestionWrapper quesWrapper = new GoNoGoController.QuestionWrapper();
            quesWrapper.questionId = question.Id;
            quesWrapper.questionLabel = question.Question_Label__c;
            quesWrapper.questionSequence = 1;
            quesWrapper.sectionId = section.Id;
            quesWrapper.answerValue = 'anse';
            quesWrapper.maxScore = 3;
            questionRecords.add(quesWrapper);
            quesWrapper.scoringRecords = scoringRecords;
            
            List<GoNoGoController.SectionWrapper> sectionWrapperList = new List<GoNoGoController.SectionWrapper>();
            GoNoGoController.SectionWrapper sectionWrapper = new GoNoGoController.SectionWrapper();
            sectionWrapper.sectionId = section.Id;
            sectionWrapper.sectionName = section.Name;
            sectionWrapper.sectionSequence = 1;
            sectionWrapper.questionRecords = questionRecords;
            sectionWrapperList.add(sectionWrapper);
            
            Opportunity opp = new Opportunity();
            opp.Closedate= System.today();
            opp.Name = 'test';
            opp.StageName = 'IsWon';
            insert opp;
            
            GoNoGoController.ResultWrapper response = GoNoGoController.saveAnswerRecords(JSON.serialize(sectionWrapperList),String.valueOf(opp.id),null);
            System.Assert(response != null);
        }
    }

    @isTest
    public static void saveAnswerRecordsTest1(){
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
            
            List<GoNoGoController.ScoringWrapper> scoringRecords = new List<GoNoGoController.ScoringWrapper>();
            GoNoGoController.ScoringWrapper scoreWrapper = new GoNoGoController.ScoringWrapper();
            scoreWrapper.scoringId = scoring.Id;
            scoreWrapper.value = 'anse';
            scoreWrapper.score = 1;
            scoringRecords.add(scoreWrapper);
            
            List<GoNoGoController.QuestionWrapper> questionRecords = new List<GoNoGoController.QuestionWrapper>();
            GoNoGoController.QuestionWrapper quesWrapper = new GoNoGoController.QuestionWrapper();
            quesWrapper.questionId = question.Id;
            quesWrapper.questionLabel = question.Question_Label__c;
            quesWrapper.questionSequence = 1;
            quesWrapper.sectionId = section.Id;
            quesWrapper.answerValue = 'anse';
            quesWrapper.maxScore = 3;
            questionRecords.add(quesWrapper);
            quesWrapper.scoringRecords = scoringRecords;
            
            List<GoNoGoController.SectionWrapper> sectionWrapperList = new List<GoNoGoController.SectionWrapper>();
            GoNoGoController.SectionWrapper sectionWrapper = new GoNoGoController.SectionWrapper();
            sectionWrapper.sectionId = section.Id;
            sectionWrapper.sectionName = section.Name;
            sectionWrapper.sectionSequence = 1;
            sectionWrapper.questionRecords = questionRecords;
            sectionWrapperList.add(sectionWrapper);
            
            Opportunity opp = new Opportunity();
            opp.Closedate= System.today();
            opp.Name = 'test';
            opp.StageName = 'IsWon';
            insert opp;
            
            Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
            answer.Opportunity__c = opp.Id;
            insert answer;

            Go_No_Go_Linked_Configuration__c linkedconfig = new Go_No_Go_Linked_Configuration__c();
            linkedconfig.Name = 'Test Linked';
            linkedconfig.Go_No_Go_Configuration__c = config.Id;
            insert linkedconfig;

            GoNoGoController.ResultWrapper response = GoNoGoController.saveAnswerRecords(JSON.serialize(sectionWrapperList),answer.Id,linkedconfig.Id);
            System.Assert(response != null);
        }
    }
    
    @isTest
    public static void submitForApprovalTest(){
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
            
            Boolean response = GoNoGoController.submitForApproval(String.valueOf(answer.id));
            System.Assert(response != null);
        }
    }
    
    @isTest
    public static void checkIfApprovedTest(){
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
            
            GoNoGoController.ResultWrapper response = GoNoGoController.checkIfApproved(String.valueOf(answer.id));
            System.Assert(response != null);
        }
    }
    
    @isTest
    public static void getDefaultConfigurationsTest(){
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
            
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getorgdefaults();
            gonogosetting.Default_Configuration_Name__c = 'Test Config';
            gonogosetting.Threshold_Score_for_Approval__c = 40;
            Database.upsert(gonogosetting);
            
            List<GoNoGoStatus__c> statusList = new List<GoNoGoStatus__c>();
            GoNoGoStatus__c status1 = new  GoNoGoStatus__c();
            status1.Name = 'Red';
            status1.Min_Range__c = 0;
            status1.Max_Range__c = 30;
            status1.Static_Resource_Name__c = 'red_status';
            statusList.add(status1);
    
            GoNoGoStatus__c status2 = new  GoNoGoStatus__c();
            status2.Name = 'Yellow';
            status2.Min_Range__c = 31;
            status2.Max_Range__c = 60;
            status2.Static_Resource_Name__c = 'yellow_status';
            statusList.add(status2);
            
            Database.insert(statusList,true);
            
            GoNoGoController.GoNoGoSettingsWrapper response = GoNoGoController.getDefaultConfigurations();
            System.Assert(response != null);
        }
    }
    
    @isTest
    public static void updateDefaultConfigNameTest(){
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
            
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getorgdefaults();
            gonogosetting.Default_Configuration_Name__c = 'Test Config';
            gonogosetting.Threshold_Score_for_Approval__c = 40;
            Database.upsert(gonogosetting);
            
            GoNoGoController.ResultWrapper response = GoNoGoController.updateDefaultConfigName('Test 2');
            GoNoGoSetting__c gonogosetting1 = GoNoGoSetting__c.getorgdefaults();
            System.Assert(gonogosetting1.Default_Configuration_Name__c == 'Test 2');
        }
    }
    
    @isTest
    public static void updateThresholdTest(){
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
            
            GoNoGoSetting__c gonogosetting = GoNoGoSetting__c.getorgdefaults();
            gonogosetting.Default_Configuration_Name__c = 'Test Config';
            gonogosetting.Threshold_Score_for_Approval__c = 40;
            Database.upsert(gonogosetting);
            
            GoNoGoController.ResultWrapper response = GoNoGoController.updateThreshold(30,false);
            GoNoGoSetting__c gonogosetting1 = GoNoGoSetting__c.getorgdefaults();
            System.Assert(gonogosetting1.Threshold_Score_for_Approval__c == 30);
            System.Assert(gonogosetting1.Auto_Submit_for_Approval__c == false);
        }
    }
    
    @isTest
    public static void updateStatusValuesTest(){
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
            
            List<GoNoGoStatus__c> statusList = new List<GoNoGoStatus__c>();
            GoNoGoStatus__c status1 = new  GoNoGoStatus__c();
            status1.Name = 'Red';
            status1.Min_Range__c = 0;
            status1.Max_Range__c = 30;
            status1.Static_Resource_Name__c = 'red_status';
            statusList.add(status1);
    
            GoNoGoStatus__c status2 = new  GoNoGoStatus__c();
            status2.Name = 'Yellow';
            status2.Min_Range__c = 31;
            status2.Max_Range__c = 60;
            status2.Static_Resource_Name__c = 'yellow_status';
            statusList.add(status2);
            
            Database.insert(statusList,true);
            
            List<GoNoGoController.GoNoGoStatusWrapper> goNoGoStatusWrapperList = new List<GoNoGoController.GoNoGoStatusWrapper>();
            List<GoNoGoStatus__c> gonogostatuslist = [select id, Name, Min_Range__c, Max_Range__c, Static_Resource_Name__c from GoNoGoStatus__c WITH SECURITY_ENFORCED limit 49999];
            if(gonogostatuslist != null && gonogostatuslist.size() > 0){
                for(GoNoGoStatus__c gonogostatus : gonogostatuslist){
                    GoNoGoController.GoNoGoStatusWrapper goNoGoStatusWrapper = new GoNoGoController.GoNoGoStatusWrapper();
                    goNoGoStatusWrapper.statusid = gonogostatus.id;
                    goNoGoStatusWrapper.label = gonogostatus.Name;
                    goNoGoStatusWrapper.minrange = gonogostatus.Min_Range__c != null ? Integer.valueOf(gonogostatus.Min_Range__c) : null;
                    goNoGoStatusWrapper.maxrange = gonogostatus.Max_Range__c != null ? Integer.valueOf(gonogostatus.Max_Range__c) : null;
                    goNoGoStatusWrapper.staticresourcename = gonogostatus.Static_Resource_Name__c;
                    goNoGoStatusWrapperList.add(goNoGoStatusWrapper);
                }
            }
            
            GoNoGoController.ResultWrapper response = GoNoGoController.updateStatusValues(JSON.serialize(goNoGoStatusWrapperList),new List<String>{String.valueOf(status2.Id)});
            System.Assert(response.isSuccess == true);
        }
    }

    @isTest
    public static void getTotalMaxScoreTest(){
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
            
            GoNoGoController.PickListWrapper response = GoNoGoController.getTotalMaxScore(config.Id);
            System.Assert(response.label == 'Configuration');

            Go_No_Go_Section__c section = new Go_No_Go_Section__c();
            section.Name = 'Test Section';
            section.Go_No_Go_Configuration__c = config.Id;
            insert section;

            GoNoGoController.PickListWrapper response1 = GoNoGoController.getTotalMaxScore(section.Id);
            System.Assert(response1.label == 'Section');
        }
    }

    @isTest
    public static void saveNewConfigurationTest(){
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
            GoNoGoController.ResultWrapper response1 = GoNoGoController.saveNewConfiguration('abc',null);
            System.Assert(response1.isSuccess == true);
        }
    }

    @isTest
    public static void getSObjectListTest(){
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
            opp.Name = 'mytest';
            opp.StageName = 'IsWon';
            insert opp;
            
            List<Opportunity> response = GoNoGoController.getSObjectList('mytest','Opportunity');
            System.Assert(response != null);
        }
    }

    @isTest
    public static void fetchDefaultRecordTest(){
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
            opp.Name = 'mytest';
            opp.StageName = 'IsWon';
            insert opp;
            
            sObject response = GoNoGoController.fetchDefaultRecord(opp.Id,'Opportunity');
            System.Assert(response != null);
        }
    }

    @isTest
    public static void upsertQuestionRecordTest(){
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
            
            Map<String,Object> response = GoNoGoController.upsertQuestionRecord(null,section.Id,1,10,'Text','Test',false,'');
            System.Assert(response != null);
        }
    }

    @isTest
    public static void loadDataForGoNoGoQuestionTest(){
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
            
            GoNoGoController.GoNoGoQuestionWrapper response = GoNoGoController.loadDataForGoNoGoQuestion(question.Id);
            System.Assert(response != null);
        }
    }

    @isTest
    public static void createLinkedConifgTest(){
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

            List<String> configIdList = new List<String>();
            configIdList.add(config.Id);
            Boolean response = GoNoGoController.createLinkedConifg('MyTest',configIdList);
            System.Assert(response == true);
        }
    }

    @isTest
    public static void getLinkedConfigsTest(){
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
            
            Go_No_Go_Linked_Configuration__c linkedconfig = new Go_No_Go_Linked_Configuration__c();
            linkedconfig.Name = 'Test Linked';
            linkedconfig.Go_No_Go_Configuration__c = config.Id;
            insert linkedconfig;

            Opportunity opp = new Opportunity();
            opp.Closedate= System.today();
            opp.Name = 'test';
            opp.StageName = 'IsWon';
            insert opp;
            
            Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
            answer.Opportunity__c = opp.Id;
            insert answer;

            Go_No_Go_Linked_Submission__c linkedSubmission = new Go_No_Go_Linked_Submission__c();
            linkedSubmission.Go_No_Go_Submission__c = answer.Id;
            linkedSubmission.Go_No_Go_Configuration__c = config.Id;
            insert linkedSubmission;

            List<String> configIdList = new List<String>();
            configIdList.add(config.Id);
            GoNoGoController.LinkedConfigWrapperResult response = GoNoGoController.getLinkedConfigs(answer.Id,true);
            System.Assert(response != null);
        }
    }

    @isTest
    public static void getLinkedSubmissionsTest1(){
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
            
            Go_No_Go_Linked_Configuration__c linkedconfig = new Go_No_Go_Linked_Configuration__c();
            linkedconfig.Name = 'Test Linked';
            linkedconfig.Go_No_Go_Configuration__c = config.Id;
            insert linkedconfig;

            Opportunity opp = new Opportunity();
            opp.Closedate= System.today();
            opp.Name = 'test';
            opp.StageName = 'IsWon';
            insert opp;
            
            Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
            answer.Opportunity__c = opp.Id;
            insert answer;

            Go_No_Go_Linked_Submission__c linkedSubmission = new Go_No_Go_Linked_Submission__c();
            linkedSubmission.Go_No_Go_Submission__c = answer.Id;
            linkedSubmission.Go_No_Go_Configuration__c = config.Id;
            insert linkedSubmission;

            List<String> configIdList = new List<String>();
            configIdList.add(config.Id);
            List<GoNoGoController.LinkedSubmissionWrapper> response = GoNoGoController.getLinkedSubmissions(answer.Id);
            System.Assert(response != null);
        }
    }

    @isTest
    public static void getLinkedSubmissionsTest2(){
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

            Opportunity opp = new Opportunity();
            opp.Closedate= System.today();
            opp.Name = 'test';
            opp.StageName = 'IsWon';
            insert opp;
            
            Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
            answer.Opportunity__c = opp.Id;
            insert answer;

            List<GoNoGoController.LinkedSubmissionWrapper> response = GoNoGoController.getLinkedSubmissions(answer.Id);
            System.Assert(response != null);
        }
    }

    @isTest
    public static void getLinkedSubmissionsTest3(){
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
            
            Go_No_Go_Linked_Configuration__c linkedconfig = new Go_No_Go_Linked_Configuration__c();
            linkedconfig.Name = 'Test Linked';
            linkedconfig.Go_No_Go_Configuration__c = config.Id;
            insert linkedconfig;

            Opportunity opp = new Opportunity();
            opp.Closedate= System.today();
            opp.Name = 'test';
            opp.StageName = 'IsWon';
            insert opp;
            
            Go_No_Go_Answer__c answer = new Go_No_Go_Answer__c();
            answer.Opportunity__c = opp.Id;
            insert answer;

            Go_No_Go_Answer_Item__c ansItem = new Go_No_Go_Answer_Item__c();
            ansItem.Go_No_Go_Answer__c = answer.Id;
            ansItem.Value__c = 'test';
            ansItem.Go_No_Go_Question_Bank__c = question.Id;
            insert ansItem;


            Go_No_Go_Linked_Submission__c linkedSubmission = new Go_No_Go_Linked_Submission__c();
            linkedSubmission.Go_No_Go_Submission__c = answer.Id;
            linkedSubmission.Go_No_Go_Configuration__c = config.Id;
            insert linkedSubmission;

            List<String> configIdList = new List<String>();
            configIdList.add(config.Id);
            List<GoNoGoController.LinkedSubmissionWrapper> response = GoNoGoController.getLinkedSubmissions(answer.Id);
            System.Assert(response != null);
        }
    }

    @isTest
    public static void updateAsigneeNotificationTest(){
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
            GoNoGoController.ResultWrapper response = GoNoGoController.updateAsigneeNotification(true,'IsWon',true,3);
            System.Assert(response != null);
        }
    }

    @isTest
    public static void requestGoNoGoSubmissionTest(){
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
            
            Boolean response = GoNoGoController.requestGoNoGoSubmission(String.valueOf(opp.Id));
            System.Assert(response != null);
        }
    }

    @isTest
    public static void createReminderJobTest(){
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
            Test.startTest();
            GoNoGoController.createReminderJob();
            List<CronTrigger> jobList = [SELECT id from CronTrigger where CronJobDetail.name ='AutoSetup GoNoGoReminderNotificationJob' limit 1];
            System.Assert(jobList.size() == 1);
            Test.stopTest();
        }
    }

    @isTest
    public static void deleteReminderJobTest(){
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
            Test.startTest();
            GoNoGoController.deleteReminderJob();
            List<CronTrigger> jobList = [SELECT id from CronTrigger where CronJobDetail.name ='AutoSetup GoNoGoReminderNotificationJob' limit 1];
            System.Assert(jobList.size() == 0);
            Test.stopTest();
        }
    }
}