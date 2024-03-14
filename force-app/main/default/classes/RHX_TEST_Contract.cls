@isTest(SeeAllData=true)
public class RHX_TEST_Contract {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Contract LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Contract()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}