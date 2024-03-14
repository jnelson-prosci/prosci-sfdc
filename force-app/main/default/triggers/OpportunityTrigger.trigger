trigger OpportunityTrigger on Opportunity (after update) {
	new OpportunityTriggerHandler(trigger.new, trigger.oldMap).execute();
}