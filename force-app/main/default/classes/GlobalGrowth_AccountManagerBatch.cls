/***********************************************************************************************************************        
Name            : GlobalGrowth_AccountManagerBatch
Author          : Slalom Team, Reggie Thompson
Date            : 07/15/24
@description    : Batch Apex to syncronise Account Owners with Account Managers
***********************************************************************************************************************/
public with sharing class GlobalGrowth_AccountManagerBatch implements 
    Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    /**
     * @description Start method of the batch
     * @param bc Batchable Context
     * @return QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, OwnerId, Account_Manager__r.pse__Salesforce_User__c, Account_Manager__r.pse__Salesforce_User__r.IsActive FROM Account'
            + ' WHERE Account_Manager__r.pse__Salesforce_User__c != OwnerId';
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
                accountsToUpdate.add(account);
            } else {
                account.OwnerId = sfAdmin.Id;
            }
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