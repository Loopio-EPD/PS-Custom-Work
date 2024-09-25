@isTest
public class RetrieveAndProcessCompaniesTest {

    @testSetup
    private static void createData(){
        hubspot_integration__c integrationSetting = hubspot_integration__c.getOrgDefaults();
        integrationSetting.Access_Token__c = 'abc';
        integrationSetting.API_Endpoint__c = 'apiendpoint';
        integrationSetting.Hubspot_Org_URL__c = 'abc/xyz';
        upsert integrationSetting;
        List<Recordtype> rtypeList = [select id, name, SobjectType, isactive from recordtype where SobjectType='avnio__Project__c' and isactive=true];
        avnio__Project__c project = new avnio__Project__c();
        project.avnio__ProjectName__c = 'Test Project';
        project.avnio__DueDate__c = Datetime.now();
        project.avnio__Status__c = 'Request';
        project.Hubspot_Deal_Id__c = '1273';
        project.recordTypeId = rtypeList[0].Id;
        insert project;
    }
    
    @isTest
    public static void executeTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CompaniesCalloutMock());
        String sch1 = '0 0 * * * ?';
        RetrieveCompaniesSchedular  sqrb1 = new RetrieveCompaniesSchedular ();
        system.schedule('Retrieve Companies 0 min', sch1, sqrb1);
        Test.stopTest();
    }
    
    public with sharing class CompaniesCalloutMock implements HttpCalloutMock {
        public HttpResponse respond( HttpRequest req ) {
            String endpoint = req.getEndpoint(); 
            HttpResponse res = new HttpResponse();
            res.setBody('{"total":1,"results":{"id":"1"}}'); 
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}