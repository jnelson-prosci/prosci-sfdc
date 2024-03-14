@isTest(SeeAllData=true)
public class RHX_TEST_Practitioner_Accelerator {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Practitioner_Accelerator__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Practitioner_Accelerator__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}