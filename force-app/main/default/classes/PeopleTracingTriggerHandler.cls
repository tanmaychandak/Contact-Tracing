public with sharing class PeopleTracingTriggerHandler {
    public static void beforeInsertHandler(List<People_Tracing__c> newRecordsList){
        List<People_Tracing__c> duplicates = CTPeopleTracingController.checkDuplicates(newRecordsList);

        for(People_Tracing__c trace : duplicates){
            trace.addError('Duplicate record found. Person 1:'+trace.Person_1__c+' Person 2:'+trace.Person_2__c);
        }
    }
}