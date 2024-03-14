@isTest(SeeAllData=true)
public class RHX_TEST_Training_Event {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Training_Event__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Training_Event__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}