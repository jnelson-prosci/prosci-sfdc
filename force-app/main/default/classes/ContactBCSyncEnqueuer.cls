/**
 * @author CloudMasonry
 * @date 2021
 * @group Queueable
 * @description Initiates queueable job to call ContactBCSyncCalloutService
 */
public with sharing class ContactBCSyncEnqueuer {

    public void enqueue(List<Contact> lstCons) {

        if(lstCons.isEmpty()) { return; }

        List<Contact> lstConsToUpdate = new List<Contact>();

        for (Contact con : lstCons) {
            lstConsToUpdate.add(new Contact(Id = con.Id, BC_Sync_Status__c = 'Queued'));
        }

        update lstConsToUpdate;

        System.enqueueJob(new ContactBCSyncQueueable(new Map<Id, Contact>(lstCons).keySet()));
    }
}