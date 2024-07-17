/***********************************************************************************************************************        
Name            : GlobalGrowth_AccountManagerBatch
Author          : Slalom Team, Reggie Thompson
Date            : 07/16/24
@description    : Test class for GlobalGrowth_AccountManagerBatch
***********************************************************************************************************************/
@IsTest
private class GlobalGrowth_AccountManagerBatchTest {

    @testSetup
    static void setupData() {
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            Account testAccount = new Account(
                Name = 'Test Account ' + i,
                Industry__c = 'Consulting',
                CurrencyIsoCode = 'USD'
            );

            if (i >= 150) {
                testAccount.Asset_Count__c = i;
            }

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
                Email = 'testUser' + i + '@example.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Test',
                LastName = 'User ' + i,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testSysAdminId.Id,
                TimeZonesIdKey = 'America/Denver',
                UserName = 'userTest' + i + '@example.com'
            );

            testUsers.add(testUser);
        }

        insert testUsers;

        List<Contact> testContacts = new List<Contact>();
        for (Account testAccount : testAccounts) {
            Integer currentIndex = testAccounts.indexOf(testAccount);
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                AccountId = testAccounts[currentIndex].Id,
                CurrencyIsoCode = 'USD',
                pse__Salesforce_User__c = testUsers[currentIndex].Id
            );

            testContacts.add(testContact);
        }

        insert testContacts;

        for (Account testAccount : testAccounts) {
            Integer currentIndex = testAccounts.indexOf(testAccount);
            testAccount.Account_Manager__c = testContacts[currentIndex].Id;
        }

        update testAccounts;
    }

    @isTest
    static void testAccountManagerSync() {
        List<Account> testAccounts = [
            SELECT Id, 
                OwnerId, 
                Account_Manager__r.pse__Salesforce_User__c 
            FROM Account 
            WHERE Name 
            LIKE 'Test Account%' 
            LIMIT 200
        ];
        List<Account> inSyncTestAccts = new List<Account>();
        List<Account> outOfSyncTestAccts = new List<Account>();

        for (Account testAccount : testAccounts) {
            if (testAccount.OwnerId == testAccount.Account_Manager__r.pse__Salesforce_User__c) {
                inSyncTestAccts.add(testAccount);
            } else {
                outOfSyncTestAccts.add(testAccount);
            }
        }

        Assert.areEqual(0, inSyncTestAccts.size(), 'Assert that no Accounts have an OwnerId that matches its Account Manager\'s SF User Id');
        Assert.areEqual(200, outOfSyncTestAccts.size(), 'Assert that all Accounts have an OwnerId that does not match its Account Manager\'s SF User Id');

        Test.startTest();
        GlobalGrowth_AccountManagerBatch batch = new GlobalGrowth_AccountManagerBatch(null);
        Database.executeBatch(batch);
        Test.stopTest();
        
        inSyncTestAccts.clear();
        outOfSyncTestAccts.clear();

        List<Account> finalTestAccounts = [
            SELECT Id, 
                OwnerId, 
                Account_Manager__r.pse__Salesforce_User__c 
            FROM Account 
            WHERE Name 
            LIKE 'Test Account%' 
            LIMIT 200
        ];

        for (Account testAccount : finalTestAccounts) {
            if (testAccount.OwnerId == testAccount.Account_Manager__r.pse__Salesforce_User__c) {
                inSyncTestAccts.add(testAccount);
            } else {
                outOfSyncTestAccts.add(testAccount);
            }
        }
        Assert.areEqual(0, outOfSyncTestAccts.size(), 'Assert that no Accounts have an OwnerId that does not match its Account Manager\'s SF User Id');
        Assert.areEqual(200, inSyncTestAccts.size(), 'Assert that all Accounts have an OwnerId that matches its Account Manager\'s SF User Id');
    }

    @isTest
    static void testAccountManagerSyncWithInactiveSFUsers() {
        List<User> testUsers = [SELECT Id, IsActive FROM User WHERE Name LIKE 'Test User%' LIMIT 100];

        for (User testUser : testUsers) {
            testUser.IsActive = false;
        }

        update testUsers;

        Test.startTest();
        GlobalGrowth_AccountManagerBatch batch = new GlobalGrowth_AccountManagerBatch(null);
        Database.executeBatch(batch);
        Test.stopTest();

        List<Account> finalTestAccounts = [SELECT Id, OwnerId FROM Account WHERE Name LIKE 'Test Account%' LIMIT 200];
        User sfAdmin = [SELECT Id FROM User WHERE Name = 'Salesforce Administrator'];
        List<Account> testAcctsWithInactiveSFUsers = new List<Account>();
        List<Account> testAcctsWithActiveSFUsers = new List<Account>();


        for (Account testAccount : finalTestAccounts) {
            if (testAccount.OwnerId == sfAdmin.Id) {
                testAcctsWithInactiveSFUsers.add(testAccount);
            } else {
                testAcctsWithActiveSFUsers.add(testAccount);
            }
        }
        Assert.areEqual(100, testAcctsWithInactiveSFUsers.size(), 'Assert that Accounts with inactive SF Users are assigned to the SF Admin User');
        Assert.areEqual(100, testAcctsWithActiveSFUsers.size(), 'Assert that Accounts with active SF Users are correctly assigned to their respective SF User');
    }

    @isTest
    static void testAccountManagerSyncWithOverride() {
        String testQuery = 'SELECT Id, OwnerId, Account_Manager__r.pse__Salesforce_User__c, Account_Manager__r.pse__Salesforce_User__r.IsActive FROM Account'
            + ' WHERE Asset_Count__c != null';

        Test.startTest();
        GlobalGrowth_AccountManagerBatch batch = new GlobalGrowth_AccountManagerBatch(testQuery);
        Database.executeBatch(batch);
        Test.stopTest();

        List<Account> finalTestAccounts = [SELECT Id, OwnerId, Account_Manager__r.pse__Salesforce_User__c FROM Account WHERE Name LIKE 'Test Account%' LIMIT 200];
        List<Account> inSyncTestAccts = new List<Account>();
        List<Account> outOfSyncTestAccts = new List<Account>();

        for (Account testAccount : finalTestAccounts) {
            if (testAccount.OwnerId == testAccount.Account_Manager__r.pse__Salesforce_User__c) {
                inSyncTestAccts.add(testAccount);
            } else {
                outOfSyncTestAccts.add(testAccount);
            }
        }

        Assert.areEqual(150, outOfSyncTestAccts.size(), 'Assert that the Accounts without \'Test Override\' have an OwnerId that does not match its Account Manager\'s SF User Id');
        Assert.areEqual(50, inSyncTestAccts.size(), 'Assert that the subset of Accounts with \'Test OVerride\' in the description have an OwnerId that matches its Account Manager\'s SF User Id');
    }
}