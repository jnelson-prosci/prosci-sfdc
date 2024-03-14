@isTest
private class OpportunityBCSyncCalloutServiceTest {

    private static final String BC_INSTANCE_US = 'Business_Central_US';
    private static final String BC_INSTANCE_CAN = 'Business_Central_CAN';
    private static final String BC_INSTANCE_ANZ = 'Business_Central_ANZ';
    private static final String DIVISION_US = 'USA';
    private static final String DIVISION_CAN = 'CAN';
    private static final String DIVISION_INVALID = 'INVALID';


    private static User ADMIN_USER {
        get { 
            if(ADMIN_USER == null){
                ADMIN_USER = [SELECT Id
                              FROM User
                              WHERE Profile.PermissionsModifyAllData = true
                              AND Profile.PermissionsManageUsers = true
                              AND IsActive = true LIMIT 1];
            }
            return ADMIN_USER;
        }
        set;
    }

    private static Profile profileWithModifyAll {
        get {
            if(profileWithModifyAll == null){
                profileWithModifyAll = [SELECT Id FROM Profile WHERE Profile.PermissionsModifyAllData = true LIMIT 1];
            }
        return profileWithModifyAll;
        }
        set;
    }

    private static Date DATE_TODAY {
        get {
            if(DATE_TODAY == null){
                DATE_TODAY = Date.today();
            }
            return DATE_TODAY;
        }
        set;
    }

    @TestSetup
    static void setupData(){

        User testUser = buildUser(DIVISION_US);
        insert testUser;

        AccountTriggerHandler.byPass = true;
        Account acct = buildAccount(testUser);
        insert acct;
        AccountTriggerHandler.byPass = false;

        Product2 tProd = buildProduct();

        Product2 tProdDropShip = buildProduct();
        tProdDropShip.Dropship_Only__c = true;

        List<Product2> lstProds = new List<Product2>();
        lstProds.add(tProd);
        lstProds.add(tProdDropShip);
        insert lstProds;

        PricebookEntry tPBE = buildPriceBookEntry(tProd);
        PricebookEntry tPBEDS = buildPriceBookEntry(tProdDropShip);
        
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        lstPBEs.add(tPBE);
        lstPBEs.add(tPBEDS);

        insert lstPBEs;

        Opportunity tOpp = buildOpportunity(acct, testUser);
        insert tOpp;

        OpportunityLineItem tOppLI = buildOppLineItem(tOpp, tPBE);
        OpportunityLineItem tOppLIDS = buildOppLineItem(tOpp, tPBEDS);
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        lstOLIs.add(tOppLI);
        lstOLIs.add(tOppLIDS);
        insert lstOLIs;
    }

    private static User buildUser(String strDivision){
        return new User(
            ProfileId = profileWithModifyAll.Id
            , LastName = 'last'
            , Email = 'test@example.com'
            , Username = 'proscitestUser' + System.currentTimeMillis() + '@prosci.com.unittest'
            , CompanyName = 'TEST'
            , Title = 'title'
            , Alias = 'alias'
            , TimeZoneSidKey = 'America/Los_Angeles'
            , EmailEncodingKey = 'UTF-8'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , Division = strDivision
        );
    }

    private static Account buildAccount(User testUser){
        return new Account(
            Name = 'Test Acc'
            , NAV_Customer__c = '123'
            , BillingStreet = '500 Main St'
            , BillingState = 'IL'
            , BillingCity = 'Chicago'
            , BillingCountry = 'IL'
            , BillingPostalCode = '60654'
            , Phone = '14245533535'
            , Fax = '44553535'
            , BC_Synced__c = true
            , BC_Synced_Instances__c = BC_INSTANCE_US
            , OwnerId = testUser.Id
        );
    }

    private static Opportunity buildOpportunity(Account acct, User testUser){
        return new Opportunity(
            Name = 'Test Oppo'
            , StageName = 'License Confirmed'
            , CloseDate = DATE_TODAY
            , LeadSource = 'Conference'
            , Shipment_Date__c = DATE_TODAY
            , Pricebook2Id = Test.getStandardPricebookId()
            , OwnerId = testUser.Id
            , AccountId = acct.Id
            , Sell_To__c = acct.Id
        );
    }

