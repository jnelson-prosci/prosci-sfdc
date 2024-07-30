# Post-Deployment Steps:

1. From Setup -> Developer Console -> Execute Anonymous, run the following script:
    ```List<Product2> productsToUpdate = [SELECT Id, Family FROM Product2 WHERE Family IN ('Training', 'Advisory','Licensing')];
    Map<String, String> productFamilyMap = new Map<String, String>{
        'Training' => 'Enterprise Training',
        'Advisory' => 'Enterprise Advisory',
        'Licensing' => 'Enterprise Licensing'
    };

    for (Product2 product : productsToUpdate) {
        product.Family = productFamilyMap.get(product.Family);
    }

    system.debug('Products::: ' + productsToUpdate);

    if (productsToUpdate != null) {
        update productsToUpdate;
    }
    ```
