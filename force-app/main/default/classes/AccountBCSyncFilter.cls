/**
 * @author CloudMasonry
 * @date 2021
 * @group Filter
 * @description Filters Account Records for processing by AccountBCSyncCalloutService
 */
public with sharing class AccountBCSyncFilter {

    @testVisible
    private static final String STATUS_PENDING_SYNC = 'Pending Sync';

    public List<Account> filterRecords(List<Account> lstNewRecords, Map<Id, Account> mapOldRecords) {
        List<Account> filteredAccts = new List<Account>();
        
        for (Account acct : lstNewRecords) {
            Account oldacct = mapOldRecords.get(acct.Id);

            if ((acct.BC_Sync_Status__c != oldacct.BC_Sync_Status__c
                && acct.BC_Sync_Status__c == STATUS_PENDING_SYNC
                )
                || 
                    (acct.BC_Synced_Instances__c != null
                    && (acct.Name != oldacct.Name
                        || acct.Payment_Terms__c != oldacct.Payment_Terms__c
                        || acct.Price_Group__c != oldacct.Price_Group__c)
                    )) {

                filteredAccts.add(acct);
            }
        }
        
        return filteredAccts;
    }
}