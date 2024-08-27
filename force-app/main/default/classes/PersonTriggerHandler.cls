public with sharing class PersonTriggerHandler {
    public static void beforeInsertHandler(List<Person__c> newPersonsList){
        for(Person__c person: newPersonsList){
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    public static void beforeUpdateHandler(List<Person__c> newPersonsList, Map<Id,Person__c> oldPersonsMap){
        for(Person__c person: newPersonsList){
            if(person.Health_Status__c != oldPersonsMap.get(person.id).Health_Status__c){
                person.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdateHandler(List<Person__c> newPersonsList, Map<Id,Person__c> oldPersonsMap){
        Set<Id> statusChange = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();

        for(Person__c person: newPersonsList){
            if(person.Health_Status__c != oldPersonsMap.get(person.id).Health_Status__c){
               statusChange.add(person.id);
            }

            if(person.Health_Status__c == 'Red' && oldPersonsMap.get(person.id).Health_Status__c != 'Red'){
               redStatus.add(person.id);
            }
        }

        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(redStatus);

        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        List<Person__c> persontoUpdate = new List<Person__c>();
        
        //add cojabitants
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));

         //add primary contacts
         Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
         orangeStatus.addAll(primaryContacts);

        //add neighbours
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));

        //add secondary contacts
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessed));


        for(Id pid: orangeStatus){
            persontoUpdate.add(new Person__c(Id=pid, Health_Status__c='Orange'));
        }

        for(Id pid: yellowStatus){
            persontoUpdate.add(new Person__c(Id=pid, Health_Status__c='Yellow'));
        }

        if(persontoUpdate.size() > 0){
            update personToUpdate;
        }
        
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(statusChange);

        if(locationTraces != null && locationTraces.size() > 0){
            Set<Id> locationIds = new Set<Id>();
            for(Location_Tracing__c trace : locationTraces){
                locationIds.add(trace.Location__c);
            }

            CTLocationController.updateRedScore(locationIds);
        }
    }
}