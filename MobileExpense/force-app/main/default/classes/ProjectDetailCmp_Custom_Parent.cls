public with sharing class ProjectDetailCmp_Custom_Parent {

    public String recordId {get; set;}
    
    public  avnio__Project__c response{get{
        avnio__Project__c res = new avnio__Project__c();
        List<avnio__ProjectQuestion__c> projectQues = new List<avnio__ProjectQuestion__c>  ();
        projectQues = [select id, avnio__ProjectId__c   from avnio__ProjectQuestion__c where id=:recordId ];
        
        if(projectQues != null && projectQues.size() > 0) {
        List<String> fields = new List<String>(avnio__Project__c.SObjectType.getDescribe().fields.getMap().keySet());
        Id projid = projectQues[0].avnio__ProjectId__c;
        String soql = ''
                + ' select ' + String.join(fields, ',')
                + ' from avnio__Project__c'
                + ' where id=:projid';
        res = Database.query(soql);
        }
        
        return res;
    }}
    

}