/***********************************************************************************************************************        
Name            : GlobalGrowth_AccountManagerBatch
Author          : Slalom Team, Reggie Thompson
Date            : 07/15/24
@description    : Batch Apex to syncronise Account Owners with Account Managers
***********************************************************************************************************************/
public with sharing class GlobalGrowth_AccountManagerBatch implements Database.Batchable<SObject> {
    
    /**
     * @description Start method of the batch
     * @param bc Batchable Context
     * @return QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<Account> accounts = [SELECT Id, OwnerId, Account_Manager__r.pse__Salesforce_User__c, Account_Manager__r.pse__Salesforce_User__r.IsActive FROM Account];
        Map<Id, Account> acctsToRetrieve = new Map<Id, Account>();

        for (Account account : accounts) {
            if (account.OwnerId != account.Account_Manager__r.pse__Salesforce_User__c) {
                acctsToRetrieve.put(account.Id, account);
            }
        }

        Set<Id> accountIds = acctsToRetrieve.keySet();
        String query = 'SELECT Id, OwnerId, Account_Manager__r.pse__Salesforce_User__c, Account_Manager__r.pse__Salesforce_User__r.IsActive FROM Account'
            + ' WHERE Id IN :accountIds';
        return Database.getQueryLocator(query);
    }

    /**
     * @description Execute method of the batch
     * @param bc Batchable Context
     * @param scope List of queried records
     */
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        User sfAdmin = [SELECT Id FROM User WHERE Name = 'Salesforce Administrator'];

        for (Account account : scope) {
            if (account.Account_Manager__r.pse__Salesforce_User__r.IsActive) {
                account.OwnerId = account.Account_Manager__r.pse__Salesforce_User__c;
            } else {
                account.OwnerId = sfAdmin.Id;
            }

            accountsToUpdate.add(account);
        }

        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    /**
     * @description Finish method of the batch
     * @param bc Batchable Context
     */
    public void finish(Database.BatchableContext bc) {
        system.debug(bc);
    }

}