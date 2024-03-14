@isTest(SeeAllData=true)
public class RHX_TEST_Account {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Account LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Account()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}