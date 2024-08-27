trigger LocationTrigger on Location__c (before insert, after insert, before update, after update) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            LocationTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        when BEFORE_UPDATE {
            LocationTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            LocationTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}