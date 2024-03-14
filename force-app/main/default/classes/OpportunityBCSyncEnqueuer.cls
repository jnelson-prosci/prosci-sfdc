/**
 * @author CloudMasonry
 * @date 2021
 * @group Queueable
 * @description Initiates queueable job to call OpportunityBCSyncCalloutService
 */
public with sharing class OpportunityBCSyncEnqueuer {

    public void enqueue(List<Opportunity> lstOpps) {
        if(lstOpps.isEmpty()) { return; }

        List<Opportunity> lstOppsToUpdate = new List<Opportunity>();

        for (Opportunity opp : lstOpps) {
            lstOppsToUpdate.add(new Opportunity(Id = opp.Id, BC_Sync_Status__c = 'Queued'));
        }

        update lstOppsToUpdate;

        System.enqueueJob(new OpportunityBCSyncQueueable(new Map<Id, Opportunity>(lstOpps).keySet()));
    }
}