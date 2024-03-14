@isTest
private class OpportunityBCSyncFilterTest {

    private static final Integer RECORD_COUNT = 200;

    @isTest static void filterRecords_noChange_returnEmpty(){
        List<Opportunity> tLstOpps = new List<Opportunity>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstOpps.add(new Opportunity(
                Id = new TestUtils().generateDummyId(Opportunity.SObjectType)
                , BC_Sync_Status__c = null
            ));
        }

        Map<Id, Opportunity> tMapOldOpps = new Map<Id, Opportunity>(tLstOpps.deepClone(true));

        List<Opportunity> rLstOpps;

        Test.startTest();

        rLstOpps = new OpportunityBCSyncFilter().filterRecords(tLstOpps, tMapOldOpps);

        Test.stopTest();

        System.assertEquals(0, rLstOpps.size()
            , 'When sync status does not change, no opportunities should be returned');
    }

    @isTest static void filterRecords_changeToPendingSync_returnAll(){
        List<Opportunity> tLstOpps = new List<Opportunity>();

        for(Integer i=0; i < RECORD_COUNT; i++){
            tLstOpps.add(new Opportunity(
                Id = new TestUtils().generateDummyId(Opportunity.SObjectType)
                , BC_Sync_Status__c = OpportunityBCSyncFilter.STATUS_PENDING_SYNC
            ));
        }

        Map<Id, Opportunity> tMapOldOpps = new Map<Id, Opportunity>(tLstOpps.deepClone(true));
        for(Opportunity oldOpp : tMapOldOpps.values()){
            oldOpp.BC_Sync_Status__c = null;
        }

        List<Opportunity> rLstOpps;

        Test.startTest();

        rLstOpps = new OpportunityBCSyncFilter().filterRecords(tLstOpps, tMapOldOpps);

        Test.stopTest();

        System.assertEquals(tLstOpps.size(), rLstOpps.size()
            , 'When sync status is changed to Pending Sync, all opportunities should be returned');
    }
}