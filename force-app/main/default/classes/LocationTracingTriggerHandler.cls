public with sharing class LocationTracingTriggerHandler {
    public static void beforeInsertHandler(List<Location_Tracing__c> newRecordsList){
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(newRecordsList);

        for(Location_Tracing__c trace : duplicates) {
            trace.addError('Duplicate record found. Location Id:'+trace.Location__c+' Person Id:'+trace.Person__c);
        }
    }
}