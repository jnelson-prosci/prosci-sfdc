/**
 * @author CloudMasonry
 * @date 2021
 * @group Filter
 * @description Filters Opportunity Records for processing by OpportunityBCSyncCalloutService
 */
public with sharing class OpportunityBCSyncFilter {

    @testVisible
    private static final String STATUS_PENDING_SYNC = 'Pending Sync';

    public List<Opportunity> filterRecords (List<Opportunity> lstNewRecords, Map<Id, Opportunity> mapOldRecords) {
        List<Opportunity> lstFilteredRecords = new List<Opportunity>();
        
        for (Opportunity opportunity : lstNewRecords) {
            Opportunity oldOpportunity = mapOldRecords.get(opportunity.Id);

            if (opportunity.BC_Sync_Status__c == STATUS_PENDING_SYNC
                && opportunity.BC_Sync_Status__c != oldOpportunity.BC_Sync_Status__c) {
                lstFilteredRecords.add(opportunity);
            }
        }
        
        return lstFilteredRecords;
    }
}