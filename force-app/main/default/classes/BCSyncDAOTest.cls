@isTest
private class BCSyncDAOTest {

    @isTest static void getRecords_queryMappingConfigFields(){

        Account tAcct = new Account(Name = 'Test Name', BillingState = 'MA');
        insert tAcct;

        List<BC_Integration_Mapping__mdt> tLstFieldMappings = new List<BC_Integration_Mapping__mdt>();
        tLstFieldMappings.add(new BC_Integration_Mapping__mdt(
            Field_API_Name__c = 'BillingState'
        ));

        Set<String> tSetFields = new Set<String>{'Name'};

        Test.startTest();

        List<Account> rLstAccts = new BCSyncDAO().getRecords('Account', tSetFields, tLstFieldMappings, new Set<Id>{tAcct.Id});

        Test.stopTest();

        System.assertEquals(1, rLstAccts.size(), 'The account should be returned by the query');
        Account rAcct = rLstAccts[0];

        System.assertEquals(rAcct.Name, tAcct.Name, 'The name should have been queried because of the set of field names');
        System.assertEquals(rAcct.BillingState, tAcct.BillingState, 'The Billing State should have been queried because of the mapping configuration');

    }
}