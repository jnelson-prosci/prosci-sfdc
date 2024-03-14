@IsTest
private class AccountBCSyncCalloutServiceTest {

    private static final String BC_INSTANCE_US = 'Business_Central_US';
    private static final String BC_INSTANCE_CAN = 'Business_Central_CAN';
    private static final String BC_INSTANCE_ANZ = 'Business_Central_ANZ';
    private static final String BC_INSTANCE_INVALID = 'Business_Central_INVALID';


    @TestSetup
    private static void setupData() {
        Account acct = buildAccount();
        insert acct;
    }

    private static Account buildAccount(){
        return new Account(
            Name = 'Test Acc',
            NAV_Customer__c = '123',
            BillingStreet = '500 Main St',
            BillingState = 'IL',
            BillingCity = 'Chicago',
            BillingCountry = 'IL',
            BillingPostalCode = '60654',
            Phone = '14245533535',
            Fax = '44553535'
        );
    }

    private static Map<String, BC_Integration_Config__mdt> buildIntegrationConfigMetadata(){
        Map<String, BC_Integration_Config__mdt> mapInstanceIntegrationConfig = new Map<String, BC_Integration_Config__mdt>();

        mapInstanceIntegrationConfig.put(BC_INSTANCE_US, new BC_Integration_Config__mdt(
            Active__c = true                
            , Division__c = 'US'
            , Integration_Name__c = AccountBCSyncCalloutService.INTEGRATION_CONFIG_NAME
            , Named_Credential__c = BC_INSTANCE_US
            , URI_Path__c = '/SFCustomerEntries'
        ));

        mapInstanceIntegrationConfig.put(BC_INSTANCE_CAN, new BC_Integration_Config__mdt(
            Active__c = true                
            , Division__c = 'CAN'
            , Integration_Name__c = AccountBCSyncCalloutService.INTEGRATION_CONFIG_NAME
            , Named_Credential__c = BC_INSTANCE_CAN
            , URI_Path__c = '/SFCustomerEntries'
        ));

        mapInstanceIntegrationConfig.put(BC_INSTANCE_ANZ, new BC_Integration_Config__mdt(
            Active__c = true                
            , Division__c = 'ANZ'
            , Integration_Name__c = AccountBCSyncCalloutService.INTEGRATION_CONFIG_NAME
            , Named_Credential__c = BC_INSTANCE_ANZ
            , URI_Path__c = '/SFCustomerEntries'
        ));
        return mapInstanceIntegrationConfig;
    }


    @IsTest static void testExecuteGenericException() {
        
        Set<Id> setAcctIds = (new Map<Id,SObject>([
            SELECT Id
            FROM Account
            WHERE Name = 'Test Acc'
        ])).keySet();

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(0).forceMockException());

        Test.startTest();

        new AccountBCSyncCalloutService(setAcctIds).execute();

        Test.stopTest();

        List<Error_Log__c> errors = [
            SELECT Id, Exception_Type__c
			FROM Error_Log__c
        ];

        System.assertNotEquals(0, errors.size());
        for(Error_Log__c rLog : errors){
            System.assertEquals(new PushToBcGenericMock.MockException().getTypeName(), rLog.Exception_Type__c);
        }

