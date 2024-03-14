@isTest
private class CustomerProductDupeManagerFilterTest {
    
    private static final Integer RECORD_COUNT = 200;
    
    @isTest static void filterRecords_matchesCriteria_returnAll(){
        List<Customer_Product__c> lstCustProds = new List<Customer_Product__c>();
        for(Integer i=0; i<RECORD_COUNT;i++){
            lstCustProds.add(new Customer_Product__c(
            	Id = new TestUtils().generateDummyId(Customer_Product__c.SObjectType)
            	, Product__c = new TestUtils().generateDummyId(Product2.SObjectType)
            	, Portal_Access__c = new TestUtils().generateDummyId(Portal_Access__c.SObjectType)
            	, Active__c = true));
        }
        
        Test.startTest();
        
        List<Customer_Product__c> rLstCustProds = new CustomerProductDupeManagerFilter().filterRecords(lstCustProds);
        
        Test.stopTest();
        
        System.assertEquals(RECORD_COUNT, rLstCustProds.size());
    }
    
    @isTest static void filterRecords_inactive_returnNone(){
        List<Customer_Product__c> lstCustProds = new List<Customer_Product__c>();
        for(Integer i=0; i<RECORD_COUNT;i++){
            lstCustProds.add(new Customer_Product__c(
            	Id = new TestUtils().generateDummyId(Customer_Product__c.SObjectType)
            	, Product__c = new TestUtils().generateDummyId(Product2.SObjectType)
            	, Portal_Access__c = new TestUtils().generateDummyId(Portal_Access__c.SObjectType)
            	, Active__c = false));
        }
        
        Test.startTest();
        
        List<Customer_Product__c> rLstCustProds = new CustomerProductDupeManagerFilter().filterRecords(lstCustProds);
        
        Test.stopTest();
        
        System.assertEquals(0, rLstCustProds.size());
    }
}