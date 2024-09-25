@isTest
public with sharing class CustomCommentFeederControllerTest {
    
    @isTest
    public static void createFeedItemRecTest1(){
        Contact c = new Contact();
        c.firstname = 'abc';
        c.lastname = 'xyz';
        insert c;
        Boolean result = CustomCommentFeederController.createFeedItemRec(new List<String>{String.valueOf(c.Id)},'test',null);
        System.assertEquals(true,result);
    }
    
    @isTest
    public static void createFeedItemRecTest2(){
        Contact c = new Contact();
        c.firstname = 'abc';
        c.lastname = 'xyz';
        insert c;
        String text = '<p>asd asdn asa sda da<img src="https://avnio-mdo--mdobuild1.sandbox.file.force.com/servlet/rtaImage?refid=0EM1s000000M2Xa"><img src="https://avnio-mdo--mdobuild1.sandbox.file.force.com/servlet/rtaImage?refid=0EM1s000000M2Xg"><img src="https://avnio-mdo--mdobuild1.sandbox.file.force.com/servlet/rtaImage?refid=0EM1s000000M2Xf"></p>';
        Boolean result = CustomCommentFeederController.createFeedItemRec(new List<String>{String.valueOf(c.Id)},text,null);
        System.assertEquals(false,result);
    }
    
    @isTest
    public static void dummytest(){
        CustomCommentFeederController.dummymethod();
    }

    @isTest
    public static void getUsersTest(){
        Map<Id,String> result = CustomCommentFeederController.getUsers();
    }
}