trigger projecttrigger on avnio__Project__c (before insert, before update,after insert, after update) {
   if(Trigger.isbefore && Trigger.isinsert) {
       projecttriggerhandler.beforeinsert(Trigger.oldmap,Trigger.newMap);
   }
   if(Trigger.isbefore && Trigger.isupdate) {
       projecttriggerhandler.beforeupdate(Trigger.oldmap,Trigger.newMap);
   }
   if(Trigger.isAfter && Trigger.isinsert) {
       projecttriggerhandler.afterinsert(Trigger.oldmap,Trigger.newMap);
   }
   if(Trigger.isAfter && Trigger.isupdate) {
       projecttriggerhandler.afterupdate(Trigger.oldmap,Trigger.newMap);
   }
}