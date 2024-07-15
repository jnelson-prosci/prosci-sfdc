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

    }

    /**
     * @description Execute method of the batch
     * @param bc Batchable Context
     * @param scope List of queried records
     */
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
    
    }

    /**
     * @description Finish method of the batch
     * @param bc Batchable Context
     */
    public void finish(Database.BatchableContext bc) {
        system.debug(bc);
    }

}