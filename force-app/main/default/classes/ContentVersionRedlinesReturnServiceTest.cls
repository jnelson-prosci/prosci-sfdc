/**
 * This is a test class for ContentVersionRedlinesReturnService
 */
@isTest
private class ContentVersionRedlinesReturnServiceTest {
    //@TestSetup
   
    @TestSetup static void setupData() {
//Create a user to be used in the Legal_Negotiator__c feild on Contract Agreement records
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        // Create a User and set their attributes
        User u = new User();
        u.LastName = 'TestLastName';
        u.Alias = 'tst';
        u.Email = 'usertestemail@prosci.com';
        u.UserName = 'usertestemail@prosci.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        //u.CompanyName = 'Test Company';
        //u.PlatformCacheLevel = 'Three';*/
        
        insert u;

//Create Contract Agreement records
        List<APXT_Redlining__Contract_Agreement__c> listContractAgreements = new List<APXT_Redlining__Contract_Agreement__c>();
        listContractAgreements.add(new APXT_Redlining__Contract_Agreement__c(
            APXT_Redlining__Status__c = 'In Client Negotiation',
            APXT_Redlining__Type__c = 'Statement of Work',
            Legal_Negotiator__c = u.id
        ));
        listContractAgreements.add(new APXT_Redlining__Contract_Agreement__c(
            APXT_Redlining__Status__c = 'In Client Negotiation',
            APXT_Redlining__Type__c = 'Statement of Work',
            Legal_Negotiator__c = u.id
        ));
        listContractAgreements.add(new APXT_Redlining__Contract_Agreement__c(
            APXT_Redlining__Status__c = 'In Client Negotiation',
            APXT_Redlining__Type__c = 'Statement of Work',
            Legal_Negotiator__c = u.id
        ));
        

        insert listContractAgreements;
        List<Id> caIds = new List<Id>();
        for(APXT_Redlining__Contract_Agreement__c ca : listContractAgreements){
            caIds.add(ca.id);
        } 

        System.assert(caIds.size() > 0, 'caIds not populated');
        System.assert(caIds.size() == 3, 'caIds not three');
        
        String cdIdString1 = Id.valueOf(caIds[0]);
        String cdIdString2 = Id.valueOf(caIds[1]);
        String cdIdString3 = Id.valueOf(caIds[2]);
        System.assert(cdIdString1.left(3) == 'a2v', 'Contract Agreement 1 Id not equal to a2v');
        System.assert(cdIdString2.left(3) == 'a2v', 'Contract Agreement 2 Id not equal to a2v');
        System.assert(cdIdString3.left(3) == 'a2v', 'Contract Agreement 3 Id not equal to a2v');
 /*//Create ContentDocument records         
        List<ContentDocument> listContentDocuments = new List<ContentDocument>{
            new ContentDocument(
                Title = 'Document 1'
            ),
            new ContentDocument(
                Title = 'Document 1'
            ),
            new ContentDocument(
                Title = 'Document 1'
            )
        };
           
        insert listContentDocuments;*/

//Create ContentVersion records         
        List<ContentVersion> listContentVersions = new List<ContentVersion>{
            new ContentVersion(
                Title = 'Redlines Returned Document 1',
                PathOnClient = 'Redlines Document 1.pdf',
                VersionData = Blob.valueOf('Test Redlines Document 1')
            ),
            new ContentVersion(
                Title = 'Redlines Returned Document 2',
                PathOnClient = 'Redlines Document 2.pdf',
                VersionData = Blob.valueOf('Test Redlines Document 2')
            ),
            new ContentVersion(
                Title = 'Redlines Document 3',
                PathOnClient = 'Redlines Document 3.pdf',
                VersionData = Blob.valueOf('Test Redlines Document 3')
            )
        };
        insert listContentVersions;

/*// Create lookup from ContentVersion records to ContentDocument records
        for(Integer i = 0; i < 3; i++){
            listContentVersions[i].ContentDocumentId = listContentDocuments[i].Id;
        }*/

        //List<ContentDocumentLink> listContentDocumentLinks =  [SELECT Id, LinkedEntityId 
         //                                                       FROM ContentDocumentLink];
        List<ContentDocument> listContentDocuments = [SELECT Id FROM ContentDocument];   
        
        
        //System.assert(listContentDocumentLinks.size() > 0, 'ContentDocumentLinks created');
        System.assert(listContentDocuments.size() > 0, 'ContentDocuments not created');

        List<ContentVersion> listContentVersion = [SELECT ContentDocumentId FROM ContentVersion];
        Set<Id> cdIds = new Set<Id>();
        for(ContentVersion cv : listContentVersion){
            cdIds.add(cv.ContentDocumentId);
        }
        System.assert(cdIds.size() > 0, 'ContentDocumentId not populated');
        System.assert(cdIds.size() == 3, 'ContentDocumentId not three');
        
        List<ContentDocumentLink> listContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId  
                                                            FROM ContentDocumentLink WHERE ContentDocumentId In :cdIds ];
        
