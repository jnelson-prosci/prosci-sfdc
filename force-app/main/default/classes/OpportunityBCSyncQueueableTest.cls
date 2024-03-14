@isTest
private class OpportunityBCSyncQueueableTest {

    @isTest static void execute_exception(){
        Set<Id> tSetIds = new Set<Id>();

        QueueableBatchManager qBatchManager_Mock = (QueueableBatchManager)
            Test.createStub(QueueableBatchManager.Class
                            , new TestUtils_TestMock().forceException('getBatchIds'));

        OpportunityBCSyncQueueable tQueueable = new OpportunityBCSyncQueueable(tSetIds, qBatchManager_Mock);

        Test.startTest();

        String jobId = System.enqueueJob(tQueueable);

        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Queueable should have enqueued successfully');

        List<Error_Log__c> rLstLogs = [SELECT Exception_Type__c, Category__c FROM Error_Log__c];
        System.assertEquals(1, rLstLogs.size(), 'An error log should be created when execute encounters an exception');
        for(Error_Log__c log : rLstLogs){
            System.assertEquals(new TestUtils_TestMock.TestMockException().getTypeName(), log.Exception_Type__c
                , 'The test mock exception should be thrown');
            System.assertEquals(OpportunityBCSyncCalloutService.EXCEPTION_CATEGORY, log.Category__c
                , 'The log should be categorized by the associated service for reporting');
        }
    }
}