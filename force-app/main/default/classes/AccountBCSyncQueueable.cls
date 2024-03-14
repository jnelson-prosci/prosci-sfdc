/**
 * @author CloudMasonry
 * @date 2021
 * @group Queueable
 * @description Enables async execution of AccountBCSyncCalloutService. Handles top level errors.
 */
public with sharing class AccountBCSyncQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> setAcctIds;
    private QueueableBatchManager batchManager;

    public AccountBCSyncQueueable(Set<Id> setAcctIds) {
        this(setAcctIds, new QueueableBatchManager(
            QueueableBatchManager.Context.Callout
            , new BCSyncDAO().getIntegrationConfigMap(AccountBCSyncCalloutService.INTEGRATION_CONFIG_NAME).size()));
    }

    @testVisible
    private AccountBCSyncQueueable(Set<Id> setAcctIds, QueueableBatchManager batchManager){
        this.setAcctIds = setAcctIds;
        this.batchManager = batchManager;
        this.batchManager.setIds(setAcctIds);
    }

    public void execute(QueueableContext context) {
        try {
            new AccountBCSyncCalloutService(this.batchManager.getBatchIds()).execute();
            if(!this.batchManager.getUnprocessedIds().isEmpty()){
                System.enqueueJob(new AccountBCSyncQueueable(this.batchManager.getUnprocessedIds()));
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