public with sharing class CTUpdatePersonStatusBatch implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        // List<Person__c> query = 'SELECT Id FROM Person__c WHERE Health_Status__c != \'Green\' and Status_Update_Date__c < LAST_N_DAYS:14';
        return Database.getQueryLocator('SELECT Id FROM Person__c WHERE Health_Status__c != \'Green\' and Status_Update_Date__c < LAST_N_DAYS:14');
    }
    
    public void execute(Database.BatchableContext BC, List<Person__c> scope){
        for(Person__c person: scope){
            person.Health_Status__c = 'Green';
        }

        update scope;
    }
    
    
    public void finish(Database.BatchableContext BC){
        System.debug('Batch Finished');
    }
}