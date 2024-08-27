public with sharing class CTPersonController {

    public static String getToken(String mobile){
        Blob mobileHash = Crypto.generateDigest('MD5', Blob.valueOf(mobile));

        //get the string value of hash blob
        return EncodingUtil.base64Encode(mobileHash);
    }

    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    public static List<Person__c> searchPeople(String searchTerm){

        searchTerm = searchTerm + '%'; //searchTerm is given by {AUTHOR_PLACEHOLDER}
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                FROM Person__c 
                WHERE Name LIKE :searchTerm OR 
                      Mobile__c LIKE :searchTerm OR 
                      Token__c LIKE :searchTerm 
                ORDER BY Status_Update_Date__c 
                DESC NULLS LAST];
    }

    public static Person__c getPersonById(String personId){
        List<Person__c> people =  [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                                    FROM Person__c 
                                    WHERE Id = :personId];

        if(people != null && people.size() > 0){
            return people[0];
        }

        return null;
    }

    public static Map<String, Integer> getHealthStatusCount(){
        Map<String, Integer> mapOfHealthCount = new Map<String, Integer>();
        
        AggregateResult[] people = [SELECT Health_Status__c, COUNT(Id) count_of_people FROM Person__c GROUP BY Health_Status__c];
       
        for(AggregateResult person : people){
            mapOfHealthCount.put(String.valueOf(person.get('Health_Status__c')), Integer.valueOf(person.get('count_of_people')));
        }
    
        return mapOfHealthCount;
    }

    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed){
        Set<Id> cohabitants = new Set<Id>();
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                    AND Contact_Type__c = 'Cohabitant'
                                                    AND (Person_1__r.Health_Status__c IN :healthStatuses OR 
                                                        Person_2__r.Health_Status__c IN :healthStatuses)];

        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if(!alreadyProcessed.contains(pt.Person_2__c)){
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return cohabitants;
    }

    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed){
        Set<Id> neighbours = new Set<Id>();
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                    AND Contact_Type__c = 'Neighbour'
                                                    AND (Person_1__r.Health_Status__c = 'Green' OR 
                                                        Person_2__r.Health_Status__c ='Green')];

        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                neighbours.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if(!alreadyProcessed.contains(pt.Person_2__c)){
                neighbours.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return neighbours;
    }

    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed){
        Set<Id> primaryContacts = new Set<Id>();
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                    AND Contact_Type__c = 'Other'
                                                    AND Contact_Date__c = LAST_N_DAYS:10
                                                    AND (Person_1__r.Health_Status__c IN :healthStatuses OR 
                                                        Person_2__r.Health_Status__c IN :healthStatuses)];

        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if(!alreadyProcessed.contains(pt.Person_2__c)){
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return primaryContacts;
    }

    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactsIds, Set<Id> alreadyProcessed){
        Set<Id> secondaryContacts = new Set<Id>();
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN :primaryContactsIds OR Person_2__c IN :primaryContactsIds)
                                                    AND Contact_Type__c = 'Other'
                                                    AND Contact_Date__c = LAST_N_DAYS:10
                                                    AND (Person_1__r.Health_Status__c = 'Green' OR 
                                                        Person_2__r.Health_Status__c = 'Green')];

        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if(!alreadyProcessed.contains(pt.Person_2__c)){
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return secondaryContacts;
    }

    // public static Map<String, Integer> getHealthStatusCount(){
    //     AggregateResult[] healthCountMap = [SELECT Health_Status__c, COUNT(Id) total
    //                                         FROM Person__c
    //                                         GROUP BY Health_Status__c];
        
    //     if(healthCountMap != null && healthCountMap.size() > 0){
    //         Map<String, Integer> result = new Map<String, Integer>();
    //         for(AggregateResult ar : healthCountMap){
    //             result.put(String.valueOf(ar.get('Health_Status__c')), Integer.valueOf(ar.get('total')));
    //         }

    //         return result;
    //     }

    //     return null;
    // }

}