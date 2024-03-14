@isTest(SeeAllData=true)
public class RHX_TEST_Associated_Training_Contacts {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Associated_Training_Contacts__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Associated_Training_Contacts__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}