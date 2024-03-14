trigger CustomerProductTrigger on Customer_Product__c (after insert) {
    new CustomerProductTriggerHandler(trigger.new, trigger.oldMap).execute();
}