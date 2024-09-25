global without sharing class PostInstallClass implements InstallHandler {
    
    global void onInstall(InstallContext ic){
        
        try{
            List<Loopio_Ext__Go_No_Go_Configuration__c> configrecords = [select id from Loopio_Ext__Go_No_Go_Configuration__c limit 1];
            if(configrecords == null || configrecords.isEmpty()){
            	createDefaultDataForConfiguration();
            }
            List<Loopio_Ext__GoNoGoStatus__c> statusrecords = [select id from Loopio_Ext__GoNoGoStatus__c limit 1];
            if(statusrecords == null || statusrecords.isEmpty()){
            	createDefaultDataForGoNoGoStatus();
            }
        }catch(Exception e){}
    }

    @TestVisible
    private void createDefaultDataForConfiguration(){
        //insert configuration
        Loopio_Ext__Go_No_Go_Configuration__c config = new Loopio_Ext__Go_No_Go_Configuration__c();
        config.Name = 'Template Configuration';
        Database.insert(config);

        //insert sections
        List<Loopio_Ext__Go_No_Go_Section__c> sectionList = new List<Loopio_Ext__Go_No_Go_Section__c>();
        Loopio_Ext__Go_No_Go_Section__c section1 = new  Loopio_Ext__Go_No_Go_Section__c();
        section1.Name = 'Sales';
        section1.Loopio_Ext__Go_No_Go_Configuration__c = config.Id;
        section1.Loopio_Ext__Section_Sequence__c = 1;
        sectionList.add(section1);
        Loopio_Ext__Go_No_Go_Section__c section2 = new  Loopio_Ext__Go_No_Go_Section__c();
        section2.Name = 'RFP';
        section2.Loopio_Ext__Go_No_Go_Configuration__c = config.Id;
        section2.Loopio_Ext__Section_Sequence__c = 2;
        sectionList.add(section2);
        Database.insert(sectionList,true);

        //insert questions
        List<Loopio_Ext__Go_No_Go_Question_Bank__c> questionList = new List<Loopio_Ext__Go_No_Go_Question_Bank__c>();
        //for section 1 - Sales
        Loopio_Ext__Go_No_Go_Question_Bank__c question1 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question1.Loopio_Ext__Go_No_Go_Section__c = section1.Id;
        question1.Loopio_Ext__Question_Label__c = 'Is there an incumbent on this opportunity?';
        question1.Loopio_Ext__Data_Type__c = 'Dropdown';
        question1.Loopio_Ext__Question_Sequence__c = 1;
        question1.Loopio_Ext__Make_Required__c = true;
        questionList.add(question1);

        Loopio_Ext__Go_No_Go_Question_Bank__c question2 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question2.Loopio_Ext__Go_No_Go_Section__c = section1.Id;
        question2.Loopio_Ext__Question_Label__c = 'Who is the main competitor?';
        question2.Loopio_Ext__Data_Type__c = 'Dropdown';
        question2.Loopio_Ext__Question_Sequence__c = 2;
        question2.Loopio_Ext__Make_Required__c = true;
        questionList.add(question2);
        
        Loopio_Ext__Go_No_Go_Question_Bank__c question3 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question3.Loopio_Ext__Go_No_Go_Section__c = section1.Id;
        question3.Loopio_Ext__Question_Label__c = 'What is the term length? (in years)';
        question3.Loopio_Ext__Data_Type__c = 'Number';
        question3.Loopio_Ext__Question_Sequence__c = 3;
        question3.Loopio_Ext__Make_Required__c = true;
        questionList.add(question3);

        Loopio_Ext__Go_No_Go_Question_Bank__c question4 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question4.Loopio_Ext__Go_No_Go_Section__c = section1.Id;
        question4.Loopio_Ext__Question_Label__c = 'Do we need to team with another organization/partner to win?';
        question4.Loopio_Ext__Data_Type__c = 'Dropdown';
        question4.Loopio_Ext__Question_Sequence__c = 4;
        question4.Loopio_Ext__Make_Required__c = true;
        questionList.add(question4);

        Loopio_Ext__Go_No_Go_Question_Bank__c question5 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question5.Loopio_Ext__Go_No_Go_Section__c = section1.Id;
        question5.Loopio_Ext__Question_Label__c = 'Have we done business with the prospect before?';
        question5.Loopio_Ext__Data_Type__c = 'Dropdown';
        question5.Loopio_Ext__Question_Sequence__c = 5;
        question5.Loopio_Ext__Make_Required__c = false;
        questionList.add(question5);

        Loopio_Ext__Go_No_Go_Question_Bank__c question6 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question6.Loopio_Ext__Go_No_Go_Section__c = section1.Id;
        question6.Loopio_Ext__Question_Label__c = 'Do we have a long standing, positive professional relationship with the buyer?';
        question6.Loopio_Ext__Data_Type__c = 'Dropdown';
        question6.Loopio_Ext__Question_Sequence__c = 6;
        question6.Loopio_Ext__Make_Required__c = false;
        questionList.add(question6);

        //for section 2 - RFP
        Loopio_Ext__Go_No_Go_Question_Bank__c question7 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question7.Loopio_Ext__Go_No_Go_Section__c = section2.Id;
        question7.Loopio_Ext__Question_Label__c = 'Are the published RFP/contract terms and conditions acceptable?';
        question7.Loopio_Ext__Data_Type__c = 'Dropdown';
        question7.Loopio_Ext__Question_Sequence__c = 1;
        question7.Loopio_Ext__Make_Required__c = true;
        questionList.add(question7);

        Loopio_Ext__Go_No_Go_Question_Bank__c question8 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question8.Loopio_Ext__Go_No_Go_Section__c = section2.Id;
        question8.Loopio_Ext__Question_Label__c = 'Does the RFP show evidence of being influenced by competitors?';
        question8.Loopio_Ext__Data_Type__c = 'Dropdown';
        question8.Loopio_Ext__Question_Sequence__c = 2;
        question8.Loopio_Ext__Make_Required__c = false;
        questionList.add(question8);
        
        Loopio_Ext__Go_No_Go_Question_Bank__c question9 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question9.Loopio_Ext__Go_No_Go_Section__c = section2.Id;
        question9.Loopio_Ext__Question_Label__c = 'How many days does our team have to turnaround the RFP (from the date of intake)?';
        question9.Loopio_Ext__Data_Type__c = 'Number';
        question9.Loopio_Ext__Question_Sequence__c = 3;
        question9.Loopio_Ext__Make_Required__c = false;
        questionList.add(question9);

        Loopio_Ext__Go_No_Go_Question_Bank__c question10 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question10.Loopio_Ext__Go_No_Go_Section__c = section2.Id;
        question10.Loopio_Ext__Question_Label__c = 'Are we able to meet 80%+ of the core requirements?';
        question10.Loopio_Ext__Data_Type__c = 'Dropdown';
        question10.Loopio_Ext__Question_Sequence__c = 4;
        question10.Loopio_Ext__Make_Required__c = true;
        questionList.add(question10);

        Loopio_Ext__Go_No_Go_Question_Bank__c question11 = new Loopio_Ext__Go_No_Go_Question_Bank__c();
        question11.Loopio_Ext__Go_No_Go_Section__c = section2.Id;
        question11.Loopio_Ext__Question_Label__c = 'Additional comments and considerations for this proposal';
        question11.Loopio_Ext__Data_Type__c = 'Text';
        question11.Loopio_Ext__Question_Sequence__c = 5;
        question11.Loopio_Ext__Make_Required__c = false;
        questionList.add(question11);

        Database.insert(questionList,true);

        //insert scoring records
        List<Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c> scoringList = new List<Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c>();
        //for question 1 - Is there an incumbent on this opportunity?
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring1 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring1.Loopio_Ext__Go_No_Go_Question_Bank__c = question1.Id;
        scoring1.Loopio_Ext__Score__c = 1;
        scoring1.Loopio_Ext__Value__c = 'Yes';
        scoringList.add(scoring1);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring2 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring2.Loopio_Ext__Go_No_Go_Question_Bank__c = question1.Id;
        scoring2.Loopio_Ext__Score__c = 10;
        scoring2.Loopio_Ext__Value__c = 'No';
        scoringList.add(scoring2);

        //for question 2 - Who is the main competitor?
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring3 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring3.Loopio_Ext__Go_No_Go_Question_Bank__c = question2.Id;
        scoring3.Loopio_Ext__Score__c = 5;
        scoring3.Loopio_Ext__Value__c = 'None';
        scoringList.add(scoring3);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring4 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring4.Loopio_Ext__Go_No_Go_Question_Bank__c = question2.Id;
        scoring4.Loopio_Ext__Score__c = 3;
        scoring4.Loopio_Ext__Value__c = 'Lumen';
        scoringList.add(scoring4);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring5 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring5.Loopio_Ext__Go_No_Go_Question_Bank__c = question2.Id;
        scoring5.Loopio_Ext__Score__c = 1;
        scoring5.Loopio_Ext__Value__c = 'Optima';
        scoringList.add(scoring5);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring6 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring6.Loopio_Ext__Go_No_Go_Question_Bank__c = question2.Id;
        scoring6.Loopio_Ext__Score__c = 0;
        scoring6.Loopio_Ext__Value__c = 'Solis';
        scoringList.add(scoring6);

        //for question 3 - What is the term length? (in years)
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring7 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring7.Loopio_Ext__Go_No_Go_Question_Bank__c = question3.Id;
        scoring7.Loopio_Ext__Score__c = 1;
        scoring7.Loopio_Ext__Value__c = '1';
        scoringList.add(scoring7);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring8 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring8.Loopio_Ext__Go_No_Go_Question_Bank__c = question3.Id;
        scoring8.Loopio_Ext__Score__c = 3;
        scoring8.Loopio_Ext__Value__c = '2';
        scoringList.add(scoring8);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring9 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring9.Loopio_Ext__Go_No_Go_Question_Bank__c = question3.Id;
        scoring9.Loopio_Ext__Score__c = 5;
        scoring9.Loopio_Ext__Value__c = '3';
        scoringList.add(scoring9);

        //for question 4 - Do we need to team with another organization/partner to win?
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring10 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring10.Loopio_Ext__Go_No_Go_Question_Bank__c = question4.Id;
        scoring10.Loopio_Ext__Score__c = 1;
        scoring10.Loopio_Ext__Value__c = 'Yes';
        scoringList.add(scoring10);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring11 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring11.Loopio_Ext__Go_No_Go_Question_Bank__c = question4.Id;
        scoring11.Loopio_Ext__Score__c = 5;
        scoring11.Loopio_Ext__Value__c = 'No';
        scoringList.add(scoring11);

        //for question 5 - Have we done business with the prospect before?
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring12 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring12.Loopio_Ext__Go_No_Go_Question_Bank__c = question5.Id;
        scoring12.Loopio_Ext__Score__c = 5;
        scoring12.Loopio_Ext__Value__c = 'Yes';
        scoringList.add(scoring12);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring13 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring13.Loopio_Ext__Go_No_Go_Question_Bank__c = question5.Id;
        scoring13.Loopio_Ext__Score__c = 1;
        scoring13.Loopio_Ext__Value__c = 'No';
        scoringList.add(scoring13);

        //for question 6 - Do we have a long standing, positive professional relationship with the buyer?
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring14 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring14.Loopio_Ext__Go_No_Go_Question_Bank__c = question6.Id;
        scoring14.Loopio_Ext__Score__c = 20;
        scoring14.Loopio_Ext__Value__c = 'Yes';
        scoringList.add(scoring14);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring15 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring15.Loopio_Ext__Go_No_Go_Question_Bank__c = question6.Id;
        scoring15.Loopio_Ext__Score__c = 5;
        scoring15.Loopio_Ext__Value__c = 'No';
        scoringList.add(scoring15);

        //for question 7 - Are the published RFP/contract terms and conditions acceptable?
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring16 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring16.Loopio_Ext__Go_No_Go_Question_Bank__c = question7.Id;
        scoring16.Loopio_Ext__Score__c = 10;
        scoring16.Loopio_Ext__Value__c = 'Very Acceptable';
        scoringList.add(scoring16);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring17 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring17.Loopio_Ext__Go_No_Go_Question_Bank__c = question7.Id;
        scoring17.Loopio_Ext__Score__c = 5;
        scoring17.Loopio_Ext__Value__c = 'Neutral';
        scoringList.add(scoring17);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring18 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring18.Loopio_Ext__Go_No_Go_Question_Bank__c = question7.Id;
        scoring18.Loopio_Ext__Score__c = 0;
        scoring18.Loopio_Ext__Value__c = 'Not Acceptable';
        scoringList.add(scoring18);

        //for question 8 - Does the RFP show evidence of being influenced by competitors?
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring19 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring19.Loopio_Ext__Go_No_Go_Question_Bank__c = question8.Id;
        scoring19.Loopio_Ext__Score__c = 0;
        scoring19.Loopio_Ext__Value__c = 'Yes';
        scoringList.add(scoring19);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring20 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring20.Loopio_Ext__Go_No_Go_Question_Bank__c = question8.Id;
        scoring20.Loopio_Ext__Score__c = 10;
        scoring20.Loopio_Ext__Value__c = 'No';
        scoringList.add(scoring20);

        //for question 9 - How many days does our team have to turnaround the RFP (from the date of intake)?
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring21 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring21.Loopio_Ext__Go_No_Go_Question_Bank__c = question9.Id;
        scoring21.Loopio_Ext__Score__c = 10;
        scoring21.Loopio_Ext__Value__c = '10';
        scoringList.add(scoring21);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring22 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring22.Loopio_Ext__Go_No_Go_Question_Bank__c = question9.Id;
        scoring22.Loopio_Ext__Score__c = 5;
        scoring22.Loopio_Ext__Value__c = '5';
        scoringList.add(scoring22);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring23 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring23.Loopio_Ext__Go_No_Go_Question_Bank__c = question9.Id;
        scoring23.Loopio_Ext__Score__c = 3;
        scoring23.Loopio_Ext__Value__c = '2';
        scoringList.add(scoring23);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring24 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring24.Loopio_Ext__Go_No_Go_Question_Bank__c = question9.Id;
        scoring24.Loopio_Ext__Score__c = 1;
        scoring24.Loopio_Ext__Value__c = '1';
        scoringList.add(scoring24);

        //for question 10 - Are we able to meet 80%+ of the core requirements?
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring25 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring25.Loopio_Ext__Go_No_Go_Question_Bank__c = question10.Id;
        scoring25.Loopio_Ext__Score__c = 20;
        scoring25.Loopio_Ext__Value__c = 'Yes';
        scoringList.add(scoring25);
        Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c scoring26 = new Loopio_Ext__Go_No_Go_Question_Bank_Scoring__c();
        scoring26.Loopio_Ext__Go_No_Go_Question_Bank__c = question10.Id;
        scoring26.Loopio_Ext__Score__c = 5;
        scoring26.Loopio_Ext__Value__c = 'No';
        scoringList.add(scoring26);

        Database.insert(scoringList,true);

        //create default gonogosettings
        Loopio_Ext__GoNoGoSetting__c gonogosetting = Loopio_Ext__GoNoGoSetting__c.getOrgDefaults();
        gonogosetting.Loopio_Ext__Default_Configuration_Name__c = 'Template Configuration';
        gonogosetting.Loopio_Ext__Threshold_Score_for_Approval__c = 50;
        Database.upsert(gonogosetting);
    }

    @TestVisible
    private void createDefaultDataForGoNoGoStatus(){
        //insert statuses
        List<Loopio_Ext__GoNoGoStatus__c> statusList = new List<Loopio_Ext__GoNoGoStatus__c>();
        Loopio_Ext__GoNoGoStatus__c status1 = new  Loopio_Ext__GoNoGoStatus__c();
        status1.Name = 'Red';
        status1.Loopio_Ext__Min_Range__c = 0;
        status1.Loopio_Ext__Max_Range__c = 30;
        status1.Loopio_Ext__Static_Resource_Name__c = 'red_status';
        statusList.add(status1);

        Loopio_Ext__GoNoGoStatus__c status2 = new  Loopio_Ext__GoNoGoStatus__c();
        status2.Name = 'Yellow';
        status2.Loopio_Ext__Min_Range__c = 31;
        status2.Loopio_Ext__Max_Range__c = 60;
        status2.Loopio_Ext__Static_Resource_Name__c = 'yellow_status';
        statusList.add(status2);

        Loopio_Ext__GoNoGoStatus__c status3 = new  Loopio_Ext__GoNoGoStatus__c();
        status3.Name = 'Green';
        status3.Loopio_Ext__Min_Range__c = 61;
        status3.Loopio_Ext__Max_Range__c = 100;
        status3.Loopio_Ext__Static_Resource_Name__c = 'green_status';
        statusList.add(status3);

        Database.insert(statusList,true);
    }
}