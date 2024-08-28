@isTest
class SandboxPostRefreshScriptTest {

    @testSetup
    static void setupData() {
        // Insert logic here to create records of the objects that the class you’re testing manipulates.
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 199; i++) {
            Account testAccount = new Account(
                Name = 'Test Account ' + i,
                Industry__c = 'Consulting',
                CurrencyIsoCode = 'USD',
                account_manager_email__c = 'test@prosci.com',
                Company_email_domain__c = i + ' prosci.com', // Unique
                GAN_Lead_Notification_Email__c	= 'test@prosci.com'
            );

            testAccounts.add(testAccount);
        }

        insert testAccounts;

        Profile testSysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        String userSuffix = org.IsSandbox ? DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() : 'prosciprod';
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < 199; i++) {
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
                UserName = 'userTest' + i + '@example.com' + userSuffix
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
                pse__Salesforce_User__c = testUsers[currentIndex].Id,
                Email = 'test'+ currentIndex +'@prosci.com',
                Leader_Email__c = 'test'+ currentIndex +'@prosci.com',
                Reports_To_Email__c = 'test'+ currentIndex +'@prosci.com',
                Secondary_Email__c = 'test'+ currentIndex +'@prosci.com',
                P_Secondary_Email__c = 'test'+ currentIndex +'@prosci.com'
            );

            testContacts.add(testContact);
        }

        insert testContacts;

        for (Account testAccount : testAccounts) {
            Integer currentIndex = testAccounts.indexOf(testAccount);
            testAccount.Account_Manager__c = testContacts[currentIndex].Id;
        }

        update testAccounts;

        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 199; i++) {
            Lead testLead = new Lead(
                FirstName = 'Test',
                LastName = 'Lead',
                Company = 'Prosci',
                Email = 'test'+ i +'@prosci.com',
                Email_Address__c = 'test'+ i +'@prosci.com',
                Email_Address_2__c = 'test'+ i +'@prosci.com',
                Email_Address_3__c = 'test'+ i +'@prosci.com'
            );

            testLeads.add(testLead);
        }

        insert testLeads;

        List<Training_Event__c> testTrainingEvents = new List<Training_Event__c>();
        for (Integer i = 0; i < 199; i++) {
            Training_Event__c testTrainingEvent = new Training_Event__c(
                Name = 'Test Training Event ' + i
            );

            testTrainingEvents.add(testTrainingEvent);
        }

        insert testTrainingEvents;

        // Cannot bulk add since CPU time limit from flow “Create an Opportunity from an ATC (US Enterprise & Public)”
        Associated_Training_Contacts__c testTrainingContact = new Associated_Training_Contacts__c(
            Contact__c = testContacts[0].Id, // sets the email text formula fields ATC_Email__c and Email_Feedback__c
            Contact_Email_for_GetFeedback__c = 'test@prosci.com',
            Survey_Resend_Email_for_GetFeedback__c = 'test@prosci.com',
            Training_Event__c = testTrainingEvents[0].Id
        );

        insert testTrainingContact;

        // Cannot bulk add since CPU time limit from flow “Contact from Portal Access Creation”
        Portal_Access__c testPortalAccess = new Portal_Access__c(
            First_Name__c = 'test',
            Last_Name__c = 'portal access',
            customer_type_id__c = '1',
            Email__c = 'test@prosci.com',
            Unique_Email__c ='testunique@prosci.com'
        );

        insert testPortalAccess;
    }

    @isTest
    static void testMySandboxPostRefresh() {
        Test.startTest();

        //Execute test script with RunAsAutoProcUser set to true
        Test.testSandboxPostCopyScript(
            new SandboxPostRefreshScript(), 
            UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(),
            UserInfo.getOrganizationName(),
            true
        );

        Test.stopTest();

        // Insert assert statements here to check that the records you created above have invalidated email addresses
        List<Account> testAccounts = [
            SELECT
                account_manager_email__c, 
                Company_email_domain__c, 
                GAN_Lead_Notification_Email__c
            FROM Account
        ];

        Boolean accountAccountManagerEmailAllInvalid = true;
        Boolean accountCompanyEmailDomainAllInvalid = true;
        Boolean accountGANLeadNotificationEmailAllInvalid = true;

        
        for (Account testAccount : testAccounts) {
            if (!testAccount.account_manager_email__c.endsWith('.invalid')) {
                accountAccountManagerEmailAllInvalid = false;
                return;
            }
            if (!testAccount.Company_email_domain__c.endsWith('.invalid')) {
                accountCompanyEmailDomainAllInvalid = false;
                return;
            }
            if (!testAccount.GAN_Lead_Notification_Email__c.endsWith('.invalid')) {
                accountGANLeadNotificationEmailAllInvalid = false;
                return;
            }
        }

        Assert.isTrue(accountAccountManagerEmailAllInvalid,'Account.account_manager_email__c all invalidated');
        Assert.isTrue(accountCompanyEmailDomainAllInvalid,'Account.Company_email_domain__c all invalidated');
        Assert.isTrue(accountGANLeadNotificationEmailAllInvalid,'Account.GAN_Lead_Notification_Email__c all invalidated');

        List<Contact> testContacts = [
            SELECT
                Email,
                Leader_Email__c,
                Reports_To_Email__c,
                Secondary_Email__c,
                P_Secondary_Email__c
            FROM Contact
        ];

        Boolean contactEmailAllInvalid = true;
        Boolean contactLeaderEmailAllInvalid = true;
        Boolean contactReportsToEmailAllInvalid = true;
        Boolean contactSecondaryEmailAllInvalid = true;
        Boolean contactPSecondaryEmailAllInvalid = true;

        for (Contact testContact : testContacts) {
            if (String.isNotBlank(testContact.Email) && !testContact?.Email?.endsWith('.invalid')) {
                contactEmailAllInvalid = false;
                return;
            }
            if (String.isNotBlank(testContact.Leader_Email__c) && !testContact.Leader_Email__c.endsWith('.invalid')) {
                contactLeaderEmailAllInvalid = false;
                return;
            }
            if (String.isNotBlank(testContact.Reports_To_Email__c) && !testContact.Reports_To_Email__c.endsWith('.invalid')) {
                contactReportsToEmailAllInvalid = false;
                return;
            }
            if (String.isNotBlank(testContact.Secondary_Email__c) && !testContact.Secondary_Email__c.endsWith('.invalid')) {
                contactSecondaryEmailAllInvalid = false;
                return;
            }
            if (String.isNotBlank(testContact.P_Secondary_Email__c) && !testContact.P_Secondary_Email__c.endsWith('.invalid')) {
                contactPSecondaryEmailAllInvalid = false;
                return;
            }
        }

        Assert.isTrue(contactEmailAllInvalid,'Contact.Email all invalidated');
        Assert.isTrue(contactLeaderEmailAllInvalid,'Contact.Leader_Email__c all invalidated');
        Assert.isTrue(contactReportsToEmailAllInvalid,'Contact.Reports_To_Email__c all invalidated');
        Assert.isTrue(contactSecondaryEmailAllInvalid,'Contact.Secondary_Email__c all invalidated');
        Assert.isTrue(contactPSecondaryEmailAllInvalid,'Contact.P_Secondary_Email__c all invalidated');

        List<Lead> testLeads = [
            SELECT
                Email,
                Email_Address__c,
                Email_Address_2__c,
                Email_Address_3__c
            FROM Lead
        ];

        Boolean leadEmailAllInvalid = true;
        Boolean leadEmailAddressAllInvalid = true;
        Boolean leadEmailAddress2AllInvalid = true;
        Boolean leadEmailAddress3AllInvalid = true;

        for (Lead testLead: testLeads) {
            if (!testLead.Email.endsWith('.invalid')) {
                leadEmailAllInvalid = false;
                return;
            }
            if (!testLead.Email_Address__c.endsWith('.invalid')) {
                leadEmailAddressAllInvalid = false;
                return;
            }
            if (!testLead.Email_Address_2__c.endsWith('.invalid')) {
                leadEmailAddress2AllInvalid = false;
                return;
            }
            if (!testLead.Email_Address_3__c.endsWith('.invalid')) {
                leadEmailAddress3AllInvalid = false;
                return;
            }
        }

        Assert.isTrue(leadEmailAllInvalid,'Lead.Email all invalidated');
        Assert.isTrue(leadEmailAddressAllInvalid,'Lead.Email_Address__c all invalidated');
        Assert.isTrue(leadEmailAddress2AllInvalid,'Lead.Email_Address_2__c all invalidated');
        Assert.isTrue(leadEmailAddress3AllInvalid,'Lead.Email_Address_3__c all invalidated');

        List<Associated_Training_Contacts__c> testTrainingContacts = [
            SELECT
                Contact_Email_for_GetFeedback__c,
                Survey_Resend_Email_for_GetFeedback__c
            FROM Associated_Training_Contacts__c
        ];

        Boolean trainingContactContactEmailAllInvalid = true;
        Boolean trainingContactSurveryResendEmailAllInvalid = true;
        
        for (Associated_Training_Contacts__c testTrainingContact: testTrainingContacts) {
            if (!testTrainingContact.Contact_Email_for_GetFeedback__c.endsWith('.invalid')) {
                trainingContactContactEmailAllInvalid = false;
                return;
            }
            if (!testTrainingContact.Survey_Resend_Email_for_GetFeedback__c.endsWith('.invalid')) {
                trainingContactSurveryResendEmailAllInvalid = false;
                return;
            }
        }

        Assert.isTrue(trainingContactContactEmailAllInvalid,'Associated_Training_Contacts__c.Contact_Email_for_GetFeedback__c all invalidated');
        Assert.isTrue(trainingContactSurveryResendEmailAllInvalid,'Associated_Training_Contacts__c.Survey_Resend_Email_for_GetFeedback__c all invalidated');

        List<Portal_Access__c> testPortalAccesses = [
            SELECT 
                Email__c,
                Unique_Email__c
            FROM Portal_Access__c
        ];

        Boolean portalAccessEmailAllInvalid   = true;
        Boolean portalAccessUniqueEmailAllInvalid = true;

        for (Portal_Access__c testPortalAccess: testPortalAccesses) {
            if (!testPortalAccess.Email__c.endsWith('.invalid')) {
                portalAccessEmailAllInvalid = false;
                return;
            }
            if (!testPortalAccess.Unique_Email__c.endsWith('.invalid')) {
                portalAccessUniqueEmailAllInvalid = false;
                return;
            }
        }

        Assert.isTrue(portalAccessEmailAllInvalid,'Portal_Access__c.Email__c all invalidated');
        Assert.isTrue(portalAccessUniqueEmailAllInvalid,'Portal_Access__c.Unique_Email__c all invalidated');
    }

    @isTest
    static void testMySandboxPostRefreshFailureCase() {
        Contact testContactFailure = [
            SELECT
                Email,
                Leader_Email__c,
                Reports_To_Email__c,
                Secondary_Email__c,
                P_Secondary_Email__c
            FROM Contact
            LIMIT 1
        ];

        testContactFailure.P_Secondary_Email__c = '123456789012345678901234567890123456789@prosci.com'; // max out the 50 char length

        update testContactFailure;

        Test.startTest();

        //Execute test script with RunAsAutoProcUser set to true
        Test.testSandboxPostCopyScript(
            new SandboxPostRefreshScript(), 
            UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(),
            UserInfo.getOrganizationName(),
            true
        );

        Test.stopTest();

        List<Case> failureCases = [
            SELECT Id
            FROM Case
            WHERE Subject like '%Contact Invalidate Email Post Refresh Failure'
        ];

        Assert.areEqual(1,failureCases.size(), 'One Contact Sandbox Post Refresh Failure should exist');
    }
}
