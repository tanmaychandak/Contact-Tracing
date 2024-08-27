public with sharing class CTLocationTracingDataCleanupBatch implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        // String query = 'SELECT Id FROM Location_Tracing__c WHERE Visit_Date__c < LAST_N_DAYS:30';
        return Database.getQueryLocator('SELECT Id FROM Location_Tracing__c WHERE Visit_Date__c < LAST_N_DAYS:30');
    }
    
    public void execute(Database.BatchableContext BC, List<Location_Tracing__c> scope){
        delete scope;
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Batch Finished');
    }
}