    private static Opportunity buildOpportunityMock(String strOwnerDivision){
        User testUser = buildUser(strOwnerDivision);
        testUser.Id = new TestUtils().generateDummyId(User.SObjectType);

        Account tAcct = buildAccount(testUser);
        tAcct.Id = new TestUtils().generateDummyId(Account.SObjectType);

        Opportunity tOpp = buildOpportunity(tAcct, testUser);
        tOpp = (Opportunity)writeFormulaFields(tOpp, new Map<String, Object>{
            'Salesperson_Code__c' => 'SPC'
        });
        tOpp.Owner = testUser;
        tOpp.Account = tAcct;
        tOpp.Id = new TestUtils().generateDummyId(Opportunity.SObjectType);
        return tOpp;
    }

    private static Product2 buildProduct(){
        return new Product2(
            Name = 'Test Product'
            , ProductCode = 'TEST_PRODUCT'
        );
    }

    private static PricebookEntry buildPriceBookEntry(Product2 prod){
        return new PricebookEntry(
            Product2Id = prod.Id
            , Pricebook2Id = Test.getStandardPricebookId()
            , UnitPrice = 0
            , IsActive = true
        );
    }

    private static OpportunityLineItem buildOppLineItem(Opportunity opp, PricebookEntry pbe){
        return new OpportunityLineItem(
            OpportunityId = opp.Id
            , PriceBookEntryId = pbe.Id
            , UnitPrice = 0
            , Quantity  = 1
        );
    }

    private static OpportunityLineItem buildOppLineItemMock(Opportunity opp, Boolean isDropShip){
        Product2 prod = buildProduct();
        prod.Id = new TestUtils().generateDummyId(Product2.SObjectType);
        prod.Dropship_Only__c = isDropShip;

        PricebookEntry pbe = buildPriceBookEntry(prod);
        pbe.Id = new TestUtils().generateDummyId(PricebookEntry.SObjectType);
        OpportunityLineItem oppLI = new OpportunityLineItem(
            OpportunityId = opp.Id
            , PriceBookEntryId = pbe.Id
            , UnitPrice = 0
            , Quantity  = 1
        );
        oppLI.Product2 = prod;
        oppLI.Id = new TestUtils().generateDummyId(OpportunityLineItem.SObjectType);
        return oppLI;
    }

