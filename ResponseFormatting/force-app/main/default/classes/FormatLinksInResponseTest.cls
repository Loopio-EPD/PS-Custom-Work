@isTest
public with sharing class FormatLinksInResponseTest {
    
    @isTest
    public static void FormatLinksInResponseBatchTes1t(){
        Test.startTest();
        avnio__Response__c response = new avnio__Response__c();
        response.avnio__PrimaryQuestion__c = 'test q';
        response.avnio__Answer__c = '<p><span style="font-family: sans-serif; font-size: 12px;"> http://abc.com Yes, this is a core functionality of Salesforce and Vlocity. When using OmniScript, “Next” and “Previous” buttons exist to help customers navigate through the guided process. </span></p>';
        insert response;
        FormatLinksInResponse ba = new FormatLinksInResponse('avnio__Response__c');
        Database.executebatch(ba);
        Test.stopTest();
        List<avnio__Response__c> resp = [select id,Links_Formatting_Required__c from avnio__Response__c];
        System.assertEquals(true,resp[0].Links_Formatting_Required__c);
    }

    @isTest
    public static void FormatLinksInResponseBatchTest2(){
        Test.startTest();
        avnio__Response__c response = new avnio__Response__c();
        response.avnio__PrimaryQuestion__c = 'test q';
        response.avnio__Answer__c = '<p><span style="font-family: sans-serif; font-size: 12px;">Yes, this is a core functionality of Salesforce and Vlocity. When using OmniScript, https://abcd.com “Next” and “Previous” buttons exist to help customers navigate through the guided process. </span></p>';
        insert response;
        FormatLinksInResponse ba = new FormatLinksInResponse('avnio__Response__c');
        Database.executebatch(ba);
        Test.stopTest();
        List<avnio__Response__c> resp = [select id,Links_Formatting_Required__c from avnio__Response__c];
        System.assertEquals(true,resp[0].Links_Formatting_Required__c);
    }


    @isTest
    public static void FormatLinksInResponseBatchTest3(){
        Test.startTest();
        avnio__Response__c response = new avnio__Response__c();
        response.avnio__PrimaryQuestion__c = 'test q';
        response.avnio__Answer__c = '<a href="http://www.salesforce.com/company/commitment-to-education/" target="_blank" style="background-color: transparent; color: rgb(17, 85, 204); font-size: 11pt;"><u>commitment to education</u></a> <img src="http://lh6.googleusercontent.com/vpZDbAtAG7CODfiuP5mH9UmCsT82PUQBMSroKAl0s838wNXTtFTcSY6_SS1Lht0HikoYsj8xVxOCSoPI2xuzM_KI0bczyF0Hm6HunkUB70RcmqjlxpmetYti9KVySGFoHZB6A-sbI1B7"></img>';
        insert response;
        FormatLinksInResponse ba = new FormatLinksInResponse('avnio__Response__c');
        Database.executebatch(ba);
        Test.stopTest();
        List<avnio__Response__c> resp = [select id,Links_Formatting_Required__c from avnio__Response__c];
        System.assertEquals(false,resp[0].Links_Formatting_Required__c);
    }

    @isTest
    public static void FormatLinksInResponseBatchTest4(){
        Test.startTest();
        avnio__Response__c response = new avnio__Response__c();
        response.avnio__PrimaryQuestion__c = 'test q';
        response.avnio__Answer__c = '<a href="https://www.salesforce.com/company/commitment-to-education/" target="_blank" style="background-color: transparent; color: rgb(17, 85, 204); font-size: 11pt;"><u>commitment to education</u></a> <img src="https://lh6.googleusercontent.com/vpZDbAtAG7CODfiuP5mH9UmCsT82PUQBMSroKAl0s838wNXTtFTcSY6_SS1Lht0HikoYsj8xVxOCSoPI2xuzM_KI0bczyF0Hm6HunkUB70RcmqjlxpmetYti9KVySGFoHZB6A-sbI1B7"></img>';
        insert response;
        FormatLinksInResponse ba = new FormatLinksInResponse('avnio__Response__c');
        Database.executebatch(ba);
        Test.stopTest();
        List<avnio__Response__c> resp = [select id,Links_Formatting_Required__c from avnio__Response__c];
        System.assertEquals(false,resp[0].Links_Formatting_Required__c);
    }
    
}