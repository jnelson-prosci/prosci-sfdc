/**
 * @author CloudMasonry
 * @date 2024
 * @group Redlines Returned Service
 * @description Sends an email alert and updates related Contract Agreement record when new ContentVersion record is created 
 */

 public with sharing class ContentVersionRedlinesReturnedService {
    @testVisible

    public void execute(List<ContentVersion> listContentVersions){    
    // Get ContentDocumentId's for the filtered ContentVersion records from the trigger handler
        Set<Id> setContentDocumentIds = new Set<Id>();

            for(ContentVersion cv : listContentVersions){
                setContentDocumentIds.add(cv.ContentDocumentId);
            }

    // Get the ContentDocumentLink records that are related to the ContentVersion records using ContentDocumentId
        List<ContentDocumentLink> listContentDocumentLinks = [
                SELECT Id, LinkedEntityID 
                FROM ContentDocumentLink 
                WHERE ContentDocumentId IN :setContentDocumentIds];         

    // Get a filtered list of ContentDocumentLink records where LinkedEntityID prefix is a2v
        List<ContentDocumentLink> filteredContentDocumentLinks =  new  List<ContentDocumentLink>();
            
        for(ContentDocumentLink contentdoclink : listContentDocumentLinks){

            String linkedEntityIdString = Id.valueOf(contentdoclink.LinkedEntityID);
            
            if(!String.isBlank(linkedEntityIdString) && LinkedEntityIdString.left(3) == 'a2v'){
                filteredContentDocumentLinks.add(contentdoclink);
            }
        }
    // Call method to update Contract Agreement records     
        updateContractAgreement(filteredContentDocumentLinks);
    
    // Call method to send email        
        sendEmailUsingEmailTemplateRedlinesReturned(filteredContentDocumentLinks);

    }

    
    private static void updateContractAgreement(List<ContentDocumentLink> listContentDocumentLinks ){
    // Get ContractAgreement Id's for the filtered ContentDocumentLink records from the Service execute method
        Set<Id> setContractAgreementIds = new Set<Id>();

        for(ContentDocumentLink cdl : listContentDocumentLinks){
                setContractAgreementIds.add(cdl.LinkedEntityId);
        }

    // Get the ContractAgreement records to be updated
        List<APXT_Redlining__Contract_Agreement__c> listContractAgreement = [
                SELECT Id, Date_Time_Returned_from_Client_Review__c, APXT_Redlining__Status__c
                FROM APXT_Redlining__Contract_Agreement__c 
                WHERE Id IN :setContractAgreementIds];  

    // Update ContractAgreement records                
        List<APXT_Redlining__Contract_Agreement__c> listContractAgreementToUpdate = new List<APXT_Redlining__Contract_Agreement__c>();
            for(APXT_Redlining__Contract_Agreement__c ca : listContractAgreement){
                ca.Date_Time_Returned_from_Client_Review__c = system.now();
                ca.APXT_Redlining__Status__c = 'Redlines Returned';

                listContractAgreementToUpdate.add(ca);
            }
        
        update listContractAgreementToUpdate;
        }


    private static void sendEmailUsingEmailTemplateRedlinesReturned(List<ContentDocumentLink> listContentDocumentLinks){
    // Get the Redlines Returned email template
        EmailTemplate et = [
            SELECT Id,Subject, Body 
            FROM EmailTemplate 
            WHERE DeveloperName ='Redlines_Returned'];
            
    //Get Contract Agreement Id's from ContentDocumentLink records
        Set<Id> cdlIds = new Set<Id>();
        for(ContentDocumentLink cdl : listContentDocumentLinks){
            cdlIds.add(cdl.LinkedEntityId);
        }

    //Get Redlining Contract Agreements records
        List<APXT_Redlining__Contract_Agreement__c> listCAs =  [
            SELECT Id, Legal_Negotiator__c
            FROM APXT_Redlining__Contract_Agreement__c
            WHERE Id IN :cdlIds];
    
    //Create map of Contract Agreement Id's to Contract Agreement records
        Map<Id, APXT_Redlining__Contract_Agreement__c> mapCAIdtoContractArgreement  = new Map<Id, APXT_Redlining__Contract_Agreement__c>(); 
        for(APXT_Redlining__Contract_Agreement__c ca : listCAs){
            mapCAIdtoContractArgreement.put(ca.Id, ca);
        }

    //Send email to Legal_Negotiator on Contract Agreement
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

        for(ContentDocumentLink cdl : listContentDocumentLinks){

            String templateId = et.Id;
            String userId = mapCAIdtoContractArgreement.get(cdl.LinkedEntityId).Legal_Negotiator__c;
            String whatId = cdl.LinkedEntityId;
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, userId, whatId);
            
            String emailSubject = email.getSubject();
            String emailTextBody = email.getPlainTextBody();
            
            email.setTargetObjectId(userId);
            email.setSubject(emailSubject);
            email.setPlainTextBody(emailTextBody);
            email.saveAsActivity = false;

            allmsg.add(email);
           
        }  
        
        try {
            if(!Test.isRunningTest()) {
                Messaging.SendEmailResult[] r = Messaging.sendEmail(allmsg,false);
            }
            return;

            } catch (Exception e) {
                System.debug(e.getMessage());
                }
        
            }
    
    }