    private static SObject buildChildRelationship(SObject sObj, List<SObject> lstChildren, String relationshipName){
        Map<String, Object> mapObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sObj));
        Map<String, Object> childMap = new Map<String, Object>();
        childMap.put('records', lstChildren);
        childMap.put('done', true);
        childMap.put('totalSize', lstChildren.size());
        mapObj.put(relationshipName, childMap);
        return (SObject)JSON.deserialize(JSON.serialize(mapObj), SObject.class);
    }

    private static SObject writeFormulaFields(SObject sObj, Map<String, Object> mapFormulaKeyValues){
        Map<String, Object> mapObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sObj));
        for(String key : mapFormulaKeyValues.keySet()){
            mapObj.put(key, mapFormulaKeyValues.get(key));
        }
        return (SObject)JSON.deserialize(JSON.serialize(mapObj), SObject.class);
    }


    private static Map<String, BC_Integration_Config__mdt> buildIntegrationConfigMetadata(){
        Map<String, BC_Integration_Config__mdt> mapInstanceIntegrationConfig = new Map<String, BC_Integration_Config__mdt>();

        mapInstanceIntegrationConfig.put(BC_INSTANCE_US, new BC_Integration_Config__mdt(
            Active__c = true                
            , Division__c = 'USA'
            , Integration_Name__c = AccountBCSyncCalloutService.INTEGRATION_CONFIG_NAME
            , Named_Credential__c = BC_INSTANCE_US
            , URI_Path__c = '/SFOpportunityEntries'
        ));

        mapInstanceIntegrationConfig.put(BC_INSTANCE_CAN, new BC_Integration_Config__mdt(
            Active__c = true                
            , Division__c = 'CAN'
            , Integration_Name__c = AccountBCSyncCalloutService.INTEGRATION_CONFIG_NAME
            , Named_Credential__c = BC_INSTANCE_CAN
            , URI_Path__c = '/SFOpportunityEntries'
        ));

        mapInstanceIntegrationConfig.put(BC_INSTANCE_ANZ, new BC_Integration_Config__mdt(
            Active__c = true                
            , Division__c = 'ANZ'
            , Integration_Name__c = AccountBCSyncCalloutService.INTEGRATION_CONFIG_NAME
            , Named_Credential__c = BC_INSTANCE_ANZ
            , URI_Path__c = '/SFOpportunityEntries'
        ));
        return mapInstanceIntegrationConfig;
    }

    @isTest static void execute_statusCode201(){

        Set<Id> tSetIds = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]).keySet();

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        new OpportunityBCSyncCalloutService(tSetIds).execute(); 

        Test.stopTest();

        List<Error_Log__c> rLstLogs = [SELECT Id FROM Error_Log__c];
        System.assertEquals(0, rLstLogs.size(), 'No Error Logs should be created');
        List<Opportunity> rLstOpps = [SELECT Id, BC_Synced__c, BC_Sync_Status__c FROM Opportunity];
        List<OpportunityLineItem> rLstOppItems = [SELECT Id, BC_Sync_Status__c, BC_Synced_Instances__c FROM OpportunityLineItem];
        System.assertNotEquals(0, rLstOpps.size());
        System.assertNotEquals(0, rLstOppItems.size());
        for(Opportunity opp : rLstOpps){
            System.assertEquals(OpportunityBCSyncCalloutService.STATUS_SYNCED, opp.BC_Sync_Status__c);
        }
        for(OpportunityLineItem oppItem : rLstOppItems){
            System.assertEquals(BC_INSTANCE_US, oppItem.BC_Synced_Instances__c);
            System.assertEquals(OpportunityBCSyncCalloutService.STATUS_SYNCED, oppItem.BC_Sync_Status__c);
        }
    }

    @IsTest static void executeMock_orderToUS_StatusCode201() {

        Set<Id> tSetIds = new Set<Id>();

        List<Opportunity> tLstOpps = new List<Opportunity>();
        Opportunity tOpp = buildOpportunityMock(DIVISION_US);
        tOpp.Dropship__c = null;

        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        OpportunityLineItem tOppLI = buildOppLineItemMock(tOpp, false);
        OpportunityLineItem tOppLI2 = buildOppLineItemMock(tOpp, false);
        lstOLIs.add(tOppLI);
        lstOLIs.add(tOppLI2);

        tOpp = (Opportunity)buildChildRelationship(tOpp, lstOLIs, 'OpportunityLineItems');
        tLstOpps.add(tOpp);
        tSetIds.add(tOpp.Id);
        
        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getOpportunities', tLstOpps);


        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        OpportunityBCSyncCalloutService calloutService = new OpportunityBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
        calloutService.execute();

        Test.stopTest();

        System.assertEquals(0, calloutService.lstErrorsToInsert.size(), 'No Error Logs should be instantiated');

        List<Opportunity> rListOpps = calloutService.lstOppsToUpdate;
        List<OpportunityLineItem> rLstOppProds = calloutService.lstOppLinesToUpdate;

        for(Opportunity opp : rListopps){

            System.assertEquals(true, opp.BC_Synced__c);
        }

        for(OpportunityLineItem oppProd : rLstOppProds){
            
            System.assertEquals(OpportunityBCSyncCalloutService.STATUS_SYNCED, oppProd.BC_Sync_Status__c);
            System.assertEquals(BC_INSTANCE_US, oppProd.BC_Synced_Instances__c, 'Each successfully synced instance should be set on record');
        }
    }

    @IsTest static void executeMock_orderToCAN_dropshipToUS_StatusCode201() {

        Set<Id> tSetIds = new Set<Id>();

        List<Opportunity> tLstOpps = new List<Opportunity>();
        Opportunity tOpp = buildOpportunityMock(DIVISION_CAN);
        tOpp.Dropship__c = DIVISION_US;

        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        OpportunityLineItem tOppLI = buildOppLineItemMock(tOpp, false);
        OpportunityLineItem tOppLIDropShip = buildOppLineItemMock(tOpp, true);
        lstOLIs.add(tOppLI);
        lstOLIs.add(tOppLIDropShip);

        tOpp = (Opportunity)buildChildRelationship(tOpp, lstOLIs, 'OpportunityLineItems');
        tLstOpps.add(tOpp);
        tSetIds.add(tOpp.Id);
        
        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getOpportunities', tLstOpps);


        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();

        OpportunityBCSyncCalloutService calloutService = new OpportunityBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
        calloutService.execute();

        Test.stopTest();

        System.assertEquals(0, calloutService.lstErrorsToInsert.size(), 'No Error Logs should be instantiated');

        List<Opportunity> rListOpps = calloutService.lstOppsToUpdate;
        List<OpportunityLineItem> rLstOppProds = calloutService.lstOppLinesToUpdate;

        for(Opportunity opp : rListopps){

            System.assertEquals(true, opp.BC_Synced__c);
        }

        Boolean standardProd = false;
        Boolean dropShipProd = false;

        Set<String> setExpectedInstances = new Set<String>{
            BC_INSTANCE_US
            , BC_INSTANCE_CAN
        };

        for(OpportunityLineItem oppProd : rLstOppProds){
            
            System.assertEquals(OpportunityBCSyncCalloutService.STATUS_SYNCED, oppProd.BC_Sync_Status__c);

            if(oppProd.Id == tOppLI.Id){
                

                System.assertNotEquals(null, oppProd.BC_Synced_Instances__c, 'Non Dropship products should go to both Dropship and Division Instance');
                Set<String> setActualInstances = new Set<String>();
                setActualInstances.addAll(oppProd.BC_Synced_Instances__c.split(';'));
                System.assertEquals(setExpectedInstances, setActualInstances, 'Non Dropship products should go to both Dropship and Division Instance');

                standardProd = true;
            } else if(oppProd.Id == tOppLIDropShip.Id){
                System.assertEquals(BC_INSTANCE_US, oppProd.BC_Synced_Instances__c, 'Dropship products should only go to both Dropship Instance');

                dropShipProd = true;
            }
        }

        System.assert(standardProd, 'Standard Product Opportunity Line Item should be asserted against');
        System.assert(dropShipProd, 'Dropship Product Opportunity Line Item should be asserted against');
    }

    @IsTest static void executeMock_orderToInvalid_InvalidConfigException() {

        Set<Id> tSetIds = new Set<Id>();

        List<Opportunity> tLstOpps = new List<Opportunity>();
        Opportunity tOpp = buildOpportunityMock(DIVISION_INVALID);
        tOpp.Dropship__c = null;

        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        OpportunityLineItem tOppLI = buildOppLineItemMock(tOpp, false);
        OpportunityLineItem tOppLI2 = buildOppLineItemMock(tOpp, false);
        lstOLIs.add(tOppLI);
        lstOLIs.add(tOppLI2);

        tOpp = (Opportunity)buildChildRelationship(tOpp, lstOLIs, 'OpportunityLineItems');
        tLstOpps.add(tOpp);
        tSetIds.add(tOpp.Id);
        
        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getOpportunities', tLstOpps);


        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        CustomMetadataException mtdEx;

        Test.startTest();

        try {
            OpportunityBCSyncCalloutService calloutService = new OpportunityBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
            calloutService.execute();
        } catch (CustomMetadataException ex){
            mtdEx = ex;
        }

        Test.stopTest();

        System.assertNotEquals(null, mtdEx);
        System.assertEquals(OpportunityBCSyncCalloutService.EXCEPTION_MISSING_CUSTOM_METADATA_DIVISION + DIVISION_INVALID, mtdEx.getMessage());
    }

    @IsTest static void executeMock_orderToCAN_DropShipToInvalid_InvalidConfigException() {

        Set<Id> tSetIds = new Set<Id>();

        List<Opportunity> tLstOpps = new List<Opportunity>();
        Opportunity tOpp = buildOpportunityMock(DIVISION_CAN);
        tOpp.Dropship__c = DIVISION_INVALID;

        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        OpportunityLineItem tOppLI = buildOppLineItemMock(tOpp, false);
        OpportunityLineItem tOppLI2 = buildOppLineItemMock(tOpp, false);
        lstOLIs.add(tOppLI);
        lstOLIs.add(tOppLI2);

        tOpp = (Opportunity)buildChildRelationship(tOpp, lstOLIs, 'OpportunityLineItems');
        tLstOpps.add(tOpp);
        tSetIds.add(tOpp.Id);
        
        Map<String, Object> mapMethodReturns = new Map<String, Object>();
        mapMethodReturns.put('getIntegrationConfigMap', buildIntegrationConfigMetadata());
        mapMethodReturns.put('getOpportunities', tLstOpps);


        BCSyncDAO mockServiceDAO = (BCSyncDAO)Test.createStub(BCSyncDAO.Class, new TestUtils_TestMock(mapMethodReturns));
        SObjectDAO mockSObjDAO = (SOBjectDAO)Test.createStub(SObjectDAO.Class, new TestUtils_TestMock());

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        CustomMetadataException mtdEx;

        Test.startTest();

        try {
            OpportunityBCSyncCalloutService calloutService = new OpportunityBCSyncCalloutService(tSetIds, mockServiceDAO, mockSObjDAO);
            calloutService.execute();
        } catch (CustomMetadataException ex){
            mtdEx = ex;
        }

        Test.stopTest();

        System.assertNotEquals(null, mtdEx);
        System.assertEquals(OpportunityBCSyncCalloutService.EXCEPTION_MISSING_CUSTOM_METADATA_DROPSHIP + DIVISION_INVALID, mtdEx.getMessage());
    }

    @isTest static void trigger_execute_statusCode201(){

        List<Opportunity> tLstOpps = [SELECT BC_Sync_Status__c FROM Opportunity];
        for(Opportunity opp : tLstOpps){
            opp.BC_Sync_Status__c = 'Pending Sync';
        }

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201));

        Test.startTest();
 
        update tLstOpps;

        Test.stopTest();

        List<Error_Log__c> rLstLogs = [SELECT Id FROM Error_Log__c];
        System.assertEquals(0, rLstLogs.size(), 'No Error Logs should be created');
        List<Opportunity> rLstOpps = [SELECT Id, BC_Synced__c, BC_Sync_Status__c FROM Opportunity];
        List<OpportunityLineItem> rLstOppItems = [SELECT Id, BC_Sync_Status__c FROM OpportunityLineItem];
        System.assertNotEquals(0, rLstOpps.size());
        System.assertNotEquals(0, rLstOppItems.size());
        for(Opportunity opp : rLstOpps){
            System.assertEquals(true, opp.BC_Synced__c);
            System.assertEquals(OpportunityBCSyncCalloutService.STATUS_SYNCED, opp.BC_Sync_Status__c);
        }
        for(OpportunityLineItem oppItem : rLstOppItems){
            System.assertEquals(OpportunityBCSyncCalloutService.STATUS_SYNCED, oppItem.BC_Sync_Status__c);
        }
    }

    @isTest static void execute_statusCode400_calloutException(){

        Set<Id> tSetIds = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]).keySet();

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(400));

        Test.startTest();

        new OpportunityBCSyncCalloutService(tSetIds).execute();

        Test.stopTest();

        List<Error_Log__c> rLstLogs = [SELECT Exception_Type__c, Category__c FROM Error_Log__c];
        System.assertNotEquals(0, rLstLogs.size(), 'An Error Log should be created to capture the error');
        for(Error_Log__c log : rLstLogs){
            System.assertEquals(new CalloutException().getTypeName(), log.Exception_Type__c);
            System.assertEquals(OpportunityBCSyncCalloutService.EXCEPTION_CATEGORY, log.Category__c);
        }
        List<Opportunity> rLstOpps = [SELECT Id, BC_Synced__c, BC_Sync_Status__c FROM Opportunity];
        List<OpportunityLineItem> rLstOppItems = [SELECT Id, BC_Sync_Status__c FROM OpportunityLineItem];
        System.assertNotEquals(0, rLstOpps.size());
        System.assertNotEquals(0, rLstOppItems.size());
        for(Opportunity opp : rLstOpps){
            System.assertEquals(false, opp.BC_Synced__c);
            System.assertEquals(OpportunityBCSyncCalloutService.STATUS_FAILED, opp.BC_Sync_Status__c);
        }
        for(OpportunityLineItem oppItem : rLstOppItems){
            System.assertNotEquals(OpportunityBCSyncCalloutService.STATUS_SYNCED, oppItem.BC_Sync_Status__c);
        }
    }

    @isTest static void execute_genericException(){

        Set<Id> tSetIds = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]).keySet();

        Test.setMock(HttpCalloutMock.class, new PushToBcGenericMock(201).forceMockException());

        Test.startTest();

        new OpportunityBCSyncCalloutService(tSetIds).execute();

        Test.stopTest();

        List<Error_Log__c> rLstLogs = [SELECT Exception_Type__c, Category__c FROM Error_Log__c];
        System.assertNotEquals(0, rLstLogs.size(), 'An Error Log should be created to capture the error');
        for(Error_Log__c log : rLstLogs){
            System.assertEquals(new PushToBcGenericMock.MockException().getTypeName(), log.Exception_Type__c);
            System.assertEquals(OpportunityBCSyncCalloutService.EXCEPTION_CATEGORY, log.Category__c);
        }
        List<Opportunity> rLstOpps = [SELECT Id, BC_Synced__c, BC_Sync_Status__c FROM Opportunity];
        List<OpportunityLineItem> rLstOppItems = [SELECT Id, BC_Sync_Status__c FROM OpportunityLineItem];
        System.assertNotEquals(0, rLstOpps.size());
        System.assertNotEquals(0, rLstOppItems.size());
        for(Opportunity opp : rLstOpps){
            System.assertEquals(false, opp.BC_Synced__c);
            System.assertEquals(OpportunityBCSyncCalloutService.STATUS_FAILED, opp.BC_Sync_Status__c);
        }
        for(OpportunityLineItem oppItem : rLstOppItems){
            System.assertNotEquals(OpportunityBCSyncCalloutService.STATUS_SYNCED, oppItem.BC_Sync_Status__c);
        }
    }
}