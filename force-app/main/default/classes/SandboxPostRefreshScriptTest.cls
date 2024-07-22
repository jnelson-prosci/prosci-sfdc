@isTest
class SandboxPostRefreshScriptTest {

    @isTest
    static void testMySandboxPostRefresh() {
        // Insert logic here to create records of the objects that the class you’re testing manipulates.
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry__c = 'Consulting',
            CurrencyIsoCode = 'USD',
            account_manager_email__c = 'test@prosci.com',
            Company_email_domain__c = 'prosci.com',
            GAN_Lead_Notification_Email__c	= 'test@prosci.com'
        );
        insert testAccount;

        Profile testSysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User testUser = new User(
            CurrencyIsoCode = 'USD',
            IsActive = true,
            Alias = 'tU',
            Email = 'testUser@prosci.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Test',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testSysAdminId.Id,
            TimeZonesIdKey = 'America/Denver',
            UserName = 'userTest@prosci.com'
        );

        insert testUser;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            CurrencyIsoCode = 'USD',
            pse__Salesforce_User__c = testUser.Id,
            Email = 'test@prosci.com',
            Leader_Email__c = 'test@prosci.com',
            Reports_To_Email__c = 'test@prosci.com',
            Secondary_Email__c = 'test@prosci.com',
            P_Secondary_Email__c = 'test@prosci.com'
        );

        insert testContact;

        testAccount.Account_Manager__c = testContact.Id;
        update testAccount;

        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Prosci',
            Email = 'test@prosci.com',
            Email_Address__c = 'test@prosci.com',
            Email_Address_2__c = 'test@prosci.com',
            Email_Address_3__c = 'test@prosci.com'
        );

        insert testLead;

        Training_Event__c testTrainingEvent = new Training_Event__c(
            Name = 'Test Event'
        );

        insert testTrainingEvent;

        Associated_Training_Contacts__c testTrainingContact = new Associated_Training_Contacts__c(
            Contact__c = testContact.Id, // sets the email text formula fields ATC_Email__c and Email_Feedback__c
            Contact_Email_for_GetFeedback__c = 'test@prosci.com',
            Survey_Resend_Email_for_GetFeedback__c = 'test@prosci.com',
            Training_Event__c = testTrainingEvent.Id
        );

        insert testTrainingContact;

        Portal_Access__c testPortalAccess = new Portal_Access__c(
            First_Name__c = 'test',
            Last_Name__c = 'portal access',
            customer_type_id__c = '1',
            Email__c ='test@prosci.com',
            Unique_Email__c ='testunique@prosci.com'
        );

        insert testPortalAccess;

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
        testAccount = [
            SELECT
                account_manager_email__c, 
                Company_email_domain__c, 
                GAN_Lead_Notification_Email__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        Assert.isTrue(testAccount.account_manager_email__c.endsWith('.invalid'),'Account.account_manager_email__c is invalidated');
        Assert.isTrue(testAccount.Company_email_domain__c.endsWith('.invalid'),'Account.Company_email_domain__c is invalidated');
        Assert.isTrue(testAccount.GAN_Lead_Notification_Email__c.endsWith('.invalid'),'Account.GAN_Lead_Notification_Email__c is invalidated');

        testContact = [
            SELECT
                Email,
                Leader_Email__c,
                Reports_To_Email__c,
                Secondary_Email__c,
                P_Secondary_Email__c
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        Assert.isTrue(testContact.Email.endsWith('.invalid'),'Contact.Email is invalidated');
        Assert.isTrue(testContact.Leader_Email__c.endsWith('.invalid'),'Contact.Leader_Email__c is invalidated');
        Assert.isTrue(testContact.Reports_To_Email__c.endsWith('.invalid'),'Contact.Reports_To_Email__c is invalidated');
        Assert.isTrue(testContact.Secondary_Email__c.endsWith('.invalid'),'Contact.Secondary_Email__c is invalidated');
        Assert.isTrue(testContact.P_Secondary_Email__c.endsWith('.invalid'),'Contact.P_Secondary_Email__c is invalidated');

        testLead = [
            SELECT
                Email,
                Email_Address__c,
                Email_Address_2__c,
                Email_Address_3__c
            FROM Lead
            WHERE Id = :testLead.Id
        ];

        Assert.isTrue(testLead.Email.endsWith('.invalid'),'Lead.Email is invalidated');
        Assert.isTrue(testLead.Email_Address__c.endsWith('.invalid'),'Lead.Email_Address__c is invalidated');
        Assert.isTrue(testLead.Email_Address_2__c.endsWith('.invalid'),'Lead.Email_Address_2__c is invalidated');
        Assert.isTrue(testLead.Email_Address_3__c.endsWith('.invalid'),'Lead.Email_Address_3__c is invalidated');

        testTrainingContact = [
            SELECT
                Contact_Email_for_GetFeedback__c,
                Survey_Resend_Email_for_GetFeedback__c
            FROM Associated_Training_Contacts__c
            WHERE Id = :testTrainingContact.Id
        ];

        Assert.isTrue(testTrainingContact.Contact_Email_for_GetFeedback__c.endsWith('.invalid'),'Associated_Training_Contacts__c.Contact_Email_for_GetFeedback__c is invalidated');
        Assert.isTrue(testTrainingContact.Survey_Resend_Email_for_GetFeedback__c.endsWith('.invalid'),'Associated_Training_Contacts__c.Survey_Resend_Email_for_GetFeedback__c is invalidated');

        testPortalAccess = [
            SELECT 
                Email__c,
                Unique_Email__c
            FROM Portal_Access__c
            WHERE Id = :testPortalAccess.Id
        ];

        Assert.isTrue(testPortalAccess.Email__c.endsWith('.invalid'),'Portal_Access__c.Email__c is invalidated');
        Assert.isTrue(testPortalAccess.Unique_Email__c.endsWith('.invalid'),'Portal_Access__c.Unique_Email__c is invalidated');
    }
}
