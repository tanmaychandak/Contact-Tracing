public with sharing class CTUpdateLocationStatusBatch implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id FROM Location__c WHERE Status__c != \'Green\' AND Status_Update_Date__c < LAST_N_DAYS:14');
    }
    
    public void execute(Database.BatchableContext BC, List<Location__c> scope){
        for(Location__c location: scope){
            location.Status__c = 'Green';
        }
        update scope;
    }
    
    
    public void finish(Database.BatchableContext BC){
        System.debug('Batch Finished');
    }
}