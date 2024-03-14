trigger ContactTrigger on Contact (after update) {
    new ContactTriggerHandler(trigger.new, trigger.oldMap).execute();
}