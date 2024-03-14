/**
 * Opportunity Trigger Handler to orchestrate business logic on Opportunity CRUD operations
 */
public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    private List<Opportunity> lstNewRecords;
    private Map<Id, Opportunity> mapOldRecords;

    @testVisible
    private static Boolean byPass = false;

    public OpportunityTriggerHandler(List<Opportunity> lstNewRecords, Map<Id, Opportunity> mapOldRecords) {
        this.lstNewRecords = lstNewRecords;
        this.mapOldRecords = mapOldRecords;
    }

    protected override void afterUpdate() {
        if (byPass) { return; }
        
        new OpportunityBCSyncEnqueuer().enqueue(
            new OpportunityBCSyncFilter().filterRecords(lstNewRecords, mapOldRecords));
          
    }
}