/**
 * @author CloudMasonry
 * @date 2021
 * @group Queueable
 * @description Initiates queueable job to call AccountBCSyncCalloutService
 */
public with sharing class AccountBCSyncEnqueuer {

    public void enqueue(List<Account> lstAccts) {

        if(lstAccts.isEmpty()) { return; }

        List<Account> lstAcctsToUpdate = new List<Account>();

        for (Account Acct : lstAccts) {
            lstAcctsToUpdate.add(new Account(Id = acct.Id, BC_Sync_Status__c = 'Queued'));
        }

        update lstAcctsToUpdate;

        System.enqueueJob(new AccountBCSyncQueueable(new Map<Id, Account>(lstAccts).keySet()));
    }
}