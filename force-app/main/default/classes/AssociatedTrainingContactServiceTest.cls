@isTest
public with sharing class AssociatedTrainingContactServiceTest {

    @isTest
    public static void getAssociatedTrainingContactsByTrainingId() {

        Account testAccount = new Account();
        testAccount.Name = 'TestAccount';
        insert testAccount;

        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        testContact.AccountId = testAccount.Id;
        insert testContact;

        Training_Event__c testTrainingEvent = new Training_Event__c();
        testTrainingEvent.Name = 'Test Training Event';
        testTrainingEvent.Type_of_Event__c = 'Test Event';
        testTrainingEvent.Title__c = 'Test Title';
        testTrainingEvent.Start_Date__c = Date.today();
        testTrainingEvent.Start_Date__c = Date.today().addMonths(1);
        insert testTrainingEvent;

        List<Training_Event__c> lstTE = [SELECT Id, Name FROM Training_Event__c];
        List<Contact> lstCon = [SELECT Id, Name FROM Contact];

        Id testTrainingEventId = lstTE[0].Id;

        Associated_Training_Contacts__c testATC = new Associated_Training_Contacts__c();
        testATC.Training_Event__c = lstTE[0].Id;
        testATC.Contact__c = lstCon[0].Id;
        insert testATC;

        Test.startTest();

        List<Associated_Training_Contacts__c> res = AssociatedTrainingContactService.getDataByTrainingEventId(testTrainingEventId);

        Test.stopTest();

        System.assertEquals(1, res.size());
        System.assertEquals(testTrainingEventId, res[0].Training_Event__c);

    }
}