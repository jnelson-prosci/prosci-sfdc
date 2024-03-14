@isTest
private class ContactBCSyncCalloutServiceTest {

    private static final String BC_INSTANCE_US = 'Business_Central_US';
    private static final String BC_INSTANCE_CAN = 'Business_Central_CAN';
    private static final String BC_INSTANCE_ANZ = 'Business_Central_ANZ';
    private static final String BC_INSTANCE_INVALID = 'Business_Central_INVALID';

    @TestSetup
    static void setupData(){
        Contact con = buildContact();
        insert con;
    }

    private static Contact buildContact(){
        return new Contact(
            FirstName = 'Jon',
            LastName = 'Doe',
            Phone = '5555555555',
            Email = 'test@example.com',
            MailingStreet = '500 Main Street',
            MailingCountry = 'US',
            MailingPostalCode = '60654',
            MailingState = 'IL'
        );
    }

    private static Map<String, BC_Integration_Config__mdt> buildIntegrationConfigMetadata(){
        Map<String, BC_Integration_Config__mdt> mapInstanceIntegrationConfig = new Map<String, BC_Integration_Config__mdt>();

        mapInstanceIntegrationConfig.put(BC_INSTANCE_US, new BC_Integration_Config__mdt(
            Active__c = true                
            , Division__c = 'US'
            , Integration_Name__c = ContactBCSyncCalloutService.INTEGRATION_CONFIG_NAME
            , Named_Credential__c = BC_INSTANCE_US
            , URI_Path__c = '/SFContactEntries'
        ));

        mapInstanceIntegrationConfig.put(BC_INSTANCE_CAN, new BC_Integration_Config__mdt(
            Active__c = true                
            , Division__c = 'CAN'
            , Integration_Name__c = ContactBCSyncCalloutService.INTEGRATION_CONFIG_NAME
            , Named_Credential__c = BC_INSTANCE_CAN
            , URI_Path__c = '/SFContactEntries'
        ));

        mapInstanceIntegrationConfig.put(BC_INSTANCE_ANZ, new BC_Integration_Config__mdt(
            Active__c = true                
            , Division__c = 'ANZ'
            , Integration_Name__c = ContactBCSyncCalloutService.INTEGRATION_CONFIG_NAME
            , Named_Credential__c = BC_INSTANCE_ANZ
            , URI_Path__c = '/SFContactEntries'
        ));
        return mapInstanceIntegrationConfig;
    }

    @isTest static void execute_Mock_statusCode201(){
        Set<Id> tSetIds = new Set<Id>();
        List<Contact> tLstCons = new List<Contact>();
        Contact tCon = buildContact();
        tCon.Id = new TestUtils().generateDummyId(Contact.SObjectType);
        tLstCons.add(tCon);
        tSetIds.add(tCon.Id);

        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getRecords', tLstCons);
        mapMethodReturns.put('buildIntegrationFieldMappingsMap', new Map<String, List<BC_Integration_Mapping__mdt>>());
        mapMethodReturns.put('getIntegrationFieldMapping', new List<BC_Integration_Mapping__mdt>());

        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        ContactBCSyncCalloutService calloutService = new ContactBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
        calloutService.execute();

        Test.stopTest();

        System.assertEquals(0, calloutService.lstErrorsToInsert.size(), 'No Error Logs should be instantiated');
        List<Contact> rLstCons = calloutService.lstConsToUpdate;
        System.assertNotEquals(0, rLstCons.size());

        Set<String> setExpectedInstances = new Set<String>{
            BC_INSTANCE_US
            , BC_INSTANCE_CAN
            , BC_INSTANCE_ANZ
        };
        for(Contact con : rLstCons){
            
            System.assertEquals(true, con.BC_Synced__c);
            System.assertEquals(ContactBCSyncCalloutService.STATUS_SYNCED, con.BC_Sync_Status__c);

            System.assertNotEquals(null, con.BC_Synced_Instances__c, 'Each successfully synced instance should be set on record');
            Set<String> setActualInstances = new Set<String>();
            setActualInstances.addAll(con.BC_Synced_Instances__c.split(';'));
            System.assertEquals(setExpectedInstances, setActualInstances, 'Each successfully synced instance should be set on record');
        }
    }

