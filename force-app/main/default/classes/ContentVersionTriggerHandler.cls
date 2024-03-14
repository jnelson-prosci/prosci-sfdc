/**
 * ContentVersion Trigger Handler to orchestrate business logic on ContentVersion CRUD operations
 */
public with sharing class ContentVersionTriggerHandler extends TriggerHandler {

    private List<ContentVersion> lstNewRecords;
    private Map<Id, ContentVersion> mapOldRecords;

    @testVisible
    public static Boolean byPass = false;

    public ContentVersionTriggerHandler(List<ContentVersion> lstNewRecords, Map<Id, ContentVersion> mapOldRecords) {
        this.lstNewRecords = lstNewRecords;
        this.mapOldRecords = mapOldRecords;
    }

    protected override void afterInsert() {
        if (byPass) { return; }

        new ContentVersionRedlinesReturnedService().execute(new ContentVersionRedlinesReturnedFilter().filterRecords(lstNewRecords));

    }
}