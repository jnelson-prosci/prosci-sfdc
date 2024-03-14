@isTest
private class BCSyncUtilsTest {

    public class TestWrapper{}

    @isTest static void buildRequestBody_noMapNoChange(){
        Account tAcct = new Account(Name = 'Test Name');
        Object tObj = new TestWrapper();
        List<BC_Integration_Mapping__mdt> tLstFieldMappings = new List<BC_Integration_Mapping__mdt>();

        Map<String, Object> rObj;

        Test.startTest();

        rObj = BCSyncUtils.buildRequestBody(tAcct, tObj, tLstFieldMappings, false);

        Test.stopTest();

        System.assertNotEquals(null, rObj);
        System.assertEquals(0, rObj.size(), 'No values should be mapped');

    }

    @isTest static void buildRequestBody_mapName(){

        String strName = 'Test Name';
        String strBillingState = 'MA';
        Account tAcct = new Account(Name = strName, BillingState = strBillingState);
        Object tObj = new TestWrapper();
        List<BC_Integration_Mapping__mdt> tLstFieldMappings = new List<BC_Integration_Mapping__mdt>();
        tLstFieldMappings.add(new BC_Integration_Mapping__mdt(
            Field_API_Name__c = 'Name'
            , JSON_Key__c = 'name_key'
            , Insert_Only__c = false
        ));
        tLstFieldMappings.add(new BC_Integration_Mapping__mdt(
            Field_API_Name__c = 'BillingState'
            , JSON_Key__c = 'billing_state'
            , Insert_Only__c = false
        ));

        Map<String, Object> rObj;

        Test.startTest();

        rObj = BCSyncUtils.buildRequestBody(tAcct, tObj, tLstFieldMappings, false);

        Test.stopTest();

        System.assertNotEquals(null, rObj);
        System.assertEquals(2, rObj.size(), 'Two values should be mapped');
        System.assertEquals(strName, rObj.get('name_key'));
        System.assertEquals(strBillingState, rObj.get('billing_state'));

    }

    @isTest static void buildRequestBody_mapName_excludeInsertOnlyOnUpdate(){

        String strName = 'Test Name';
        String strBillingState = 'MA';
        Account tAcct = new Account(Name = strName, BillingState = strBillingState);
        Object tObj = new TestWrapper();
        List<BC_Integration_Mapping__mdt> tLstFieldMappings = new List<BC_Integration_Mapping__mdt>();
        tLstFieldMappings.add(new BC_Integration_Mapping__mdt(
            Field_API_Name__c = 'Name'
            , JSON_Key__c = 'name_key'
            , Insert_Only__c = true
        ));
        tLstFieldMappings.add(new BC_Integration_Mapping__mdt(
            Field_API_Name__c = 'BillingState'
            , JSON_Key__c = 'billing_state'
            , Insert_Only__c = false
        ));

        Map<String, Object> rObj;

        Test.startTest();

        rObj = BCSyncUtils.buildRequestBody(tAcct, tObj, tLstFieldMappings, false);

        Test.stopTest();

        System.assertNotEquals(null, rObj);
        System.assertEquals(1, rObj.size(), 'Two values should be mapped');
        System.assertEquals(null, rObj.get('name_key'));
        System.assertEquals(strBillingState, rObj.get('billing_state'));

    }

    @isTest static void buildRequestBody_mapName_includeInsertOnlyOnInsert(){

        String strName = 'Test Name';
        String strBillingState = 'MA';
        Account tAcct = new Account(Name = strName, BillingState = strBillingState);
        Object tObj = new TestWrapper();
        List<BC_Integration_Mapping__mdt> tLstFieldMappings = new List<BC_Integration_Mapping__mdt>();
        tLstFieldMappings.add(new BC_Integration_Mapping__mdt(
            Field_API_Name__c = 'Name'
            , JSON_Key__c = 'name_key'
            , Insert_Only__c = true
        ));
        tLstFieldMappings.add(new BC_Integration_Mapping__mdt(
            Field_API_Name__c = 'BillingState'
            , JSON_Key__c = 'billing_state'
            , Insert_Only__c = false
        ));

        Map<String, Object> rObj;

        Test.startTest();

        rObj = BCSyncUtils.buildRequestBody(tAcct, tObj, tLstFieldMappings, true);

        Test.stopTest();

        System.assertNotEquals(null, rObj);
        System.assertEquals(2, rObj.size(), 'Two values should be mapped');
        System.assertEquals(strName, rObj.get('name_key'));
        System.assertEquals(strBillingState, rObj.get('billing_state'));

    }

}