    @isTest static void executeInstance_Mock_statusCode201(){
        Set<Id> tSetIds = new Set<Id>();
        List<Contact> tLstCons = new List<Contact>();
        Contact tCon = buildContact();
        tCon.Id = new TestUtils().generateDummyId(Contact.SObjectType);
        tLstCons.add(tCon);
        tSetIds.add(tCon.Id);

        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getRecords', tLstCons);
        mapMethodReturns.put('buildIntegrationFieldMappingsMap', new Map<String, List<BC_Integration_Mapping__mdt>>());
        mapMethodReturns.put('getIntegrationFieldMapping', new List<BC_Integration_Mapping__mdt>());

        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        ContactBCSyncCalloutService calloutService = new ContactBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
        calloutService.execute(BC_INSTANCE_ANZ);

        Test.stopTest();

        System.assertEquals(0, calloutService.lstErrorsToInsert.size(), 'No Error Logs should be instantiated');
        List<Contact> rLstCons = calloutService.lstConsToUpdate;
        System.assertNotEquals(0, rLstCons.size());

        Set<String> setExpectedInstances = new Set<String>{
            BC_INSTANCE_ANZ
        };
        for(Contact con : rLstCons){
            
            System.assertEquals(true, con.BC_Synced__c);
            System.assertEquals(ContactBCSyncCalloutService.STATUS_SYNCED, con.BC_Sync_Status__c);

            System.assertNotEquals(null, con.BC_Synced_Instances__c, 'Each successfully synced instance should be set on record');
            Set<String> setActualInstances = new Set<String>();
            setActualInstances.addAll(con.BC_Synced_Instances__c.split(';'));
            System.assertEquals(setExpectedInstances, setActualInstances, 'Each successfully synced instance should be set on record');
        }
    }

    @isTest static void executeInstance_Mock_InvalidConfig_Exception(){
        Set<Id> tSetIds = new Set<Id>();
        List<Contact> tLstCons = new List<Contact>();
        Contact tCon = buildContact();
        tCon.Id = new TestUtils().generateDummyId(Contact.SObjectType);
        tLstCons.add(tCon);
        tSetIds.add(tCon.Id);

        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getRecords', tLstCons);
        mapMethodReturns.put('buildIntegrationFieldMappingsMap', new Map<String, List<BC_Integration_Mapping__mdt>>());
        mapMethodReturns.put('getIntegrationFieldMapping', new List<BC_Integration_Mapping__mdt>());

        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        CustomMetadataException mtdEx;

        Test.startTest();

        try {
            ContactBCSyncCalloutService calloutService = new ContactBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
            calloutService.execute(BC_INSTANCE_INVALID);
        } catch (CustomMetadataException ex){
            mtdEx = ex;
        }

        Test.stopTest();

        System.assertNotEquals(null, mtdEx);
        System.assertEquals(ContactBCSyncCalloutService.EXCEPTION_MISSING_CUSTOM_METADATA + BC_INSTANCE_INVALID, mtdEx.getMessage());
    }

    @isTest static void execute_statusCode201(){
        Set<Id> tSetIds = new Map<Id, Contact>([SELECT Id FROM Contact]).keySet();

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        new ContactBCSyncCalloutService(tSetIds).execute();

        Test.stopTest();

        List<Error_Log__c> rLstLogs = [SELECT Id FROM Error_Log__c];
        System.assertEquals(0, rLstLogs.size(), 'No Error Logs should be created');
        List<Contact> rLstCons = [SELECT Id, BC_Synced__c, BC_Synced_Instances__c, BC_Sync_Status__c FROM Contact];
        System.assertNotEquals(0, rLstCons.size());
        for(Contact con : rLstCons){
            System.assertNotEquals(null, con.BC_Synced_Instances__c, 'Each successfully synced instance should be set on record');
            System.assertEquals(true, con.BC_Synced__c);
            System.assertEquals(ContactBCSyncCalloutService.STATUS_SYNCED, con.BC_Sync_Status__c);
        }
    }

    @isTest static void trigger_execute_statusCode201(){
        List<Contact> tLstCons = [SELECT Id, BC_Synced__c, BC_Sync_Status__c FROM Contact];
        for(Contact con : tLstCons){
            con.BC_Sync_Status__c = 'Pending Sync';
        }

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        update tLstCons;

        Test.stopTest();

        List<Error_Log__c> rLstLogs = [SELECT Id FROM Error_Log__c];
        System.assertEquals(0, rLstLogs.size(), 'No Error Logs should be created');
        List<Contact> rLstCons = [SELECT Id, BC_Synced__c, BC_Sync_Status__c FROM Contact];
        System.assertNotEquals(0, rLstCons.size());
        for(Contact con : rLstCons){
            System.assertEquals(true, con.BC_Synced__c);
            System.assertEquals(ContactBCSyncCalloutService.STATUS_SYNCED, con.BC_Sync_Status__c);
        }
    }

