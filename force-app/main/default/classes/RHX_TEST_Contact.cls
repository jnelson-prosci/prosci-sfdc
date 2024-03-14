@isTest(SeeAllData=true)
public class RHX_TEST_Contact {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Contact LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Contact()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}