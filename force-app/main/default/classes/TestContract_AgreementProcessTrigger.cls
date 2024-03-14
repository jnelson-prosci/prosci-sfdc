@isTest
private class TestContract_AgreementProcessTrigger { 
    private static testMethod void Test_Contract_AgreementProcessTrigger () { 
        try{
            APXT_Redlining__Contract_Agreement__c fw = new APXT_Redlining__Contract_Agreement__c(); 
            insert fw; 
            System.assertNotEquals(null, fw.id); 
            update fw; 
            delete fw;
        } catch(Exception e){
            FSTR.COTestFactory.FillAllFields=true;
            APXT_Redlining__Contract_Agreement__c fw = (APXT_Redlining__Contract_Agreement__c)FSTR.COTestFactory.createSObject('APXT_Redlining__Contract_Agreement__c',true); 
            insert fw; 
            System.assertNotEquals(null, fw.id); 
            update fw; 
            delete fw;
        }
    } 
}