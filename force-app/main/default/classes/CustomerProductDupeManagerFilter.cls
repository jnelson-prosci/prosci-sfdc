public with sharing class CustomerProductDupeManagerFilter {

    public List<Customer_Product__c> filterRecords(List<Customer_Product__c> lstCustProds){
        List<Customer_Product__c> lstFilteredRecords = new List<Customer_Product__c>();
        
        for(Customer_Product__c custProd : lstCustProds){
            if(custProd.Active__c && custProd.Product__c != null && custProd.Portal_Access__c != null){
                lstFilteredRecords.add(custProd);
            }
        }
        return lstFilteredRecords;
    }
}