/**
 * Test class to validate functionality of TriggerHandler
 * @group UnitTest
 */
@isTest
private class TriggerHandler_Test {

    @isTest static void beforeInsert_override_isCalled(){

        Test.startTest();
        TestTriggerHandler testHandler = new TestTriggerHandler();
        testHandler.executeOperationType(TriggerOperation.BEFORE_INSERT);
        Test.stopTest();

        System.assertEquals(true, testHandler.beforeInsert_isCalled
            , 'Before Insert Override method should be called');
    }

    @isTest static void afterInsert_override_isCalled(){

        Test.startTest();
        TestTriggerHandler testHandler = new TestTriggerHandler();
        testHandler.executeOperationType(TriggerOperation.AFTER_INSERT);
        Test.stopTest();

        System.assertEquals(true, testHandler.afterInsert_isCalled
            , 'After Insert Override method should be called');
    }

    @isTest static void beforeUpdate_override_isCalled(){

        Test.startTest();
        TestTriggerHandler testHandler = new TestTriggerHandler();
        testHandler.executeOperationType(TriggerOperation.BEFORE_UPDATE);
        Test.stopTest();

        System.assertEquals(true, testHandler.beforeUpdate_isCalled
            , 'Before Update Override method should be called');
    }

    @isTest static void afterUpdate_override_isCalled(){

        Test.startTest();
        TestTriggerHandler testHandler = new TestTriggerHandler();
        testHandler.executeOperationType(TriggerOperation.AFTER_UPDATE);
        Test.stopTest();

        System.assertEquals(true, testHandler.afterUpdate_isCalled
            , 'After Update Override method should be called');
    }

    @isTest static void beforeDelete_override_isCalled(){

        Test.startTest();
        TestTriggerHandler testHandler = new TestTriggerHandler();
        testHandler.executeOperationType(TriggerOperation.BEFORE_DELETE);
        Test.stopTest();

        System.assertEquals(true, testHandler.beforeDelete_isCalled
            , 'Before Delete Override method should be called');
    }

    @isTest static void afterDelete_override_isCalled(){

        Test.startTest();
        TestTriggerHandler testHandler = new TestTriggerHandler();
        testHandler.executeOperationType(TriggerOperation.AFTER_DELETE);
        Test.stopTest();

        System.assertEquals(true, testHandler.afterDelete_isCalled
            , 'After Delete Override method should be called');
    }

    @isTest static void afterUndelete_override_isCalled(){

        Test.startTest();
        TestTriggerHandler testHandler = new TestTriggerHandler();
        testHandler.executeOperationType(TriggerOperation.AFTER_UNDELETE);
        Test.stopTest();

        System.assertEquals(true, testHandler.afterUndelete_isCalled
            , 'After Undelete Override method should be called');
    }

    @isTest static void executeOperationType(){
        Test.startTest();
        TriggerHandler testHandler = new TriggerHandler();
        testHandler.executeOperationType(TriggerOperation.BEFORE_INSERT);
        testHandler.executeOperationType(TriggerOperation.AFTER_INSERT);
        testHandler.executeOperationType(TriggerOperation.BEFORE_UPDATE);
        testHandler.executeOperationType(TriggerOperation.AFTER_UPDATE);
        testHandler.executeOperationType(TriggerOperation.BEFORE_DELETE);
        testHandler.executeOperationType(TriggerOperation.AFTER_DELETE);
        testHandler.executeOperationType(TriggerOperation.AFTER_UNDELETE);
        Test.stopTest();

        System.assert(true, 'Base Handler class should execute without error');

    }
    
    @isTest static void byPassTrigger_noTriggerManagement_NoByPass(){
        TestTriggerHandler handler = new TestTriggerHandler();
        
        Boolean rByPass;
        
        Test.startTest();
        
        rByPass = handler.byPassTrigger();
        
        Test.stopTest();
        
        System.assertEquals(false, rByPass);
        
    }
    
    @isTest static void byPassTrigger_CustSettingSetFalse_NoByPass(){
        TestTriggerHandler handler = new TestTriggerHandler();
        insert new Trigger_Management__c(Test__c = false);
        
        Boolean rByPass;
        
        Test.startTest();
        
        rByPass = handler.byPassTrigger();
        
        Test.stopTest();
        
        System.assertEquals(false, rByPass);
        
    }
    
    @isTest static void byPassTrigger_CustSettingSetTrue_ByPass(){
        TestTriggerHandler handler = new TestTriggerHandler();
        insert new Trigger_Management__c(Test__c = true);
        
        Boolean rByPass;
        
        Test.startTest();
        
        rByPass = handler.byPassTrigger();
        
        Test.stopTest();
        
        System.assertEquals(true, rByPass);
        
    }
    
    @isTest static void execute_CustSettingSetTrue_ByPass(){
        TestTriggerHandler handler = new TestTriggerHandler();
        insert new Trigger_Management__c(Test__c = true);
        
        Test.startTest();
        
        handler.execute();
        
        Test.stopTest();
        
        System.assert(true, 'Base Handler class should execute without error');
        
    }
    
    @isTest static void execute_CustSettingSetFalse_UndefinedOperationTypeException(){
        TestTriggerHandler handler = new TestTriggerHandler();
        insert new Trigger_Management__c(Test__c = false);
        
        TriggerHandler.TriggerException rEx;
        
        Test.startTest();
        try {
        	handler.execute();
        } catch (TriggerHandler.TriggerException tEx){
            rEx = tEx;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, rEx, 'Execute should run and throw an error for undefined trigger operation type');
        
    }

    /**
     * Extension of TriggerHandler to validate event method overrides are called.
     */
    public class TestTriggerHandler extends TriggerHandler {

        public Boolean beforeInsert_isCalled = false;
        public Boolean afterInsert_isCalled = false;
        public Boolean beforeUpdate_isCalled = false;
        public Boolean afterUpdate_isCalled = false;
        public Boolean beforeDelete_isCalled = false;
        public Boolean afterDelete_isCalled = false;
        public Boolean afterUndelete_isCalled = false;

        protected override void beforeInsert(){
            beforeInsert_isCalled = true;
        }
        protected override void afterInsert(){
            afterInsert_isCalled = true;
        }
        protected override void beforeUpdate(){
            beforeUpdate_isCalled = true;
        }
        protected override void afterUpdate(){
            afterUpdate_isCalled = true;
        }
        protected override void beforeDelete(){
            beforeDelete_isCalled = true;
        }
        protected override void afterDelete(){
            afterDelete_isCalled = true;
        }
        protected override void afterUndelete(){
            afterUndelete_isCalled = true;
        }
    }
}