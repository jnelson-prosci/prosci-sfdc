/**
 * @author CloudMasonry
 * @date 2021
 * @group Web Service Callout Service
 * @description Performs callouts to Business Central to sync Contact records
 */
public with sharing class ContactBCSyncCalloutService {

    @testVisible
    private static final String STATUS_SYNCED = 'Synced';
    @testVisible
    private static final String STATUS_FAILED = 'Failed';
    public static final String EXCEPTION_CATEGORY = 'Contact BC Sync';
    // placeholder value to tell BC to write field as null
    // distinguishes from fields that are not included in payload that would otherwise appear blank
    @testVisible
    private static final String NULL_PLACEHOLDER = '-';
    public static final String INTEGRATION_CONFIG_NAME = 'SFContactEntries';
    @testVisible
    private static final String EXCEPTION_MISSING_CUSTOM_METADATA = 'No Active BC Integration Configuration for ';
    private static final Integer REQ_TIME_OUT = 60000;

    private static Set<String> queryFields = new Set<String>{
        'FirstName'
        , 'LastName'
        , 'OtherStreet'
        , 'OtherCity'
        , 'OtherState'
        , 'OtherPostalCode'
        , 'OtherCountry'
        , 'Contact_No__c'
        , 'Account_No__c'
        , 'Contact_Primary_Phone__c'
        , 'Email'
        , 'BC_Synced__c'
        , 'BC_Synced_Instances__c'
    };

    private BCSyncDAO serviceDAO;
    private SObjectDAO sObjDAO;
    private Set<Id> setConIds;
    @testVisible
    List<Contact> lstConsToUpdate;
    @testVisible
    List<Error_Log__c> lstErrorsToInsert;

    private Map<String, BC_Integration_Config__mdt> integrationDetailsMap {
        get {
            if(integrationDetailsMap == null){
                integrationDetailsMap = serviceDAO.getIntegrationConfigMap(INTEGRATION_CONFIG_NAME);
            }
            return integrationDetailsMap;
        }
        set;
    }

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
     * @param  setConIds Record Ids of contacts to sync
     */
    public ContactBCSyncCalloutService(Set<Id> setConIds){
        this(setConIds, new BCSyncDAO(), new SObjectDAO());
    }

    @testVisible
    private ContactBCSyncCalloutService(Set<Id> setConIds, BCSyncDAO serviceDAO, SObjectDAO sObjDAO){
        this.setConIds = setConIds;
        this.serviceDAO = serviceDAO;
        this.sObjDAO = sObjDAO;
        this.lstConsToUpdate = new List<Contact>();
        this.lstErrorsToInsert = new List<Error_Log__c>();
    }

    /**
     * @description Executes callouts to Business Central for each contact. Performs callout per contact and per active Instance Configuration
     *              Allows for individual contacts to fail.
     */
    public void execute(){
        if(this.setConIds.isEmpty()) { return; }

        List<Contact> lstCons = this.serviceDAO.getRecords('Contact', queryFields, this.lstFieldMap, this.setConIds);

        for(Contact con : lstcons){

            Integer successCount = 0;

            for(BC_Integration_Config__mdt bcInstance : integrationDetailsMap.values()){

                Boolean isSuccess = sendHTTPReqToInstance(con, bcInstance);
                if(isSuccess){
                    successCount++;
                }

            }

            setRecordSyncStatus(con, successCount == integrationDetailsMap.size());
        }

        saveRecords();
    }

    /**
     * @description Executes callouts to Business Central for each contact. Performs callout per contact and the specified Instance Configuration
     *              Allows for individual contacts to fail.
     * @param  strBCInstance strBCInstance description
     */
    public void execute(String strBCInstance){
        if(this.setConIds.isEmpty()) { return; }

        List<Contact> lstCons = this.serviceDAO.getRecords('Contact', queryFields, this.lstFieldMap, this.setConIds);

        BC_Integration_Config__mdt bcInstanceConfig = integrationDetailsMap.get(strBCInstance);

        if(bcInstanceConfig == null){
            throw new CustomMetadataException(EXCEPTION_MISSING_CUSTOM_METADATA + strBCInstance);
        }

        for(Contact con : lstcons){
            Boolean isSuccess = sendHTTPReqToInstance(con, bcInstanceConfig);

            setRecordSyncStatus(con, isSuccess);
        }

        saveRecords();
    }

    private Boolean sendHTTPReqToInstance(Contact con, BC_Integration_Config__mdt bcInstanceConfig){
        Boolean isSuccess = false;
        String strJSONRequest;
    
        try {

            strJSONRequest = JSON.serialize(buildRequestBody(con, bcInstanceConfig.Named_Credential__c));

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
                con.BC_Synced_Instances__c = StringUtils.addMultiSelectPicklistValue(con.BC_Synced_Instances__c, bcInstanceConfig.Named_Credential__c);
                System.debug(JSON.serializePretty(JSON.deserializeUntyped(res.getBody())));
                isSuccess = true;
            } else {
                throw new CalloutException(String.valueOf(res) + ' ' + res.getBody());
            }

        } catch (Exception ex){
            lstErrorsToInsert.add(new Error_Log__c(
                    Error_Message__c = ex.getMessage()
                    , Stacktrace__c = ex.getStackTraceString()
                    , Associated_Records__c = con.Id
                    , Request_Body__c = strJSONRequest
                    , Exception_Type__c = ex.getTypeName()
                    , Category__c = EXCEPTION_CATEGORY
                    , BC_Instance__c = bcInstanceConfig.Named_Credential__c
                ));
            isSuccess = false;
        }
        return isSuccess;
    }

    private void saveRecords(){
        this.sObjDAO.updateRecords(this.lstConsToUpdate);
        if(!this.lstErrorsToInsert.isEmpty()){
            this.sObjDAO.insertRecords(this.lstErrorsToInsert);
        }
    }

    private void setRecordSyncStatus(Contact con, Boolean isSuccess){
        this.lstConsToUpdate.add(new Contact(
            Id = con.Id
            , BC_Synced_Instances__c = con.BC_Synced_Instances__c
            , BC_Sync_Status__c = isSuccess ? STATUS_SYNCED : STATUS_FAILED
            , BC_Synced__c = isSuccess ? true : con.BC_Synced__c
            )
        );
    }

    private Map<String, Object> buildRequestBody (Contact con, String strBCInstance){
        Boolean isInsert = !(con.BC_Synced_Instances__c != null && con.BC_Synced_Instances__c.contains(strBCInstance));
        Object obj = (Object)new ContactSyncWrapper(con);
        List<BC_Integration_Mapping__mdt> lstFieldMappings = integrationMapping.get(strBCInstance);
        return BCSyncUtils.buildRequestBody(con, obj, lstFieldMappings, isInsert);
    }

    /**
     * @description Base Wrapper class to construct payload to Business Central (BC)
     *              Includes fields synced in all scenarios, initial and continuous sync to BC
     */
    public class ContactSyncWrapper {
        String SF_Record_ID { get; set; }
        String Name { get; set; }
        @testVisible
        String Address { get; set; }
        @testVisible
        String Address_2 { get; set; }
        String City { get; set; }
        String County { get; set; }
        String Post_Code { get; set; }
        String Country_Region { get; set; }
        String SF_Contact_ID { get; set; }
        String Customer_No { get; set; }
        String Phone_No { get; set; }
        String Email_Address { get; set; }
        String Is_a_Person { get; set; }

        public ContactSyncWrapper (Contact con) {
            this.SF_Record_ID = con.Id;
            this.SF_Contact_ID = String.isBlank(con.Contact_No__c) ? '-' : con.Contact_No__c;
            this.Customer_No = String.isBlank(con.Account_No__c) ? '-' : con.Account_No__c;
            this.Name = String.isBlank(con.FirstName) ? con.LastName : con.FirstName + ' ' + con.LastName;
            this.Email_Address = String.isBlank(con.Email) ? '-' : con.Email;
            this.Country_Region = String.isBlank(con.OtherCountry)  ? '-' : con.OtherCountry;
            this.City = String.isBlank(con.OtherCity)  ? '-' : con.OtherCity;
            this.County = String.isBlank(con.OtherState)  ? '-' : con.OtherState;
            this.Post_Code = String.isBlank(con.OtherPostalCode)  ? '-' : con.OtherPostalCode;
            this.Phone_No = String.isBlank(con.Contact_Primary_Phone__c)  ? '-' : con.Contact_Primary_Phone__c;
            this.Is_a_Person = 'true';
            if (String.isBlank(con.OtherStreet)) {
                this.Address = '-';
                this.Address_2 = '-';
            } else {
                List<String> streetLines = con.OtherStreet.split('\r\n');
                this.Address = streetLines.get(0);
                this.Address_2 = streetLines.size() == 1 ? '-' : streetLines.get(1);
            }
        }
    }
}