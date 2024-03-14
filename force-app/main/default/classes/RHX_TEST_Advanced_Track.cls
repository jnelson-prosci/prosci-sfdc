@isTest(SeeAllData=true)
public class RHX_TEST_Advanced_Track {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Advanced_Track__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Advanced_Track__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}