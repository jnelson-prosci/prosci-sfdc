/**
 * @author CloudMasonry
 * @date 2021
 * @group Queueable
 * @description Enables async execution of OpportunityBCSyncCalloutService. Handles top level errors.
 */
public with sharing class OpportunityBCSyncQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> setOppIds;
    private QueueableBatchManager batchManager;
    private static final Integer MAX_CALLOUTS_PER_RECORD = 2;

    public OpportunityBCSyncQueueable (Set<Id> setOppIds) {
        this(setOppIds, new QueueableBatchManager(QueueableBatchManager.Context.Callout, MAX_CALLOUTS_PER_RECORD));
    }

    @testVisible
    private OpportunityBCSyncQueueable(Set<Id> setOppIds, QueueableBatchManager batchManager){
        this.setOppIds = setOppIds;
        this.batchManager = batchManager;
        this.batchManager.setIds(setOppIds);
    }

    public void execute(QueueableContext context) {

        try {
            new OpportunityBCSyncCalloutService(this.batchManager.getBatchIds()).execute();
            if(!this.batchManager.getUnprocessedIds().isEmpty()){
                System.enqueueJob(new OpportunityBCSyncQueueable(this.batchManager.getUnprocessedIds()));
            }
        } catch (Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            insert new Error_Log__c(
            	Error_Message__c = ex.getMessage()
                , Stacktrace__c = ex.getStackTraceString()
                , Associated_Records__c = JSON.serialize(this.setOppIds)
                , Exception_Type__c = ex.getTypeName()
                , Category__c = OpportunityBCSyncCalloutService.EXCEPTION_CATEGORY
            );
        }
    }
}