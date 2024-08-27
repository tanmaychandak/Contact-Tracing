public with sharing class CTLocationController {
    public static List<Location__c> getRecentStatusChanges() {
        return [SELECT Name, Id, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    public static List<Location__c> searchLocations(String searchTerm){

        searchTerm = '%' + searchTerm + '%'; //searchTerm is given by {AUTHOR_PLACEHOLDER}

        return [SELECT Name, Id, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c 
                WHERE Name LIKE :searchTerm OR 
                           Address__c LIKE :searchTerm OR 
                           Pincode__c LIKE :searchTerm 
                ORDER BY Status_Update_Date__c 
                DESC NULLS LAST];
    }
    
    public static Location__c getLocationById(String locationId){

        if(String.isBlank(locationId)){
            return null;
        }
        List<Location__c> locations = [SELECT Name, Id, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                                        FROM Location__c 
                                        WHERE Id =: locationId];

        if(locations != null && locations.size() > 0){
            return locations[0];
        }
        return null;
    }

    public static Map<String, Integer> getStatusCount(){

        Map<String, Integer> mapOfHealthCount = new Map<String, Integer>();

        AggregateResult[] healthCountList = [SELECT Status__c, Count(Id) total 
                                            FROM Location__c 
                                            GROUP BY Status__c];
        
        for(AggregateResult health: healthCountList){

            String healthStatus = String.valueOf(health.get('Status__c'));
            Integer count = Integer.valueOf(health.get('total'));

            mapOfHealthCount.put(healthStatus, count);
        }

        return mapOfHealthCount;
    }

    public static void updateRedScore(Set<Id> locationIds){
        List<Location__c> locationToUpdate = new List<Location__c>();

        AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id) total 
                                        FROM Location_Tracing__c 
                                        WHERE Person__r.Health_Status__c = 'Red' AND 
                                        Visit_Date__c = LAST_N_DAYS:10 AND Location__c IN :locationIds
                                        Group By Location__c];
        
        for(AggregateResult ar : redPeoplePerLocation){
            String locationId = String.valueOf(ar.get('Location__c'));
            Integer redScore = Integer.valueOf(ar.get('total'));
            String status = CTLocationController.getStatus(redScore);

            locationToUpdate.add(new Location__c(Id=locationId, Red_Score__c=redScore, Status__c=status));
        }

        if(locationToUpdate != null && locationToUpdate.size() > 0){
            update locationToUpdate;
        }

    }

    public static String getStatus(Integer redScore){
        if(redScore == 0){
            return 'Green';
        }else if(redScore <= 5){
            return 'Yellow';
        }else if(redScore <= 10){
            return 'Orange';
        }else{
            return 'Red';
        }
    }

    // public static Map<String, Integer> getHealthStatusCount(){
    //     AggregateResult[] healthCountMap = [SELECT Status__c, COUNT(Id) total
    //                                         FROM Location_c
    //                                         GROUP BY Health_Status__c];
        
    //     if(healthCountMap != null && healthCountMap.size() > 0){
    //         Map<String, Integer> result = new Map<String, Integer>();
    //         for(AggregateResult ar : healthCountMap){
    //             result.put(String.valueOf(ar.get('Status__c')), Integer.valueOf(ar.get('total')));
    //         }

    //         return result;
    //     }

    //     return null;
    // }
}