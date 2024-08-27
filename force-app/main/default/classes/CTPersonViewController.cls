public with sharing class CTPersonViewController {
    @AuraEnabled
    public static void updateHealthStatus(String personId){
        Person__c personObj = new Person__c(Id=personId);
        personObj.Health_Status__c = 'Red';
        update personObj;
    }
}