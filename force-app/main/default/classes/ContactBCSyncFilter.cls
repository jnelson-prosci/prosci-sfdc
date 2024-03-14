/**
 * @author CloudMasonry
 * @date 2021
 * @group Filter
 * @description Filters Contact Records for processing by ContactBCSyncCalloutService
 */
public with sharing class ContactBCSyncFilter {

    @testVisible
    private static final String STATUS_PENDING_SYNC = 'Pending Sync';

    public List<Contact> filterRecords (List<Contact> lstNewRecords, Map<Id, Contact> mapOldRecords) {
        List<Contact> filteredContacts = new List<Contact>();

        for (Contact con : lstNewRecords) {
            Contact oldRecord = mapOldRecords.get(con.Id);

            if ((con.BC_Sync_Status__c != oldRecord.BC_Sync_Status__c
                && con.BC_Sync_Status__c == STATUS_PENDING_SYNC)
                ||	(con.BC_Synced_Instances__c != null &&
                        (con.LastName != oldRecord.LastName
                        || con.FirstName != oldRecord.FirstName
                        || con.AccountId != oldRecord.AccountId
                        || con.Email != oldRecord.Email)
                )) {

                filteredContacts.add(con);
            }
        }

        return filteredContacts;
    }

}