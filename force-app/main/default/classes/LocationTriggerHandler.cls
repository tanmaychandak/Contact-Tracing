public with sharing class LocationTriggerHandler {
    public static void beforeInsertHandler(List<Location__c> newLocationsList){
        for(Location__c location: newLocationsList){
            location.Status__c = 'Green';
        }
    }

    public static void beforeUpdateHandler(List<Location__c> newLocationsList, Map<id, Location__c> oldRecordMap){
        for(Location__c location: newLocationsList){
            if(location.Status__c != oldRecordMap.get(location.id).Status__c){
                location.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdateHandler(List<Location__c> newLocationsList, Map<id, Location__c> oldRecordMap){
        Set<Id> statusChange = new Set<Id>();

        for(Location__c location: newLocationsList){
            if(location.Status__c == 'Red' && oldRecordMap.get(location.id).Status__c != 'Red'){
                statusChange.add(location.id);
            }
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(statusChange);

        Set<Id> personIds = new Set<Id>();

        for(Location_Tracing__c trace: locationTraces){
            personIds.add(trace.Person__c);
        }

        List<Person__c> personToUpdate = new List<Person__c>();

        for(Id pid: personIds){
            personToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Yellow'));
        }

        
        if(!personToUpdate.isEmpty()){
            update personToUpdate;
        }
    }
}