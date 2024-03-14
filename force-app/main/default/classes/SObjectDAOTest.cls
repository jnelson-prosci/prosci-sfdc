@isTest
private with sharing class SObjectDAOTest {

    private static final Integer RECORD_COUNT = 200;
    private static final String NAME_BEFORE = 'Test Account';
    private static final String NAME_AFTER = 'Updated Account';
    private static final String NAME_INVALID_LENGTH {
        get {
            if(NAME_INVALID_LENGTH == null){

                NAME_INVALID_LENGTH = '';
                for(Integer i=0; i <= Account.Name.getDescribe().getLength(); i ++){
                    NAME_INVALID_LENGTH += 'x';
                }
            }
            return NAME_INVALID_LENGTH;
        }
        set;
    }

    @TestSetup
    static void makeData(){
        List<Account> lstAccts = new List<Account>();
        for(Integer i=0; i < RECORD_COUNT; i++){
            lstAccts.add(new Account(
                Name = NAME_BEFORE + i
            ));
        }
        insert lstAccts;
    }

    @isTest static void updateRecords_success(){
        List<Account> tLstAccts = [SELECT Name FROM Account];
        for(Account acct : tLstAccts){
            acct.Name = acct.Name.replace(NAME_BEFORE, NAME_AFTER);
        }

        Test.startTest();

        new SObjectDAO().updateRecords(tLstAccts);

        Test.stopTest();

        List<Account> rLstAccts = [SELECT Name FROM Account];

        System.assertEquals(RECORD_COUNT, rLstAccts.size());
        for(Account acct : rLstAccts){
            // get integer at end of name
            String strSuffix = acct.Name.replace(NAME_AFTER, '');
            System.assertEquals(NAME_AFTER + strSuffix, acct.Name);
        }
    }

    @isTest static void updateRecords_error_thrownException(){
        List<Account> tLstAccts = [SELECT Name FROM Account];
        for(Account acct : tLstAccts){
            acct.Name = acct.Name.replace(NAME_BEFORE, NAME_INVALID_LENGTH);
        }

        DmlException rDmlEx;

        Test.startTest();

        try {
            new SObjectDAO().updateRecords(tLstAccts);
        } catch (DmlException dmlEx){
            rDmlEx = dmlEx;
        }

        Test.stopTest();

        System.assertNotEquals(null, rDmlEx);
        List<Account> rLstAccts = [SELECT Name FROM Account];

        System.assertEquals(RECORD_COUNT, rLstAccts.size());
        for(Account acct : rLstAccts){
            // get integer at end of name
            String strSuffix = acct.Name.replace(NAME_BEFORE, '');
            System.assertEquals(NAME_BEFORE + strSuffix, acct.Name);
        }
    }

    @isTest static void updateRecordsAllowPartialSuccess_failedUpdate_noError(){
        List<Account> tLstAccts = [SELECT Name FROM Account];
        for(Account acct : tLstAccts){
            acct.Name = acct.Name.replace(NAME_BEFORE, NAME_INVALID_LENGTH);
        }

        Test.startTest();

        new SObjectDAO().updateRecordsAllowPartialSuccess(tLstAccts);

        Test.stopTest();

        List<Account> rLstAccts = [SELECT Name FROM Account];
        List<Error_Log__c> rLstErrorLogs = [SELECT Id FROM Error_Log__c];

        System.assertEquals(0, rLstErrorLogs.size());
        System.assertEquals(RECORD_COUNT, rLstAccts.size());
        for(Account acct : rLstAccts){
            // get integer at end of name
            String strSuffix = acct.Name.replace(NAME_BEFORE, '');
            System.assertEquals(NAME_BEFORE + strSuffix, acct.Name);
        }
    }

    @isTest static void updateRecordsAllowPartialSuccess_success(){
        List<Account> tLstAccts = [SELECT Name FROM Account];
        for(Account acct : tLstAccts){
            acct.Name = acct.Name.replace(NAME_BEFORE, NAME_AFTER);
        }

        Test.startTest();

        new SObjectDAO().updateRecordsAllowPartialSuccess(tLstAccts);

        Test.stopTest();

        List<Account> rLstAccts = [SELECT Name FROM Account];

        System.assertEquals(RECORD_COUNT, rLstAccts.size());
        for(Account acct : rLstAccts){
            // get integer at end of name
            String strSuffix = acct.Name.replace(NAME_AFTER, '');
            System.assertEquals(NAME_AFTER + strSuffix, acct.Name);
        }
    }

    @isTest static void updateRecordsAndLogErrors_success(){
        String strCategory = 'Test Error';
        List<Account> tLstAccts = [SELECT Name FROM Account];
        for(Account acct : tLstAccts){
            acct.Name = acct.Name.replace(NAME_BEFORE, NAME_AFTER);
        }

        Test.startTest();

        new SObjectDAO().updateRecordsAndLogErrors(tLstAccts, strCategory);

        Test.stopTest();

        List<Account> rLstAccts = [SELECT Name FROM Account];
        List<Error_Log__c> rLstErrorLogs = [SELECT Id FROM Error_Log__c];

        System.assertEquals(0, rLstErrorLogs.size());
        System.assertEquals(RECORD_COUNT, rLstAccts.size());
        for(Account acct : rLstAccts){
            // get integer at end of name
            String strSuffix = acct.Name.replace(NAME_AFTER, '');
            System.assertEquals(NAME_AFTER + strSuffix, acct.Name);
        }
    }

    @isTest static void updateRecordsAndLogErrors_failedUpdate_loggedErrors(){
        String strCategory = 'Test Error';
        List<Account> tLstAccts = [SELECT Name FROM Account];
        for(Account acct : tLstAccts){
            acct.Name = acct.Name.replace(NAME_BEFORE, NAME_INVALID_LENGTH);
        }

        Test.startTest();

        new SObjectDAO().updateRecordsAndLogErrors(tLstAccts, strCategory);

        Test.stopTest();

        List<Account> rLstAccts = [SELECT Name FROM Account];
        List<Error_Log__c> rLstErrorLogs = [SELECT Id, Category__c, Associated_Records__c FROM Error_Log__c];

        Set<Id> rSetAssocRecIds = new Set<Id>();

        System.assertEquals(RECORD_COUNT, rLstErrorLogs.size());

        for(Error_Log__c errLog : rLstErrorLogs){
            System.assertEquals(strCategory, errLog.Category__c);
            rSetAssocRecIds.add(errLog.Associated_Records__c);
        }
        System.assertEquals(RECORD_COUNT, rLstAccts.size());
        System.assertEquals(RECORD_COUNT, rSetAssocRecIds.size());
        System.assert(rSetAssocRecIds.containsAll(new Map<Id, Account>(rLstAccts).keySet()));
        for(Account acct : rLstAccts){
            // get integer at end of name
            String strSuffix = acct.Name.replace(NAME_BEFORE, '');
            System.assertEquals(NAME_BEFORE + strSuffix, acct.Name);
        }
    }

    @isTest
    static void getSaveResult(){
        SObjectDAO tSObjDAO = new SObjectDAO();
        tSObjDAO.lstSaveResult = new List<Database.SaveResult>();

        List<Database.SaveResult> rLstSaveResult;

        Test.startTest();

        rLstSaveResult = tSObjDAO.getSaveResult();

        Test.stopTest();

        System.assertEquals(new List<Database.SaveResult>(), rLstSaveResult);
    }


}