    @isTest static void execute_statusCode400_calloutException(){
        Set<Id> tSetIds = new Map<Id, Contact>([SELECT Id FROM Contact]).keySet();

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(400));

        Test.startTest();

        new ContactBCSyncCalloutService(tSetIds).execute();

        Test.stopTest();

        List<Error_Log__c> rLstLogs = [SELECT Exception_Type__c, Category__c FROM Error_Log__c];
        System.assertNotEquals(0, rLstLogs.size(), 'An Error Log should be created to capture the error');
        for(Error_Log__c log : rLstLogs){
            System.assertEquals(new CalloutException().getTypeName(), log.Exception_Type__c);
            System.assertEquals(ContactBCSyncCalloutService.EXCEPTION_CATEGORY, log.Category__c);
        }
        List<Contact> rLstCons = [SELECT Id, BC_Synced__c, BC_Sync_Status__c FROM Contact];
        System.assertNotEquals(0, rLstCons.size());
        for(Contact con : rLstCons){
            System.assertEquals(false, con.BC_Synced__c);
            System.assertEquals(ContactBCSyncCalloutService.STATUS_FAILED, con.BC_Sync_Status__c);
        }
    }

    @isTest static void execute_genericException(){
        Set<Id> tSetIds = new Map<Id, Contact>([SELECT Id FROM Contact]).keySet();

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201).forceMockException());

        Test.startTest();

        new ContactBCSyncCalloutService(tSetIds).execute();

        Test.stopTest();

        List<Error_Log__c> rLstLogs = [SELECT Exception_Type__c, Category__c FROM Error_Log__c];
        System.assertNotEquals(0, rLstLogs.size(), 'An Error Log should be created to capture the error');
        for(Error_Log__c log : rLstLogs){
            System.assertEquals(new PushToBcGenericMock.MockException().getTypeName(), log.Exception_Type__c);
            System.assertEquals(ContactBCSyncCalloutService.EXCEPTION_CATEGORY, log.Category__c);
        }
        List<Contact> rLstCons = [SELECT Id, BC_Synced__c, BC_Sync_Status__c FROM Contact];
        System.assertNotEquals(0, rLstCons.size());
        for(Contact con : rLstCons){
            System.assertEquals(false, con.BC_Synced__c);
            System.assertEquals(ContactBCSyncCalloutService.STATUS_FAILED, con.BC_Sync_Status__c);
        }
    }

    @isTest static void wrapper_AddressBlank(){
        Contact tCon = buildContact();
        tCon.OtherStreet = null;

        Test.startTest();

        ContactBCSyncCalloutService.ContactSyncWrapper tWrapper = new ContactBCSyncCalloutService.ContactSyncWrapper(tCon);

        Test.stopTest();

        System.assertEquals(ContactBCSyncCalloutService.NULL_PLACEHOLDER, tWrapper.Address);
    }

    @isTest static void wrapper_AddressOneLine(){
        final String strStreet1 = '500 Main St';
        Contact tCon = buildContact();
        tCon.OtherStreet = strStreet1;

        Test.startTest();

        ContactBCSyncCalloutService.ContactSyncWrapper tWrapper = new ContactBCSyncCalloutService.ContactSyncWrapper(tCon);

        Test.stopTest();

        System.assertEquals(strStreet1, tWrapper.Address);
        System.assertEquals(ContactBCSyncCalloutService.NULL_PLACEHOLDER, tWrapper.Address_2);
    }

    @isTest static void wrapper_AddressTwoLines(){
        final String strStreet1 = '500 Main St';
        final String strStreet2 = 'Unit 23';
        final String strLineBreak = '\r\n';
        Contact tCon = buildContact();
        tCon.OtherStreet = strStreet1 + strLineBreak + strStreet2;

        Test.startTest();

        ContactBCSyncCalloutService.ContactSyncWrapper tWrapper = new ContactBCSyncCalloutService.ContactSyncWrapper(tCon);

        Test.stopTest();

        System.assertEquals(strStreet1, tWrapper.Address);
        System.assertEquals(strStreet2, tWrapper.Address_2);
    }
}