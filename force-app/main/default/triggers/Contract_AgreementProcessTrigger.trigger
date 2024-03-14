trigger Contract_AgreementProcessTrigger on APXT_Redlining__Contract_Agreement__c (after insert, before insert, before update, after update, before delete){
    FSTR.COTriggerHandler.handleProcessObjectTrigger();
}