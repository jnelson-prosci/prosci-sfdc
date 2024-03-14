@isTest
private class AccountBCSyncFilterTest {

    private static final Integer RECORD_COUNT = 200;
    private static final String TEST_NAME = 'Test Name';
    private static final String TEST_NAME_OLD = 'Test Name Old';
    private static final String TEST_PAYMENT_TERMS = 'NET 30';
    private static final String TEST_PAYMENT_TERMS_OLD = 'NET 45';
    private static final String TEST_PRICE_GROUP = 'ADKAR';
    private static final String TEST_PRICE_GROUP_OLD = 'ECM';
    private static final String BC_INSTANCE_US = 'Business_Central_US';

    @isTest static void filterRecords_noChange_returnEmpty(){
        List<Account> tLstAccts = new List<Account>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstAccts.add(new Account(
                Id = new TestUtils().generateDummyId(Account.SObjectType)
                , BC_Sync_Status__c = null
                , Name = TEST_NAME
                , Payment_Terms__c = TEST_PAYMENT_TERMS
                , Price_Group__c = TEST_PRICE_GROUP
                , BC_Synced__c = false
                , BC_Synced_Instances__c = null
            ));
        }

        Map<Id, Account> tMapOldAccts = new Map<Id, Account>(tLstAccts.deepClone(true));

        List<Account> rLstAccts;

        Test.startTest();

        rLstAccts = new AccountBCSyncFilter().filterRecords(tLstAccts, tMapOldAccts);

        Test.stopTest();

        System.assertEquals(0, rLstAccts.size()
            , 'When sync status does not change and record is not synced, no accounts should be returned');
    }

    @isTest static void filterRecords_notSyncedChangeToPendingSync_returnAll(){
        List<Account> tLstAccts = new List<Account>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstAccts.add(new Account(
                Id = new TestUtils().generateDummyId(Account.SObjectType)
                , BC_Sync_Status__c = AccountBCSyncFilter.STATUS_PENDING_SYNC
                , Name = TEST_NAME
                , Payment_Terms__c = TEST_PAYMENT_TERMS
                , Price_Group__c = TEST_PRICE_GROUP
                , BC_Synced__c = false
                , BC_Synced_Instances__c = null
            ));
        }

        Map<Id, Account> tMapOldAccts = new Map<Id, Account>(tLstAccts.deepClone(true));
        for(Account oldAcct : tMapOldAccts.values()){
            oldAcct.BC_Sync_Status__c = null;
        }

        List<Account> rLstAccts;

        Test.startTest();

        rLstAccts = new AccountBCSyncFilter().filterRecords(tLstAccts, tMapOldAccts);

        Test.stopTest();

        System.assertEquals(tLstAccts.size(), rLstAccts.size()
            , 'When sync status is changed to Pending Sync, all accounts should be returned');
    }

    @isTest static void filterRecords_syncedChangeToName_returnAll(){
        List<Account> tLstAccts = new List<Account>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstAccts.add(new Account(
                Id = new TestUtils().generateDummyId(Account.SObjectType)
                , BC_Sync_Status__c = AccountBCSyncFilter.STATUS_PENDING_SYNC
                , Name = TEST_NAME
                , Payment_Terms__c = TEST_PAYMENT_TERMS
                , Price_Group__c = TEST_PRICE_GROUP
                , BC_Synced__c = true
                , BC_Synced_Instances__c = BC_INSTANCE_US
            ));
        }

        Map<Id, Account> tMapOldAccts = new Map<Id, Account>(tLstAccts.deepClone(true));
        for(Account oldAcct : tMapOldAccts.values()){
            oldAcct.Name = TEST_NAME_OLD;
        }

        List<Account> rLstAccts;

        Test.startTest();

        rLstAccts = new AccountBCSyncFilter().filterRecords(tLstAccts, tMapOldAccts);

        Test.stopTest();

        System.assertEquals(tLstAccts.size(), rLstAccts.size()
            , 'When records are synced and name is changed, all accounts should be returned');
    }

    @isTest static void filterRecords_syncedChangeToPaymentTerms_returnAll(){
        List<Account> tLstAccts = new List<Account>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstAccts.add(new Account(
                Id = new TestUtils().generateDummyId(Account.SObjectType)
                , BC_Sync_Status__c = AccountBCSyncFilter.STATUS_PENDING_SYNC
                , Name = TEST_NAME
                , Payment_Terms__c = TEST_PAYMENT_TERMS
                , Price_Group__c = TEST_PRICE_GROUP
                , BC_Synced__c = true
                , BC_Synced_Instances__c = BC_INSTANCE_US
            ));
        }

        Map<Id, Account> tMapOldAccts = new Map<Id, Account>(tLstAccts.deepClone(true));
        for(Account oldAcct : tMapOldAccts.values()){
            oldAcct.Payment_Terms__c = TEST_PAYMENT_TERMS_OLD;
        }

        List<Account> rLstAccts;

        Test.startTest();

        rLstAccts = new AccountBCSyncFilter().filterRecords(tLstAccts, tMapOldAccts);

        Test.stopTest();

        System.assertEquals(tLstAccts.size(), rLstAccts.size()
            , 'When records are synced and payment terms are changed, all accounts should be returned');
    }

    @isTest static void filterRecords_syncedChangeToPriceGroup_returnAll(){
        List<Account> tLstAccts = new List<Account>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstAccts.add(new Account(
                Id = new TestUtils().generateDummyId(Account.SObjectType)
                , BC_Sync_Status__c = AccountBCSyncFilter.STATUS_PENDING_SYNC
                , Name = TEST_NAME
                , Payment_Terms__c = TEST_PAYMENT_TERMS
                , Price_Group__c = TEST_PRICE_GROUP
                , BC_Synced__c = true
                , BC_Synced_Instances__c = BC_INSTANCE_US
            ));
        }

        Map<Id, Account> tMapOldAccts = new Map<Id, Account>(tLstAccts.deepClone(true));
        for(Account oldAcct : tMapOldAccts.values()){
            oldAcct.Price_Group__c = TEST_PRICE_GROUP_OLD;
        }

        List<Account> rLstAccts;

        Test.startTest();

        rLstAccts = new AccountBCSyncFilter().filterRecords(tLstAccts, tMapOldAccts);

        Test.stopTest();

        System.assertEquals(tLstAccts.size(), rLstAccts.size()
            , 'When records are synced and price group is changed, all accounts should be returned');
    }
}