        List<Account> rLstAccts = [SELECT Id, BC_Sync_Status__c, BC_Synced__c FROM Account];
        for(Account acct : rLstAccts){
            System.assertEquals(false, acct.BC_Synced__c);
            System.assertEquals(AccountBCSyncCalloutService.STATUS_FAILED, acct.BC_Sync_Status__c);
        }
    }

    @IsTest static void trigger_UpdatePendingSync_StatusCode400() {
        Account testAcc = [SELECT Id, BC_Sync_Status__c FROM Account LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(400));

        Test.startTest();

        testAcc.BC_Sync_Status__c = 'Pending Sync';
        update testAcc;

        Test.stopTest();

        List<Error_Log__c> errors = [
            SELECT Id, Exception_Type__c
			FROM Error_Log__c
        ];

        System.assertNotEquals(0, errors.size());
        for(Error_Log__c rLog : errors){
            System.assertEquals(new CalloutException().getTypeName(), rLog.Exception_Type__c);
        }

        List<Account> rLstAccts = [SELECT Id, BC_Sync_Status__c, BC_Synced__c FROM Account];
        for(Account acct : rLstAccts){
            System.assertEquals(false, acct.BC_Synced__c);
            System.assertEquals(AccountBCSyncCalloutService.STATUS_FAILED, acct.BC_Sync_Status__c);
        }
    }


    @IsTest static void trigger_UpdatePendingSync_StatusCode201() {
        Account testAcc = [SELECT Id, BC_Sync_Status__c FROM Account LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        testAcc.BC_Sync_Status__c = 'Pending Sync';
        update testAcc;

        Test.stopTest();

        List<Account> rLstAccts = [SELECT Id, BC_Sync_Status__c, BC_Synced__c FROM Account];
        for(Account acct : rLstAccts){
            System.assertEquals(AccountBCSyncCalloutService.STATUS_SYNCED, acct.BC_Sync_Status__c);
        }
    }

    @IsTest static void testExecute_StatusCode201() {
        Set<Id> setAcctIds = (new Map<Id,SObject>([
            SELECT Id
            FROM Account
            WHERE Name = 'Test Acc'
        ])).keySet();

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        new AccountBCSyncCalloutService(setAcctIds).execute();

        Test.stopTest();

        List<Error_Log__c> errors = [
            SELECT Id, Exception_Type__c
			FROM Error_Log__c
        ];

        System.assertEquals(0, errors.size());

        List<Account> rLstAccts = [SELECT Id, BC_Sync_Status__c, BC_Synced_Instances__c, BC_Synced__c FROM Account];
        for(Account acct : rLstAccts){
            System.assertEquals(AccountBCSyncCalloutService.STATUS_SYNCED, acct.BC_Sync_Status__c);
            System.assertNotEquals(null, acct.BC_Synced_Instances__c, 'Each successfully synced instance should be set on record');
            System.assertEquals(true, acct.BC_Synced__c);
        }
    }

    @IsTest static void testExecuteMock_StatusCode201() {

        Set<Id> tSetIds = new Set<Id>();
        List<Account> tLstAccs = new List<Account>();
        Account tAcc = buildAccount();
        tAcc.Id = new TestUtils().generateDummyId(Account.SObjectType);
        tLstAccs.add(tAcc);
        tSetIds.add(tAcc.Id);
        
        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getRecords', tLstAccs);
        mapMethodReturns.put('buildIntegrationFieldMappingsMap', new Map<String, List<BC_Integration_Mapping__mdt>>());
        mapMethodReturns.put('getIntegrationFieldMapping', new List<BC_Integration_Mapping__mdt>());

        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        AccountBCSyncCalloutService calloutService = new AccountBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
        calloutService.execute();

        Test.stopTest();

        System.assertEquals(0, calloutService.lstErrorsToInsert.size(), 'No Error Logs should be instantiated');
        List<Account> rLstAccts = calloutService.lstAcctsToUpdate;

        Set<String> setExpectedInstances = new Set<String>{
            BC_INSTANCE_US
            , BC_INSTANCE_CAN
            , BC_INSTANCE_ANZ
        };
       
        for(Account acct : rLstAccts){
            
            System.assertEquals(true, acct.BC_Synced__c);
            System.assertEquals(AccountBCSyncCalloutService.STATUS_SYNCED, acct.BC_Sync_Status__c);

            System.assertNotEquals(null, acct.BC_Synced_Instances__c, 'Each successfully synced instance should be set on record');
            Set<String> setActualInstances = new Set<String>();
            setActualInstances.addAll(acct.BC_Synced_Instances__c.split(';'));
            System.assertEquals(setExpectedInstances, setActualInstances, 'Each successfully synced instance should be set on record');
        }
    }

    @IsTest static void executeInstance_Mock_statusCode201() {

        Set<Id> tSetIds = new Set<Id>();
        List<Account> tLstAccs = new List<Account>();
        Account tAcc = buildAccount();
        tAcc.Id = new TestUtils().generateDummyId(Account.SObjectType);
        tLstAccs.add(tAcc);
        tSetIds.add(tAcc.Id);
        
        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getRecords', tLstAccs);
        mapMethodReturns.put('buildIntegrationFieldMappingsMap', new Map<String, List<BC_Integration_Mapping__mdt>>());
        mapMethodReturns.put('getIntegrationFieldMapping', new List<BC_Integration_Mapping__mdt>());

        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        AccountBCSyncCalloutService calloutService = new AccountBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
        calloutService.execute(BC_INSTANCE_ANZ);

        Test.stopTest();

        System.assertEquals(0, calloutService.lstErrorsToInsert.size(), 'No Error Logs should be instantiated');
        List<Account> rLstAccts = calloutService.lstAcctsToUpdate;

        Set<String> setExpectedInstances = new Set<String>{
            BC_INSTANCE_ANZ
        };
       
        for(Account acct : rLstAccts){
            
            System.assertEquals(true, acct.BC_Synced__c);
            System.assertEquals(AccountBCSyncCalloutService.STATUS_SYNCED, acct.BC_Sync_Status__c);

            System.assertNotEquals(null, acct.BC_Synced_Instances__c, 'Each successfully synced instance should be set on record');
            Set<String> setActualInstances = new Set<String>();
            setActualInstances.addAll(acct.BC_Synced_Instances__c.split(';'));
            System.assertEquals(setExpectedInstances, setActualInstances, 'Each successfully synced instance should be set on record');
        }
    }

    @IsTest static void executeInstance_Mock_InvalidConfig_Exception() {

        Set<Id> tSetIds = new Set<Id>();
        List<Account> tLstAccs = new List<Account>();
        Account tAcc = buildAccount();
        tAcc.Id = new TestUtils().generateDummyId(Account.SObjectType);
        tLstAccs.add(tAcc);
        tSetIds.add(tAcc.Id);
        
        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getRecords', tLstAccs);
        mapMethodReturns.put('buildIntegrationFieldMappingsMap', new Map<String, List<BC_Integration_Mapping__mdt>>());
        mapMethodReturns.put('getIntegrationFieldMapping', new List<BC_Integration_Mapping__mdt>());

        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        CustomMetadataException mtdEx;

        Test.startTest();

        try {
            AccountBCSyncCalloutService calloutService = new AccountBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
            calloutService.execute(BC_INSTANCE_INVALID);
        } catch (CustomMetadataException ex){
            mtdEx = ex;
        }

        Test.stopTest();

        System.assertNotEquals(null, mtdEx);
        System.assertEquals(AccountBCSyncCalloutService.EXCEPTION_MISSING_CUSTOM_METADATA + BC_INSTANCE_INVALID, mtdEx.getMessage());
    }

    @IsTest static void testSyncWrapperBlankStreet() {
        Account testAccount = buildAccount();
        testAccount.BillingStreet = null;

        Test.startTest();

        AccountBCSyncCalloutService.AccountInitSyncWrapper testSyncWrapper = new  AccountBCSyncCalloutService.AccountInitSyncWrapper(testAccount);

        Test.stopTest();

        System.assertEquals(AccountBCSyncCalloutService.NULL_PLACEHOLDER, testSyncWrapper.Address);
    }
    @IsTest static void testSyncWrapperMultiStreetDoubleLineStreet() {

        final String strStreet1 = '500 Main St';
        final String strStreet2 = 'Unit 23';
        final String strLineBreak = '\r\n';

        Account testAccount = buildAccount();
        testAccount.BillingStreet = strStreet1 + strLineBreak + strStreet2;

        Test.startTest();

        AccountBCSyncCalloutService.AccountInitSyncWrapper testSyncWrapper = new  AccountBCSyncCalloutService.AccountInitSyncWrapper(testAccount);

        Test.stopTest();

        System.assertEquals(strStreet1, testSyncWrapper.Address);
        System.assertEquals(strStreet2, testSyncWrapper.Address_2);


    }
    @IsTest static void testSyncWrapperMultiStreetSingleLineStreet() {
        final String strStreet1 = '500 Main St';

        Account testAccount = buildAccount();
        testAccount.BillingStreet = strStreet1;

        Test.startTest();

        AccountBCSyncCalloutService.AccountInitSyncWrapper testSyncWrapper = new  AccountBCSyncCalloutService.AccountInitSyncWrapper(testAccount);

        Test.stopTest();

        System.assertEquals(strStreet1, testSyncWrapper.Address);
        System.assertEquals(AccountBCSyncCalloutService.NULL_PLACEHOLDER, testSyncWrapper.Address_2);

    }
}