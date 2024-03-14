@IsTest
private with sharing class CustomerProductDupeManagerServiceTest {
    
    private static Date DEFAULTEXPIRATIONDATE = Date.today().addDays(100);

    private static Portal_Access__c createPortalAccess(){
        Portal_Access__c tPortalAccess = new Portal_Access__c(
            Active__c = true
            , Email__c = 'TestPortalAccess@example.com'
            , First_Name__c = 'TestPortalAccessFirstname'
            , Last_Name__c = 'TestPortalAccessLastName'
            , customer_type_id__c = '1'
            );
        insert tPortalAccess;

        return tPortalAccess;
    }

    private static Product2 createProduct(){
        Product2 tProduct = buildProduct();
        insert tProduct;

        return tProduct;
    }

    private static Product2 buildProduct(){
        Product2 tProduct = new Product2(Name = 'TestProduct');

        return tProduct;
    }


    public static Customer_Product__c createCustomerProduct(Id portalAccessId, Id productId) {
        Customer_Product__c tCustomerProduct = buildCustomerProduct(portalAccessId, productId);
        insert tCustomerProduct;

        return tCustomerProduct;
    }

    public static Customer_Product__c buildCustomerProduct(Id portalAccessId, Id productId) {
        Customer_Product__c tCustomerProduct = new Customer_Product__c(
              Active__c = true
            , Portal_Access__c = portalAccessId
            , Product__c = productId
            , expiration_date__c = DEFAULTEXPIRATIONDATE
            );

        return tCustomerProduct;
    }

    @IsTest static void executeNewCustomerProductNoDupes(){

        CustomerProductTriggerHandler.byPass = true;

        Portal_Access__c tPortalAccess = createPortalAccess();
        Product2 tProduct = createProduct();
        Customer_Product__c tCustomerProduct = createCustomerProduct(tPortalAccess.Id, tProduct.Id);

        List<Customer_Product__c> tCustomerProductList = new List<Customer_Product__c> ();
        tCustomerProductList.add(tCustomerProduct); 

        CustomerProductTriggerHandler.byPass = false;

        Test.startTest();

        new CustomerProductDupeManagerService().execute(tCustomerProductList);

        Test.stopTest();

        List<Customer_Product__c> rCustomerProductList = [
            SELECT Id, Active__c, expiration_date__c
            FROM Customer_Product__c 
        ];

        System.assertEquals(1, rCustomerProductList.size());
        Customer_Product__c rCustomerProduct = rCustomerProductList[0];

        System.assertEquals(tCustomerProduct.Active__c, rCustomerProduct.Active__c);
        System.assertEquals(tCustomerProduct.expiration_date__c, rCustomerProduct.expiration_date__c);

    }

    @IsTest static void executeNewCustomerProductNoDupesMulti(){

        CustomerProductTriggerHandler.byPass = true;

        Portal_Access__c tPortalAccess = createPortalAccess();
        Product2 tProduct1 = createProduct();
        Product2 tProduct2 = createProduct();
        Customer_Product__c tCustomerProduct1 = createCustomerProduct(tPortalAccess.Id, tProduct1.Id);
        Customer_Product__c tCustomerProduct2 = createCustomerProduct(tPortalAccess.Id, tProduct2.Id);

        List<Customer_Product__c> tCustomerProductListMulti = new List<Customer_Product__c> ();
        tCustomerProductListMulti.add(tCustomerProduct1);
        tCustomerProductListMulti.add(tCustomerProduct2);

        CustomerProductTriggerHandler.byPass = false;

        Test.startTest();

        new CustomerProductDupeManagerService().execute(tCustomerProductListMulti);

        Test.stopTest();

        List<Customer_Product__c> rCustomerProductListMulti = [
            SELECT Id, Active__c, Product__c, expiration_date__c
            FROM Customer_Product__c 
        ];

        System.assertEquals(2, rCustomerProductListMulti.size());
        Customer_Product__c rCustomerProduct1 = rCustomerProductListMulti[0];
        Customer_Product__c rCustomerProduct2 = rCustomerProductListMulti[1];

        System.assertNotEquals(rCustomerProduct1.Product__c, rCustomerProduct2.Product__c, 'Two different products exist within the list');

    }

    @IsTest static void executeNewCustomerProductDupesSameExpirationDate(){

        CustomerProductTriggerHandler.byPass = true;

        Portal_Access__c tPortalAccess = createPortalAccess();
        Product2 tProduct1 = createProduct();
        Customer_Product__c tCustomerProduct1 = createCustomerProduct(tPortalAccess.Id, tProduct1.Id);
        Customer_Product__c tCustomerProduct2 = createCustomerProduct(tPortalAccess.Id, tProduct1.Id);
        List<Customer_Product__c> tCustomerProductListMulti = new List<Customer_Product__c> ();
        tCustomerProductListMulti.add(tCustomerProduct2);

        CustomerProductTriggerHandler.byPass = false;

        Test.startTest();

        new CustomerProductDupeManagerService().execute(tCustomerProductListMulti);

        Test.stopTest();

        List<Customer_Product__c> rCustomerProductListMulti = [
            SELECT Id, Active__c, Product__c, expiration_date__c
            FROM Customer_Product__c 
        ];

        System.assertEquals(2, rCustomerProductListMulti.size());
        

        Boolean customerProduct1Exists = false;
        Boolean customerProduct2Exists = false;

        for(Customer_Product__c customerProduct: rCustomerProductListMulti){
            if(customerProduct.Id == tCustomerProduct2.Id){
                System.assertEquals(true, customerProduct.Active__c);
                customerProduct2Exists = true;
            } else if (customerProduct.Id == tCustomerProduct1.Id){
                System.assertEquals(false, customerProduct.Active__c);
                customerProduct1Exists = true;
            }
        }

        System.assertEquals(true, customerProduct1Exists);
        System.assertEquals(true, customerProduct2Exists);

    }

    @IsTest static void executeNewCustomerProductDupesDiffExpirationDates(){

        CustomerProductTriggerHandler.byPass = true;

        Portal_Access__c tPortalAccess = createPortalAccess();
        Product2 tProduct1 = createProduct();
        Customer_Product__c tCustomerProduct1 = createCustomerProduct(tPortalAccess.Id, tProduct1.Id);
        Customer_Product__c tCustomerProduct2 = createCustomerProduct(tPortalAccess.Id, tProduct1.Id);
        tCustomerProduct2.expiration_date__c.addDays(365);

        List<Customer_Product__c> tCustomerProductListMulti = new List<Customer_Product__c> ();
        tCustomerProductListMulti.add(tCustomerProduct1);
        tCustomerProductListMulti.add(tCustomerProduct2);

        CustomerProductTriggerHandler.byPass = false;

        Test.startTest();

        new CustomerProductDupeManagerService().execute(tCustomerProductListMulti);

        Test.stopTest();

        List<Customer_Product__c> rCustomerProductListMulti = [
            SELECT Id, Active__c, Product__c, expiration_date__c
            FROM Customer_Product__c 
        ];

        System.assertEquals(2, rCustomerProductListMulti.size());

        Boolean customerProduct1Exists = false;
        Boolean customerProduct2Exists = false;

        for(Customer_Product__c customerProduct: rCustomerProductListMulti){
            if(customerProduct.Id == tCustomerProduct2.Id){
                System.assertEquals(true, customerProduct.Active__c);
                customerProduct2Exists = true;
            } else if (customerProduct.Id == tCustomerProduct1.Id){
                System.assertEquals(false, customerProduct.Active__c);
                customerProduct1Exists = true;
            }
        }

        System.assertEquals(true, customerProduct1Exists);
        System.assertEquals(true, customerProduct2Exists);

    }


    @IsTest static void executeNewCustomerProductDupesNullExpirationDate(){

        Date nullExpirationDate = null;

        CustomerProductTriggerHandler.byPass = true;

        Portal_Access__c tPortalAccess = createPortalAccess();
        Product2 tProduct1 = createProduct();
        Customer_Product__c tCustomerProduct1 = buildCustomerProduct(tPortalAccess.Id, tProduct1.Id);
        Customer_Product__c tCustomerProduct2 = buildCustomerProduct(tPortalAccess.Id, tProduct1.Id);
        tCustomerProduct2.expiration_date__c = nullExpirationDate;
        tCustomerProduct1.expiration_date__c = nullExpirationDate;
        insert tCustomerProduct1;
        insert tCustomerProduct2;

        List<Customer_Product__c> tCustomerProductListMulti = new List<Customer_Product__c> ();
        tCustomerProductListMulti.add(tCustomerProduct1);
        tCustomerProductListMulti.add(tCustomerProduct2);

        CustomerProductTriggerHandler.byPass = false;

        Test.startTest();

        new CustomerProductDupeManagerService().execute(tCustomerProductListMulti);

        Test.stopTest();

        List<Customer_Product__c> rCustomerProductListMulti = [
            SELECT Id, Active__c, Product__c, expiration_date__c
            FROM Customer_Product__c 
        ];

        System.assertEquals(2, rCustomerProductListMulti.size());

        Boolean customerProduct1Exists = false;
        Boolean customerProduct2Exists = false;

        for(Customer_Product__c customerProduct: rCustomerProductListMulti){
            if(customerProduct.Id == tCustomerProduct2.Id){
                System.assertEquals(true, customerProduct.Active__c);
                System.assertEquals(CustomerProductDupeManagerService.DEFAULTEXPIRATIONDATE, customerProduct.expiration_date__c);
                customerProduct2Exists = true;
            } else if (customerProduct.Id == tCustomerProduct1.Id){
                System.assertEquals(false, customerProduct.Active__c);
                System.assertEquals(nullExpirationDate, customerProduct.expiration_date__c);
                customerProduct1Exists = true;
            }
        }

        System.assertEquals(true, customerProduct1Exists);
        System.assertEquals(true, customerProduct2Exists);

    }

    @IsTest static void executeNewCustomerProductDupesOlderExpirationDate(){

        Date laterExpirationDate = DEFAULTEXPIRATIONDATE.addDays(100);

        CustomerProductTriggerHandler.byPass = true;

        Portal_Access__c tPortalAccess = createPortalAccess();
        Product2 tProduct1 = createProduct();
        Customer_Product__c tCustomerProduct1 = buildCustomerProduct(tPortalAccess.Id, tProduct1.Id);
        Customer_Product__c tCustomerProduct2 = buildCustomerProduct(tPortalAccess.Id, tProduct1.Id);
        tCustomerProduct2.expiration_date__c = DEFAULTEXPIRATIONDATE;
        tCustomerProduct1.expiration_date__c = laterExpirationDate;
        insert tCustomerProduct1;
        insert tCustomerProduct2;

        List<Customer_Product__c> tCustomerProductListMulti = new List<Customer_Product__c> ();
        tCustomerProductListMulti.add(tCustomerProduct1);
        tCustomerProductListMulti.add(tCustomerProduct2);

        CustomerProductTriggerHandler.byPass = false;

        Test.startTest();

        new CustomerProductDupeManagerService().execute(tCustomerProductListMulti);

        Test.stopTest();

        List<Customer_Product__c> rCustomerProductListMulti = [
            SELECT Id, Active__c, Product__c, expiration_date__c
            FROM Customer_Product__c 
        ];

        System.assertEquals(2, rCustomerProductListMulti.size());

        Boolean customerProduct1Exists = false;
        Boolean customerProduct2Exists = false;

        for(Customer_Product__c customerProduct: rCustomerProductListMulti){
            if(customerProduct.Id == tCustomerProduct2.Id){
                System.assertEquals(true, customerProduct.Active__c);
                System.assertEquals(laterExpirationDate, customerProduct.expiration_date__c);
                customerProduct2Exists = true;
            } else if (customerProduct.Id == tCustomerProduct1.Id){
                System.assertEquals(false, customerProduct.Active__c);
                System.assertEquals(laterExpirationDate, customerProduct.expiration_date__c);
                customerProduct1Exists = true;
            }
        }

        System.assertEquals(true, customerProduct1Exists);
        System.assertEquals(true, customerProduct2Exists);

    }

    @IsTest static void executeBulkNewCustomerProductDupes(){

        Portal_Access__c tPortalAccess = createPortalAccess();

        List<Product2> listTestProducts = new List<Product2>();
        List<Customer_Product__c> listTestCustomerProducts1 = new List<Customer_Product__c>();
        List<Customer_Product__c> listTestCustomerProducts2 = new List<Customer_Product__c>();

        for(Integer i = 0; i < 200; i++){
            Product2 testProduct = buildProduct();
            listTestProducts.add(testProduct);
        }
        insert listTestProducts;

        for(Product2 listTestProduct : listTestProducts){
            Customer_Product__c testCustomerProduct1 = buildCustomerProduct(tPortalAccess.Id, listTestProduct.Id);
            Customer_Product__c testCustomerProduct2 = buildCustomerProduct(tPortalAccess.Id, listTestProduct.Id);
            listTestCustomerProducts1.add(testCustomerProduct1);
            listTestCustomerProducts2.add(testCustomerProduct2);
        }
        insert listTestCustomerProducts1;
        
        Test.startTest();

        insert listTestCustomerProducts2;

        Test.stopTest();

        List<Customer_Product__c> rCustomerProductListMulti = [
            SELECT Id, Active__c, Product__c, expiration_date__c
            FROM Customer_Product__c 
        ];

        // Should have first 200 active cases after test runs, 400 total in list
        System.assertEquals(400, rCustomerProductListMulti.size());

    }


}