/**
 * @author CloudMasonry
 * @date 2021
 * @group Queueable
 * @description Enables async execution of ContactBCSyncCalloutService. Handles top level errors.
 */
public with sharing class ContactBCSyncQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> setConIds;
    private QueueableBatchManager batchManager;

    public ContactBCSyncQueueable(Set<Id> setConIds) {
        this(setConIds, new QueueableBatchManager(
            QueueableBatchManager.Context.Callout
            , new BCSyncDAO().getIntegrationConfigMap(ContactBCSyncCalloutService.INTEGRATION_CONFIG_NAME).size()));
    }

    @testVisible
    private ContactBCSyncQueueable(Set<Id> setConIds, QueueableBatchManager batchManager){
        this.setConIds = setConIds;
        this.batchManager = batchManager;
        this.batchManager.setIds(setConIds);
    }

    public void execute(QueueableContext context) {
        try {
            new ContactBCSyncCalloutService(this.batchManager.getBatchIds()).execute();
            if(!this.batchManager.getUnprocessedIds().isEmpty()){
                System.enqueueJob(new ContactBCSyncQueueable(this.batchManager.getUnprocessedIds()));
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