@isTest
private class ContactBCSyncFilterTest {

    private static final Integer RECORD_COUNT = 200;
    private static final String TEST_FIRST_NAME = 'John';
    private static final String TEST_FIRST_NAME_OLD = 'Jimmy';
    private static final String TEST_LAST_NAME = 'Doe';
    private static final String TEST_LAST_NAME_OLD = 'Dough';
    private static final String TEST_ACCOUNT_ID = new TestUtils().generateDummyId(Account.SObjectType);
    private static final String TEST_ACCOUNT_ID_OLD = new TestUtils().generateDummyId(Account.SObjectType);
    private static final String TEST_EMAIL = 'john.doe@example.com';
    private static final String TEST_EMAIL_OLD = 'jimmy.dough@example.com';
    private static final String BC_INSTANCE_US = 'Business_Central_US';

    @isTest static void filterRecords_noChange_returnEmpty(){
        List<Contact> tLstCons = new List<Contact>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstCons.add(new Contact(
                Id = new TestUtils().generateDummyId(Contact.SObjectType)
                , BC_Sync_Status__c = null
                , FirstName = TEST_FIRST_NAME
                , LastName = TEST_LAST_NAME
                , AccountId = TEST_ACCOUNT_ID
                , Email = TEST_EMAIL
                , BC_Synced__c = false
                , BC_Synced_Instances__c = null
            ));
        }

        Map<Id, Contact> tMapOldCons = new Map<Id, Contact>(tLstCons.deepClone(true));

        List<Contact> rLstCons;

        Test.startTest();

        rLstCons = new ContactBCSyncFilter().filterRecords(tLstCons, tMapOldCons);

        Test.stopTest();

        System.assertEquals(0, rLstCons.size()
            , 'When sync status does not change and record is not synced, no Contacts should be returned');
    }

    @isTest static void filterRecords_notSyncedChangeToPendingSync_returnAll(){
        List<Contact> tLstCons = new List<Contact>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstCons.add(new Contact(
                Id = new TestUtils().generateDummyId(Contact.SObjectType)
                , BC_Sync_Status__c = ContactBCSyncFilter.STATUS_PENDING_SYNC
                , FirstName = TEST_FIRST_NAME
                , LastName = TEST_LAST_NAME
                , AccountId = TEST_ACCOUNT_ID
                , Email = TEST_EMAIL
                , BC_Synced__c = false
                , BC_Synced_Instances__c = null
            ));
        }

        Map<Id, Contact> tMapOldCons = new Map<Id, Contact>(tLstCons.deepClone(true));
        for(Contact oldCon : tMapOldCons.values()){
            oldCon.BC_Sync_Status__c = null;
        }

        List<Contact> rLstCons;

        Test.startTest();

        rLstCons = new ContactBCSyncFilter().filterRecords(tLstCons, tMapOldCons);

        Test.stopTest();

        System.assertEquals(tLstCons.size(), rLstCons.size()
            , 'When sync status is changed to Pending Sync, all Contacts should be returned');
    }

    @isTest static void filterRecords_syncedChangeToFirstName_returnAll(){
        List<Contact> tLstCons = new List<Contact>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstCons.add(new Contact(
                Id = new TestUtils().generateDummyId(Contact.SObjectType)
                , BC_Sync_Status__c = null
                , FirstName = TEST_FIRST_NAME
                , LastName = TEST_LAST_NAME
                , AccountId = TEST_ACCOUNT_ID
                , Email = TEST_EMAIL
                , BC_Synced__c = true
                , BC_Synced_Instances__c = BC_INSTANCE_US
            ));
        }

        Map<Id, Contact> tMapOldCons = new Map<Id, Contact>(tLstCons.deepClone(true));
        for(Contact oldCon : tMapOldCons.values()){
            oldCon.FirstName = TEST_FIRST_NAME_OLD;
        }

        List<Contact> rLstCons;

        Test.startTest();

        rLstCons = new ContactBCSyncFilter().filterRecords(tLstCons, tMapOldCons);

        Test.stopTest();

        System.assertEquals(tLstCons.size(), rLstCons.size()
            , 'When records are synced and First Name is changed, all Contacts should be returned');
    }

    @isTest static void filterRecords_syncedChangeToLastName_returnAll(){
        List<Contact> tLstCons = new List<Contact>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstCons.add(new Contact(
                Id = new TestUtils().generateDummyId(Contact.SObjectType)
                , BC_Sync_Status__c = null
                , FirstName = TEST_FIRST_NAME
                , LastName = TEST_LAST_NAME
                , AccountId = TEST_ACCOUNT_ID
                , Email = TEST_EMAIL
                , BC_Synced__c = true
                , BC_Synced_Instances__c = BC_INSTANCE_US
            ));
        }

        Map<Id, Contact> tMapOldCons = new Map<Id, Contact>(tLstCons.deepClone(true));
        for(Contact oldCon : tMapOldCons.values()){
            oldCon.LastName = TEST_LAST_NAME_OLD;
        }

        List<Contact> rLstCons;

        Test.startTest();

        rLstCons = new ContactBCSyncFilter().filterRecords(tLstCons, tMapOldCons);

        Test.stopTest();

        System.assertEquals(tLstCons.size(), rLstCons.size()
            , 'When records are synced and Last Name is changed, all Contacts should be returned');
    }

    @isTest static void filterRecords_syncedChangeToAccount_returnAll(){
        List<Contact> tLstCons = new List<Contact>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstCons.add(new Contact(
                Id = new TestUtils().generateDummyId(Contact.SObjectType)
                , BC_Sync_Status__c = null
                , FirstName = TEST_FIRST_NAME
                , LastName = TEST_LAST_NAME
                , AccountId = TEST_ACCOUNT_ID
                , Email = TEST_EMAIL
                , BC_Synced__c = true
                , BC_Synced_Instances__c = BC_INSTANCE_US
            ));
        }

        Map<Id, Contact> tMapOldCons = new Map<Id, Contact>(tLstCons.deepClone(true));
        for(Contact oldCon : tMapOldCons.values()){
            oldCon.AccountId = TEST_ACCOUNT_ID_OLD;
        }

        List<Contact> rLstCons;

        Test.startTest();

        rLstCons = new ContactBCSyncFilter().filterRecords(tLstCons, tMapOldCons);

        Test.stopTest();

        System.assertEquals(tLstCons.size(), rLstCons.size()
            , 'When records are synced and Account is changed, all Contacts should be returned');
    }

    @isTest static void filterRecords_syncedChangeToEmail_returnAll(){
        List<Contact> tLstCons = new List<Contact>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstCons.add(new Contact(
                Id = new TestUtils().generateDummyId(Contact.SObjectType)
                , BC_Sync_Status__c = null
                , FirstName = TEST_FIRST_NAME
                , LastName = TEST_LAST_NAME
                , AccountId = TEST_ACCOUNT_ID
                , Email = TEST_EMAIL
                , BC_Synced__c = true
                , BC_Synced_Instances__c = BC_INSTANCE_US
            ));
        }

        Map<Id, Contact> tMapOldCons = new Map<Id, Contact>(tLstCons.deepClone(true));
        for(Contact oldCon : tMapOldCons.values()){
            oldCon.Email = TEST_EMAIL_OLD;
        }

        List<Contact> rLstCons;

        Test.startTest();

        rLstCons = new ContactBCSyncFilter().filterRecords(tLstCons, tMapOldCons);

        Test.stopTest();

        System.assertEquals(tLstCons.size(), rLstCons.size()
            , 'When records are synced and Email is changed, all Contacts should be returned');
    }
}