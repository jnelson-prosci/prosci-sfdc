public with sharing class CustomerProductDupeManagerService {

    @testVisible
    private static Date DEFAULTEXPIRATIONDATE = Date.today().addDays(365);

    public void execute(List<Customer_Product__c> listCustomerProducts){

        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setPortalAccessId = new Set<Id>();

        for(Customer_Product__c customerProducts : listCustomerProducts){
            setProductIds.add(customerProducts.Product__c);
            setPortalAccessId.add(customerProducts.Portal_Access__c);
        }

        List<Customer_Product__c> listExistCustomerProducts = [
            SELECT Id, Active__c, Product__c, Portal_Access__c, expiration_date__c, CreatedDate
            FROM Customer_Product__c
            WHERE Product__c IN :setProductIds
            AND Portal_Access__c IN :setPortalAccessId
            AND Active__c = true
            ORDER BY CreatedDate DESC, Id DESC 
        ];

        Map<String, List<Customer_Product__c>> mapDupeCustomerProducts = new Map<String, List<Customer_Product__c>>();

        // Build map of duplicates
        for(Customer_Product__c customerProduct : listExistCustomerProducts){

            String strDupeId = buildDuplicateId(customerProduct);

            List<Customer_Product__c> listDupeCustProds = mapDupeCustomerProducts.get(strDupeId);

            if(listDupeCustProds == null){
                listDupeCustProds = new List<Customer_Product__c>();
            }

            listDupeCustProds.add(customerProduct);
            mapDupeCustomerProducts.put(strDupeId, listDupeCustProds);

        }

        // Collect customer products we need to update 
        List<Customer_Product__c> listCustomerProductsToUpdate = new List<Customer_Product__c>();


        // Iterate through the map list
        for(List<Customer_Product__c> dupeList : mapDupeCustomerProducts.values()){
            if(dupeList.size() == 1){
                continue;
            }
            Customer_Product__c newCustomerProduct;
        
            for(Customer_Product__c customerProduct : dupeList){
                if(newCustomerProduct == null){
                    newCustomerProduct = customerProduct;
                    if(newCustomerProduct.expiration_date__c == null){
                        newCustomerProduct.expiration_date__c = DEFAULTEXPIRATIONDATE;
                        listCustomerProductsToUpdate.add(newCustomerProduct);
                    }
                    continue;
                }
                customerProduct.Active__c = false;

                if(customerProduct.expiration_date__c > newCustomerProduct.expiration_date__c){
                    newCustomerProduct.expiration_date__c = customerProduct.expiration_date__c;
                    listCustomerProductsToUpdate.add(newCustomerProduct);
                }
                listCustomerProductsToUpdate.add(customerProduct);

            }
        }

        if(!listCustomerProductsToUpdate.isEmpty()){
            
            Map<Id, Customer_Product__c> mapCustomerProductsToUpdate = new Map<Id, Customer_Product__c>();
            for(Customer_Product__c custProd : listCustomerProductsToUpdate){
                mapCustomerProductsToUpdate.put(custProd.Id, custProd);
            }
            
            new SObjectDAO().updateRecordsAndLogErrors(mapCustomerProductsToUpdate.values(), 'Customer Product Duplicate');
    
        }
    }

    private static String buildDuplicateId(Customer_Product__c customerProduct){

        return customerProduct.Product__c + '-' + customerProduct.Portal_Access__c;

    }

}