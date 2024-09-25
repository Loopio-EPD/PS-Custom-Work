@isTest(SeeAllData=false)
public with sharing class PostInstallClassTest {
    
    static testmethod void testInstallScript(){
        Test.startTest();
        try{
            PostInstallClass postinstall = new PostInstallClass();
            Test.testInstall(postinstall, new Version(1,60), false);
        } catch (Exception e) {
            System.assert(false);
        }
        Test.stopTest();
	}
}