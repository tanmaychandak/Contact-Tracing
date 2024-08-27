trigger PersonTrigger on Person__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            PersonTriggerHandler.beforeInsertHandler(Trigger.new);
        }

        when BEFORE_UPDATE {
            // Process before update
            PersonTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            PersonTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }

}