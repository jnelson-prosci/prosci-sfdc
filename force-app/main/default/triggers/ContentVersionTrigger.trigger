trigger ContentVersionTrigger on ContentVersion (after insert) {
	new ContentVersionTriggerHandler(trigger.new, trigger.oldMap).execute();
}