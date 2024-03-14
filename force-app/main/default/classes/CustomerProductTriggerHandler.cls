public with sharing class CustomerProductTriggerHandler extends TriggerHandler{

    private List<Customer_Product__c> lstNewRecords;
    private Map<Id, Customer_Product__c> mapOldRecords;

    @testVisible
    public static Boolean byPass = false;
    
    public CustomerProductTriggerHandler(List<Customer_Product__c> lstNewRecords, Map<Id, Customer_Product__c> mapOldRecords) {
        this.lstNewRecords = lstNewRecords;
        this.mapOldRecords = mapOldRecords;
    }

    protected override void afterInsert() {
        if (byPass) { return; }
        new CustomerProductDupeManagerService().execute(new CustomerProductDupeManagerFilter().filterRecords(lstNewRecords));
    }
   
}