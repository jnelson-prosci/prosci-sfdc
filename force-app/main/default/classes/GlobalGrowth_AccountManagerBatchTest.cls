/***********************************************************************************************************************        
Name            : GlobalGrowth_AccountManagerBatch
Author          : Slalom Team, Reggie Thompson
Date            : 07/16/24
@description    : Test class for CS_HealthCheckBatch[Helper]
***********************************************************************************************************************/
@IsTest
private class GlobalGrowth_AccountManagerBatchTest {

    @testSetup
    static void setupData() {
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            Account testAccount = new Account(
                name = 'Test Account ' + i,
                Industry__c = ,
                CurrencyIsoCode = 'USD'
            );

            testAccounts.add(testAccount);
        }

        insert testAccounts;

        List<User> testUsers = new List<User>();
        Profile testSysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        for (Integer i = 0; i < 200; i++) {
            User testUser = new User(
                CurrencyIsoCode = 'USD',
                IsActive = true,
                Alias = 'tU' + i,
                SenderEmail = 'testUser' + i + '@example.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Test',
                LastName = 'User ' + i,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testSysAdminId.Id,
                TimeZonesIdKey = 'America/Denver',
                UserName = email
            );

            testUsers.add(testUser);
        }

        insert testUsers;

        List<Contact> testContacts = new List<Contact>();
        for (Account testAccount : testAccounts) {
            Integer i = 0;

            List<Contact> testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                AccountId = testAccounts[i],
                CurrencyIsoCode = 'USD',
                pse__Salesforce_User__c = testUsers[i]
            );

            testContacts.add(testContact);
            i++;
        }

        insert testContacts;

        for (Account testAccount : testAccounts) {
            Integer i = 0;

            testAccount.Account_Manager__c = testContacts[i].Id;
        }

        update testAccounts;
    }

    // @isTest
    // static void testAccountManagerSync() {

    //     Test.startTest();
    //     GlobalGrowth_AccountManagerBatch batch = new GlobalGrowth_AccountManagerBatch();
    //     Database.executeBatch(batch);
    //     Test.stopTest();
    // }
}