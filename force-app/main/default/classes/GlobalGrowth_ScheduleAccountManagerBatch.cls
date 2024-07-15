/***********************************************************************************************************************        
Name            : GlobalGrowth_ScheduleAccountManagerBatch
Author          : Slalom Team, Reggie Thompson
Date            : 07/15/24
@description    : Schedules batch Apex to update Accounts whose OwnerId is not the same as the Account Manager
                    (GlobalGrowth_AccountManagerBatch)
***********************************************************************************************************************/
public with sharing class GlobalGrowth_ScheduleAccountManagerBatch implements Schedulable {
    /**
     * @description Scheduler execute method
     * @param sc SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        // TO-DO: Determine batch size
        // GlobalGrowth_AccountManagerBatch batch = new GlobalGrowth_AccountManagerBatch();
        // Database.executeBatch(batch, batchSize);
    } 
}