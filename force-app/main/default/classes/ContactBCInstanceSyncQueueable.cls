/**
 * @author CloudMasonry
 * @date 2021
 * @group Queueable
 * @description Enables async execution of ContactBCSyncCalloutService. Handles top level errors.
 */
public with sharing class ContactBCInstanceSyncQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> setConIds;
    private QueueableBatchManager batchManager;
    private String strBCInstance;

    public ContactBCInstanceSyncQueueable(Set<Id> setConIds, String strBCInstance) {
        this(setConIds, strBCInstance, new QueueableBatchManager(QueueableBatchManager.Context.Callout, 1));
    }

    @testVisible
    private ContactBCInstanceSyncQueueable(Set<Id> setConIds, String strBCInstance, QueueableBatchManager batchManager){
        this.setConIds = setConIds;
        this.strBCInstance = strBCInstance;
        this.batchManager = batchManager;
        this.batchManager.setIds(setConIds);
    }

    public void execute(QueueableContext context) {
        try {
            new ContactBCSyncCalloutService(this.batchManager.getBatchIds()).execute(this.strBCInstance);
            if(!this.batchManager.getUnprocessedIds().isEmpty()){
                System.enqueueJob(new ContactBCInstanceSyncQueueable(this.batchManager.getUnprocessedIds(), this.strBCInstance));
            }
        } catch (Exception ex){
            insert new Error_Log__c(
                Error_Message__c = ex.getMessage()
                , Stacktrace__c = ex.getStackTraceString()
                , Associated_Records__c = JSON.serialize(this.setConIds)
                , Exception_Type__c = ex.getTypeName()
                , Category__c = ContactBCSyncCalloutService.EXCEPTION_CATEGORY
            );
        }
    }
}