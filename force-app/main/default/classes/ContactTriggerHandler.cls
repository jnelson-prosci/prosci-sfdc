/**
 * Contact Trigger Handler to orchestrate business logic on Contact CRUD operations
 */
public with sharing class ContactTriggerHandler extends TriggerHandler{

    private List<Contact> lstNewRecords;
    private Map<Id, Contact> mapOldRecords;

    @testVisible
    public static Boolean byPass = false;

    public ContactTriggerHandler(List<Contact> lstNewRecords, Map<Id, Contact> mapOldRecords) {
        this.lstNewRecords = lstNewRecords;
        this.mapOldRecords = mapOldRecords;
    }

    protected override void afterUpdate() {
        if (byPass) { return; }

        new ContactBCSyncEnqueuer().enqueue(
            new ContactBCSyncFilter().filterRecords(lstNewRecords, mapOldRecords));
    }
}