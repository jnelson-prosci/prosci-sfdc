/**
 * @author CloudMasonry
 * @date 2021
 * @group Queueable
 * @description Enables async execution of AccountBCSyncCalloutService. Handles top level errors.
 */
public with sharing class AccountBCInstanceSyncQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> setAcctIds;
    private QueueableBatchManager batchManager;
    private String strBCInstance;

    public AccountBCInstanceSyncQueueable(Set<Id> setAcctIds, String strBCInstance) {
        this(setAcctIds, strBCInstance, new QueueableBatchManager(QueueableBatchManager.Context.Callout, 1));
    }

    @testVisible
    private AccountBCInstanceSyncQueueable(Set<Id> setAcctIds, String strBCInstance, QueueableBatchManager batchManager){
        this.setAcctIds = setAcctIds;
        this.strBCInstance = strBCInstance;
        this.batchManager = batchManager;
        this.batchManager.setIds(setAcctIds);
    }

    public void execute(QueueableContext context) {
        try {
            new AccountBCSyncCalloutService(this.batchManager.getBatchIds()).execute(this.strBCInstance);
            if(!this.batchManager.getUnprocessedIds().isEmpty()){
                System.enqueueJob(new AccountBCInstanceSyncQueueable(this.batchManager.getUnprocessedIds(), this.strBCInstance));
            }
        } catch (Exception ex){
            insert new Error_Log__c(
                Error_Message__c = ex.getMessage()
                , Stacktrace__c = ex.getStackTraceString()
                , Associated_Records__c = JSON.serialize(this.setAcctIds)
                , Exception_Type__c = ex.getTypeName()
                , Category__c = AccountBCSyncCalloutService.EXCEPTION_CATEGORY
            );
        }
    }
}