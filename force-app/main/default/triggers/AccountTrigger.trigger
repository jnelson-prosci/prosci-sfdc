trigger AccountTrigger on Account (after update) {
	new AccountTriggerHandler(trigger.new, trigger.oldMap).execute();
}