        System.assert(listContentDocumentLink.size() > 0, 'listContentDocumentLink not populated');
        System.assert(listContentDocumentLink.size() == 3, 'listContentDocumentLink not three');

        List<Id> cdlLinkedEntityIds = new List<Id>();
        for(ContentDocumentLink cdl : listContentDocumentLink){
            cdlLinkedEntityIds.add(cdl.LinkedEntityId);
        } 
        String cdlLinkedEntityIdString1 = Id.valueOf(cdlLinkedEntityIds[0]);
        String cdlLinkedEntityIdString2 = Id.valueOf(cdlLinkedEntityIds[1]);
        String cdlLinkedEntityIdString3 = Id.valueOf(cdlLinkedEntityIds[2]);
        System.assert(cdlLinkedEntityIdString1.left(3) == 'a2v', 'cdlLinkedEntityIdString1 not equal to a2v');
        System.assert(cdlLinkedEntityIdString2.left(3) == 'a2v', 'cdlLinkedEntityIdString2 not equal to a2v');
        System.assert(cdlLinkedEntityIdString3.left(3) == 'a2v', 'cdlLinkedEntityIdString3 not equal to a2v');
    }

    @isTest 
    static void testContentVersionRedlinesReturnedService(){
        List<ContentVersion> listContentVersions = [SELECT ContentDocumentId 
                                                    FROM ContentVersion];
        ContentVersionRedlinesReturnedService a = new ContentVersionRedlinesReturnedService();

        Set<Id> cdIds = new Set<Id>();
        for(ContentVersion cv : listContentVersions){
            cdIds.add(cv.ContentDocumentId);
        }
        
        List<ContentDocumentLink> listContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId  
                                                            FROM ContentDocumentLink 
                                                            WHERE ContentDocumentId In :cdIds ];
        
        String linkedEntityIdString = Id.valueOf(listContentDocumentLink[0].LinkedEntityID);
            
    
        //System.assert(LinkedEntityIdString.left(3) == 'a2v', 'LinkedEntityIdString not equal to a2v');
        System.assert(!String.isEmpty(LinkedEntityIdString), 'LinkedEntityIdString is empty');
        // Call the service method
			Test.startTest();
			a.execute(listContentVersions);
			Test.stopTest();

			// Verify the ContentVersion record is updated
			//ContentVersion updatedCv = [SELECT Id, Redlines_Returned__c FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
			//System.assertEquals(true, updatedCv.Redlines_Returned__c);
    }

}
    /*
        List<ContentVersion> cvList = new List<ContentVersion>();
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        List<APXT_Redlining__Contract_Agreement__c> caList = new List<APXT_Redlining__Contract_Agreement__c>();
        
        for(Integer i = 0; i < 5; i++){
            APXT_Redlining__Contract_Agreement__c testCA = new APXT_Redlining__Contract_Agreement__c();
            caList.add(testCA);
        }
        insert caList;
        
        for(Integer i = 0; i < 4; i++){
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.FirstPublishLocationId = caList[i].Id;
            cvList.add(cv);
        }
        insert cvList;
        
        for(Integer i = 0; i < 4; i++){
            ContentDocumentLink cd = new ContentDocumentLink();
            cd.LinkedEntityId = caList[i].Id;
            cd.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvList[i].Id LIMIT 1].ContentDocumentId;
            cd.ShareType = 'I';
            cd.Visibility = 'AllUsers'; 
            cdList.add(cd);
        }
        insert cdList;







    }

    @isTest
    static void testGetRedlines() {
        List<ContentVersion> redlines = [SELECT Id, Title, VersionData FROM ContentVersion];

        Test.startTest();
        List<ContentVersion> returnedRedlines = ContentVersionRedlinesReturnedService.getRedlines();
        Test.stopTest();

        System.assertEquals(redlines.size(), returnedRedlines.size(), 'The returned list size should match the ContentVersion records size');
    }
}


			// Call the service method
			Test.startTest();
			ContentVersionRedlinesReturnedService.getContentVersionRedlinesReturnedData(new List<Id>{ cv.Id });
			Test.stopTest();

			// Verify the ContentVersion record is updated
			ContentVersion updatedCv = [SELECT Id, Redlines_Returned__c FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
			System.assertEquals(true, updatedCv.Redlines_Returned__c);
		}


@isTest
    static void executeTest(){
        user u = [SELECT Id, IsActive FROM User WHERE email = {EMAIL_PLACEHOLDER}' WITH USER_MODE LIMIT 1];
        List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WITH USER_MODE];

        Test.startTest();
        System.runAs(u){
            ContentVersionRedlinesReturnedService contentVersionRedlinesService = new ContentVersionRedlinesReturnedService();
            contentVersionRedlinesService.execute(contentVersionList);
        }
        Test.stopTest();

        //One Contract Agreement record should have been updated
        List<Contract_Agreement__c> updatedContractAgreement = [SELECT Id, Redlines_Returned__c FROM Contract_Agreement__c WHERE Redlines_Returned__c = true WITH USER_MODE];
        System.assertEquals(1, updatedContractAgreement.size(), '1 Contract Agreement record should have been updated');
        //One email should have been sent
        List<EmailMessage> emailMessageList = [SELECT Id FROM EmailMessage WITH USER_MODE];
        System.assertEquals(1, emailMessageList.size(), '1 email should have been sent');
    }



@isTest
    static void updateContractAgreementTest(){
        user u = [SELECT Id, IsActive FROM User WHERE email = {EMAIL_PLACEHOLDER}' WITH USER_MODE LIMIT 1];
        system.runAs(u){
            List<ContentVersion> cvList = new List<ContentVersion>();
            List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
            List<APXT_Redlining__Contract_Agreement__c> caList = new List<APXT_Redlining__Contract_Agreement__c>();
            
            for(Integer i = 0; i < 5; i++){
                APXT_Redlining__Contract_Agreement__c testCA = new APXT_Redlining__Contract_Agreement__c();
                caList.add(testCA);
            }
            insert caList;
            
            for(Integer i = 0; i < 4; i++){
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Test Document';
                cv.PathOnClient = 'TestDocument.pdf';
                cv.VersionData = Blob.valueOf('Test Content');
                cv.FirstPublishLocationId = caList[i].Id;
                cvList.add(cv);
            }
            insert cvList;
            
            for(Integer i = 0; i < 4; i++){
                ContentDocumentLink cd = new ContentDocumentLink();
                cd.LinkedEntityId = caList[i].Id;
                cd.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvList[i].Id LIMIT 1].ContentDocumentId;
                cd.ShareType = 'I';
                cd.Visibility = 'AllUsers'; 
                cdList.add(cd);
            }
            insert cdList;
            
            test.startTest();
                ContentVersionRedlinesReturnedService.updateContractAgreement(cdList);
            test.stopTest();
        }
    }
@isTest
    static void sendEmailTest(){
        user u = [SELECT Id, IsActive FROM User WHERE email = {EMAIL_PLACEHOLDER}' WITH USER_MODE LIMIT 1];
        System.runAs(u){
            List<ContentDocumentLink> cdlList = [SELECT Id from ContentDocumentLink WITH USER_MODE LIMIT 1];
            Test.startTest();
            ContentVersionRedlinesReturnedService.sendEmailUsingEmailTemplateRedlinesReturned(cdlList);
            Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();        
            System.assertEquals(1, invocations, 'One email should have been sent');
        }
    }
@isTest
    static void sendEmailTest(){
        user u = [SELECT Id, IsActive FROM User WHERE email = {EMAIL_PLACEHOLDER}' WITH USER_MODE LIMIT 1];
        System.runAs(u){
            List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM APXT_Redlining__Contract_Agreement__c)];
            Test.startTest();
            ContentVersionRedlinesReturnedService.sendEmailUsingEmailTemplateRedlinesReturned(cdlList);
            Test.stopTest();
        }
    }
@isTest
    static void executeTest(){
        user u = [SELECT Id, IsActive FROM User WHERE email = {EMAIL_PLACEHOLDER}' WITH USER_MODE LIMIT 1];
        System.runAs(u){
            Test.startTest();
            ContentVersionRedlinesReturnedService service = new ContentVersionRedlinesReturnedService();
            List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion WITH USER_MODE];
            service.execute(cvList);
            Test.stopTest();
        }
        
    }
}
*/