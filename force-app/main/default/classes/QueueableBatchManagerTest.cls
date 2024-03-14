@isTest
private class QueueableBatchManagerTest {

    private static final Integer BATCH_LIMIT = 100;

    @isTest static void setBatchIds_moreThanLimit_fullBatchSize(){
        Integer COUNT = BATCH_LIMIT * 2;
        Set<Id> tSetIds = new Set<Id>();

        for(Integer i=0; i<COUNT; i++){
            tSetIds.add(new TestUtils().generateDummyId(Opportunity.SObjectType));
        }

        Set<Id> rSetBatchIds;
        Set<Id> rSetUnprocessedIds;

        Test.startTest();

        QueueableBatchManager batchManager = new QueueableBatchManager();
        batchManager.BATCH_LIMIT = BATCH_LIMIT;
        batchManager.setIds(tSetIds);
        rSetBatchIds = batchManager.getBatchIds();
        rSetUnprocessedIds = batchManager.getUnprocessedIds();

        Test.stopTest();

        System.assertEquals(BATCH_LIMIT, rSetBatchIds.size());
        System.assertEquals(COUNT - BATCH_LIMIT, rSetUnprocessedIds.size());
    }

    @isTest static void setBatchIds_lessThanLimit_partialBatchSize(){
        Integer COUNT = Integer.valueOf(Math.floor(BATCH_LIMIT * .5));
        Set<Id> tSetIds = new Set<Id>();

        for(Integer i=0; i<COUNT; i++){
            tSetIds.add(new TestUtils().generateDummyId(Opportunity.SObjectType));
        }

        Set<Id> rSetBatchIds;
        Set<Id> rSetUnprocessedIds;

        Test.startTest();

        QueueableBatchManager batchManager = new QueueableBatchManager();
        batchManager.BATCH_LIMIT = BATCH_LIMIT;
        batchManager.setIds(tSetIds);
        rSetBatchIds = batchManager.getBatchIds();
        rSetUnprocessedIds = batchManager.getUnprocessedIds();

        Test.stopTest();

        System.assertEquals(COUNT, rSetBatchIds.size());
        System.assertEquals(0, rSetUnprocessedIds.size());
    }

}