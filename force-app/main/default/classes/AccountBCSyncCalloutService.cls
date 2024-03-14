/**
 * @author CloudMasonry
 * @date 2021
 * @group Web Service Callout Service
 * @description Performs callouts to Business Central to sync Account records
 */
public with sharing class AccountBCSyncCalloutService {

    @testVisible
    private static final String STATUS_SYNCED = 'Synced';
    @testVisible
    private static final String STATUS_FAILED = 'Failed';
    public static final String EXCEPTION_CATEGORY = 'Account BC Sync';
    // placeholder value to tell BC to write field as null
    // distinguishes from fields that are not included in payload that would otherwise appear blank
    @testVisible
    private static final String NULL_PLACEHOLDER = '-';
    // @testVisible
    public static final String INTEGRATION_CONFIG_NAME = 'SFCustomerEntries';
    private static final Integer REQ_TIME_OUT = 60000;
    @testVisible
    private static final String EXCEPTION_MISSING_CUSTOM_METADATA = 'No Active BC Integration Configuration for ';


    private static Set<String> queryFields = new Set<String>{
        'Name'    
        , 'Account_Name_2__c'
        , 'BillingStreet'
        , 'BillingCity'
        , 'BillingState'
        , 'BillingPostalCode'
        , 'BillingCountry'
        , 'Phone'
        , 'Fax'
        , 'Price_Group__c'
        , 'Payment_Terms__c'
        , 'Account_No__c'
        , 'BC_Synced_Instances__c'
        , 'BC_Synced__c'
    };
    @testVisible
    private BCSyncDAO serviceDAO;
    @testVisible
    private SObjectDAO sObjDAO; 
    @testVisible
    private Set<Id> setAcctIds;
    @testVisible
    List<Account> lstAcctsToUpdate;
    @testVisible
    List<Error_Log__c> lstErrorsToInsert;

    @testVisible
    private Map<String, BC_Integration_Config__mdt> integrationDetailsMap {
        get {
            if(integrationDetailsMap == null){
                integrationDetailsMap = serviceDAO.getIntegrationConfigMap(INTEGRATION_CONFIG_NAME);
            }
            return integrationDetailsMap;
        }
        set;
    }
    @testVisible
    private List<BC_Integration_Mapping__mdt> lstFieldMap {
        get {
            if(lstFieldMap == null){
                lstFieldMap = serviceDAO.getIntegrationFieldMapping(INTEGRATION_CONFIG_NAME);
            }
            return lstFieldMap;
        }
        set;
    }

    private Map<String, List<BC_Integration_Mapping__mdt>> integrationMapping {
        get {
            if(integrationMapping == null){
                integrationMapping = serviceDAO.buildIntegrationFieldMappingsMap(lstFieldMap);
            }
            return integrationMapping;
        }
        set;
    }

    /**
     * @description Class constructor
     * @param  setAcctIds Record Ids of accounts to sync
     */
    public AccountBCSyncCalloutService(Set<Id> setAcctIds){
        this(setAcctIds, new BCSyncDAO(), new SObjectDAO());
    }

    @testVisible
    private AccountBCSyncCalloutService(Set<Id> setAcctIds, BCSyncDAO serviceDAO, SObjectDAO sObjDAO){
        this.setAcctIds = setAcctIds;
        this.serviceDAO = serviceDAO;
        this.sObjDAO = sObjDAO;


    }

    /**
     * @description Executes callouts to Business Central for each account. Performs callout per Account and per active Instance Configuration
     *              Allows for individual accounts to fail.
     */
    public void execute(){
        if(this.setAcctIds.isEmpty()) { return; }

        this.lstAcctsToUpdate = new List<Account>();
        this.lstErrorsToInsert = new List<Error_Log__c>();

        List<Account> lstAccts = this.serviceDAO.getRecords('Account', queryFields, this.lstFieldMap, this.setAcctIds);
        for(Account acct : lstAccts){

            Integer successCount = 0;

            for(BC_Integration_Config__mdt bcInstance : integrationDetailsMap.values()){

                Boolean isSuccess = sendHTTPReqToInstance(acct, bcInstance);
                if(isSuccess){
                    successCount++;
                }
            }

            setRecordSyncStatus(acct, successCount == integrationDetailsMap.size());
        }

        saveRecords();
    }

    /**
     * @description Executes callouts to Business Central for each account. Performs callout per Account and the specified Instance Configuration
     *              Allows for individual accounts to fail.
     * @param  strBCInstance strBCInstance description
     */
    public void execute(String strBCInstance){
        if(this.setAcctIds.isEmpty()) { return; }

        this.lstAcctsToUpdate = new List<Account>();
        this.lstErrorsToInsert = new List<Error_Log__c>();

        List<Account> lstAccts = this.serviceDAO.getRecords('Account', queryFields, this.lstFieldMap, this.setAcctIds);

        BC_Integration_Config__mdt bcInstanceConfig = integrationDetailsMap.get(strBCInstance);

        if(bcInstanceConfig == null){
            throw new CustomMetadataException(EXCEPTION_MISSING_CUSTOM_METADATA + strBCInstance);
        }

        for(Account acct : lstAccts){
            Boolean isSuccess = sendHTTPReqToInstance(acct, bcInstanceConfig);

            setRecordSyncStatus(acct, isSuccess);
        }

        saveRecords();
    }

    private Boolean sendHTTPReqToInstance(Account acct, BC_Integration_Config__mdt bcInstanceConfig){
        Boolean isSuccess = false;
        String strJSONRequest;
    
        try {

            strJSONRequest = JSON.serialize(buildRequestBody(acct, bcInstanceConfig.Named_Credential__c));

            HTTPRequest req = new HTTPRequest();

            req.setTimeout(REQ_TIME_OUT);
            req.setBody(strJSONRequest);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Content-Length', '' + strJSONRequest.length());
            req.setHeader('Accept', 'application/json');
            req.setEndpoint('callout:' + bcInstanceConfig.Named_Credential__c + bcInstanceConfig.URI_Path__c);
            req.setMethod('POST');
            
            System.debug('REQUEST');
            System.debug(JSON.serializePretty(JSON.deserializeUntyped(strJSONRequest)));

            HTTP http = new HTTP();
            HTTPResponse res = http.send(req);

            System.debug('RESPONSE');
            System.debug(res);

            if (res.getStatusCode() == 201) {
                acct.BC_Synced_Instances__c = StringUtils.addMultiSelectPicklistValue(acct.BC_Synced_Instances__c, bcInstanceConfig.Named_Credential__c);
                System.debug(JSON.serializePretty(JSON.deserializeUntyped(res.getBody())));
                isSuccess = true;
            } else {
                throw new CalloutException(String.valueOf(res) + ' ' + res.getBody());
                
            }

        } catch (Exception ex){
            this.lstErrorsToInsert.add(new Error_Log__c(
                    Error_Message__c = ex.getMessage()
                    , Stacktrace__c = ex.getStackTraceString()
                    , Associated_Records__c = acct.Id
                    , Request_Body__c = strJSONRequest
                    , Exception_Type__c = ex.getTypeName()
                    , Category__c = EXCEPTION_CATEGORY
                    , BC_Instance__c = bcInstanceConfig.Named_Credential__c

                ));
            System.debug(' this is ex.getStackTraceString():' + ex.getStackTraceString());
            System.debug(' this is ex.getMessage():' + ex.getMessage());
            isSuccess = false;
        }
        return isSuccess;
    }

    private Map<String, Object> buildRequestBody (Account acct, String strBCInstance){
        Boolean isInsert = !(acct.BC_Synced_Instances__c != null && acct.BC_Synced_Instances__c.contains(strBCInstance));
        Object obj = isInsert ? (Object)new AccountInitSyncWrapper(acct) : (Object)new AccountSyncWrapper(acct);
        List<BC_Integration_Mapping__mdt> lstFieldMappings = integrationMapping.get(strBCInstance);
        return BCSyncUtils.buildRequestBody(acct, obj, lstFieldMappings, isInsert);
    }

    private void setRecordSyncStatus(Account acct, Boolean isSuccess){
        lstAcctsToUpdate.add(new Account(
            Id = acct.Id
            , BC_Synced_Instances__c = acct.BC_Synced_Instances__c
            , BC_Sync_Status__c = isSuccess ? STATUS_SYNCED : STATUS_FAILED
            , BC_Synced__c = isSuccess ? true : acct.BC_Synced__c
            )
        );
    }

    /**
     * @description saveRecords description
     */
    private void saveRecords(){
        this.sObjDAO.updateRecords(this.lstAcctsToUpdate);
        if(!this.lstErrorsToInsert.isEmpty()){
            this.sObjDAO.insertRecords(this.lstErrorsToInsert);
        }
    }
    
    /**
     * @description Base Wrapper class to construct payload to Business Central (BC)
     *              Includes fields synced in all scenarios, initial and continuous sync to BC
     *              Virtual class to allow extension for different sync scenarios and payloads
     */
    public virtual class AccountSyncWrapper {
        String SF_Record_ID { get; set; }
        String SF_Customer_ID { get; set; }
        String Name { get; set; }
        String Name_2 { get; set; }
        String Customer_Price_Group { get; set; }
        String Payment_Terms_Code { get; set; }

        
        public AccountSyncWrapper(Account acct) {
            this.SF_Record_ID = acct.Id;
            this.SF_Customer_ID = String.isEmpty(acct.Account_No__c) ? NULL_PLACEHOLDER : acct.Account_No__c;
            this.Name = String.isEmpty(acct.Name) ? NULL_PLACEHOLDER : acct.Name;
            this.Name_2 = String.isEmpty(acct.Account_Name_2__c) ? NULL_PLACEHOLDER : acct.Account_Name_2__c;
            this.Customer_Price_Group = String.isEmpty(acct.Price_Group__c) ? NULL_PLACEHOLDER : acct.Price_Group__c;
            this.Payment_Terms_Code = String.isEmpty(acct.Payment_Terms__c) ? NULL_PLACEHOLDER : acct.Payment_Terms__c;

        }
        
    }

    /**
     * @description Wrapper class to constructor payload to Business Central (BC)
     *              Extends base wrapper to add fields that are sent only on the initial sync to BC
     */
    public class AccountInitSyncWrapper extends AccountSyncWrapper {
        @TestVisible
        String Address { get; set; }
        @TestVisible
       	String Address_2 { get; set; }
        String Country_Region { get; set; }
        String City { get; set; }
        String County { get; set; }
        String Post_Code { get; set; }
        String Phone_No { get; set; }
        String Fax_No { get; set; }
        
        public AccountInitSyncWrapper(Account acct) {
            super(acct);
            if (String.isBlank(acct.BillingStreet)) {
                this.Address = NULL_PLACEHOLDER;
                this.Address_2 = NULL_PLACEHOLDER;
            } else {
                List<String> streetLines = acct.BillingStreet.split('\r\n');
                this.Address = streetLines.get(0);
                this.Address_2 = streetLines.size() == 1 ? NULL_PLACEHOLDER : streetLines.get(1);
            }
           	this.Country_Region = String.isEmpty(acct.BillingCountry) ? NULL_PLACEHOLDER : acct.BillingCountry;
            this.City = String.isEmpty(acct.BillingCity) ? NULL_PLACEHOLDER : acct.BillingCity;
            this.County = String.isEmpty(acct.BillingState) ? NULL_PLACEHOLDER : acct.BillingState;
            this.Post_Code = String.isEmpty(acct.BillingPostalCode) ? NULL_PLACEHOLDER : acct.BillingPostalCode;
            this.Phone_No = String.isEmpty(acct.Phone) ? NULL_PLACEHOLDER : acct.Phone;
            this.Fax_No = String.isEmpty(acct.Fax) ? NULL_PLACEHOLDER : acct.Fax;
        }
    }
}