/**
 * @author CloudMasonry
 * @date 2021
 * @group Web Service Callout Service
 * @description Performs callouts to Business Central to sync Opportunity records
 */
public without sharing class OpportunityBCSyncCalloutService {

    @testVisible
    private static final String STATUS_SYNCED = 'Synced';
    @testVisible
    private static final String STATUS_FAILED = 'Failed';
    public static final String EXCEPTION_CATEGORY = 'Opportunity BC Sync';
    @testVisible
    private static final String INTEGRATION_CONFIG_NAME = 'SFOpportunityEntries';
    @testVisible
    private static final String EXCEPTION_MISSING_CUSTOM_METADATA_DIVISION = 'No Active BC Integration Configuration for Division ';
    @testVisible
    private static final String EXCEPTION_MISSING_CUSTOM_METADATA_DROPSHIP = 'No Active BC Integration Configuration for Dropship Division ';

    private BCSyncDAO serviceDAO;
    SObjectDAO sObjDAO;
    private Set<Id> setOppIds;

    private static final Integer REQ_TIME_OUT = 60000;
    @testVisible List<Opportunity> lstOppsToUpdate;
    @testVisible List<Error_Log__c> lstErrorsToInsert;
    @testVisible List<OpportunityLineItem> lstOppLinesToUpdate;

    private Map<String, BC_Integration_Config__mdt> divisionToIntegrationMap {

        get {
            if (divisionToIntegrationMap == null) {
                divisionToIntegrationMap = new Map<String, BC_Integration_Config__mdt>();
                List<BC_Integration_Config__mdt> integrationsMapValues = integrationDetailsMap.values();
                for(BC_Integration_Config__mdt mtd : integrationsMapValues){
                    divisionToIntegrationMap.put(mtd.Division__c, mtd);
                }
            }
            return divisionToIntegrationMap;
        }
        set;
    }

    private Map<String, BC_Integration_Config__mdt> integrationDetailsMap {
        get {
            if(integrationDetailsMap == null){
                integrationDetailsMap = this.serviceDAO.getIntegrationConfigMap(INTEGRATION_CONFIG_NAME);
            }
            return integrationDetailsMap;
        }
        set;
    }
    
    /**
     * @description Class constructor
     * @param  setAcctIds Record Ids of opportunities to sync
     */
    public OpportunityBCSyncCalloutService(Set<Id> setOppIds){
        this(setOppIds, new BCSyncDAO(), new SObjectDAO());
    }

    @testVisible
    private OpportunityBCSyncCalloutService(Set<Id> setOppIds, BCSyncDAO serviceDAO, SObjectDAO sObjDAO){
        this.setOppIds = setOppIds;
        this.serviceDAO = serviceDAO;
        this.sObjDAO = sObjDAO;
        this.lstOppLinesToUpdate = new List<OpportunityLineItem>();
        this.lstOppsToUpdate = new List<Opportunity>();
        this.lstErrorsToInsert = new List<Error_Log__c>();
    }

    /**
     * @description Executes callouts to Business Central for each Opportunity. Performs callout per Opportunity Line Item.
     *              Allows for individual Opportunity Line Items to fail.
     */
    public void execute(){
        if(this.setOppIds.isEmpty()) { return; }

        List<Opportunity> lstOpps = this.serviceDAO.getOpportunities(STATUS_SYNCED, setOppIds);
        
        for(Opportunity opp : lstOpps){
            Integer prodCount = opp.OpportunityLineItems.size();
            Boolean prodErrors = false;
            Boolean isDropship = String.isNotBlank(opp.Dropship__c);

            BC_Integration_Config__mdt bcInstanceConfig = divisionToIntegrationMap.get(opp.Owner.Division);
            BC_Integration_Config__mdt bcDropshipInstanceConfig = divisionToIntegrationMap.get(opp.Dropship__c);

            if(bcInstanceConfig == null){
                throw new CustomMetadataException(EXCEPTION_MISSING_CUSTOM_METADATA_DIVISION + opp.Owner.Division);
            }

            if(isDropship && bcDropshipInstanceConfig == null){
                throw new CustomMetadataException(EXCEPTION_MISSING_CUSTOM_METADATA_DROPSHIP + opp.Dropship__c);
            }

            for(OpportunityLineItem oppProd : opp.OpportunityLineItems){

                Boolean isSuccess = true;
                Boolean isDropshipSuccess = true;
                Boolean isDropshipProduct = isDropship && oppProd.Product2.Dropship_Only__c;

                if(!isDropshipProduct && StringUtils.doesNotContain(oppProd.BC_Synced_Instances__c, bcInstanceConfig.Named_Credential__c)){
                    isSuccess = sendHTTPReqToInstance(opp, oppProd, prodCount, bcInstanceConfig, false);
                }
                
                if(isDropship && StringUtils.doesNotContain(oppProd.BC_Synced_Instances__c, bcDropshipInstanceConfig.Named_Credential__c)){
                    isDropshipSuccess = sendHTTPReqToInstance(opp, oppProd, prodCount, bcDropshipInstanceConfig, true);
                }

                if(isSuccess && isDropshipSuccess){ 
                    this.lstOppLinesToUpdate.add(new OpportunityLineItem(Id = oppProd.Id, BC_Synced_Instances__c = oppProd.BC_Synced_Instances__c, BC_Sync_Status__c = STATUS_SYNCED));
                } else {
                    prodErrors = true;
                    this.lstOppLinesToUpdate.add(new OpportunityLineItem(Id = oppProd.Id, BC_Synced_Instances__c = oppProd.BC_Synced_Instances__c, BC_Sync_Status__c = STATUS_FAILED));
                }
            }

            setOppSyncStatus(opp, !prodErrors);

        }

        this.sObjDAO.updateRecords(lstOppsToUpdate);
        this.sObjDAO.updateRecords(lstOppLinesToUpdate);
        if(!lstErrorsToInsert.isEmpty()){
            this.sObjDAO.insertRecords(lstErrorsToInsert);
        }
    }

    private Boolean sendHTTPReqToInstance(Opportunity opp, OpportunityLineItem oppProd, Integer prodCount, BC_Integration_Config__mdt bcInstanceConfig, Boolean isDropship){

        Boolean isSuccess = false;
        String strJSONRequest;
        
        try {
            
            OpportunityWrapper oppWrapper = isDropship ? new OpportunityDropShipWrapper(opp, oppProd, prodCount) : new OpportunityWrapper(opp, oppProd, prodCount);
            strJSONRequest = JSON.serialize(oppWrapper);
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
            System.debug('req: ' + req);
            
            HTTP http = new HTTP();
            HTTPResponse res = http.send(req);

            System.debug('RESPONSE');
            System.debug(res);

            if (res.getStatusCode() == 201) {
                oppProd.BC_Synced_Instances__c = StringUtils.addMultiSelectPicklistValue(oppProd.BC_Synced_Instances__c, bcInstanceConfig.Named_Credential__c);
                System.debug(JSON.serializePretty(JSON.deserializeUntyped(res.getBody())));
                isSuccess = true;
            } else {
                throw new CalloutException(String.valueOf(res) + ' ' + res.getBody());
            }

        } catch (Exception ex){
            lstErrorsToInsert.add(new Error_Log__c(
                    Error_Message__c = ex.getMessage()
                    , Stacktrace__c = ex.getStackTraceString()
                    , Associated_Records__c = oppProd.Id
                    , Request_Body__c = strJSONRequest
                    , Exception_Type__c = ex.getTypeName()
                    , Category__c = EXCEPTION_CATEGORY
                    , BC_Instance__c = bcInstanceConfig.Named_Credential__c
                ));
                
            isSuccess = false;
        }
        return isSuccess;
    }

    private void setOppSyncStatus(Opportunity opp, Boolean isSuccess){
        this.lstOppsToUpdate.add(new Opportunity(
            Id = opp.Id
            , BC_Sync_Status__c = isSuccess ? STATUS_SYNCED : STATUS_FAILED
            , BC_Synced__c = isSuccess ? true : opp.BC_Synced__c
            )
        );
    }

    /**
     * @description Base Wrapper class to construct payload to Business Central (BC)
     *              Includes fields synced in all scenarios, initial and continuous sync to BC
     */
    public virtual class OpportunityWrapper {
        String Customer_No { get; set; }
        String Customer_Name { get; set; }
        String Contact_No { get; set; }
        String Contact_Name { get; set; }
        String Address { get; set; }
        String Address_2 { get; set; }
        String Post_Code { get; set; }
        String City { get; set; }
        String County { get; set; }
        String Country_Region { get; set; }
        String Shipment_Date { get; set; }
        String Bill_to_Customer_No { get; set; }
        String Bill_to_Customer_Name { get; set; }
        String Bill_to_Contact_No { get; set; }
        String Bill_to_Address { get; set; }
        String Bill_to_Address_2 { get; set; }
        String Bill_to_Post_Code { get; set; }
        String Bill_to_City { get; set; }
        String Bill_to_County { get; set; }
        String Bill_to_Country_Region { get; set; }
        String Location_Code { get; set; }
        String Shortcut_Dimension_1_Code { get; set; }
        String Shortcut_Dimension_2_Code { get; set; }
        String Payment_Method_Code { get; set; }
        String Ship_to_Contact { get; set; }
        String Ship_to_Phone_No { get; set; }
        String Ship_to_Address { get; set; }
        String Ship_to_Address_2 { get; set; }
        String Ship_to_Post_Code { get; set; }
        String Ship_to_City { get; set; }
        String Ship_to_County { get; set; }
        String Ship_to_Country_Region { get; set; }
        String Shipping_Agent_Code { get; set; }
        String Shipping_Agent_Service_Code { get; set; }
        String External_Document_No { get; set; }
        String Salesperson_Code { get; set; }
        String SF_Opportunity_ID { get; set; }
        String SF_Record_ID { get; set; }
        String Event_Start_Date { get; set; }
        String Venue_Code { get; set; }
        String Description { get; set; }
        String Add_Freight_Line { get; set; }
        String Item_No { get; set; }
        Decimal Quantity { get; set; }
        Decimal Unit_Price { get; set; }
        Decimal Line_Discount_Amount { get; set; }
        Decimal Line_Discount_Percent { get; set; }
        Boolean Residential_Delivery { get; set; }
        Decimal No_of_Lines  { get; set; }
        String DSHIP_IncoTerms { get; set; }
        String DSHIP_Pmt_Type { get; set; }
        String DSHIP_Pmt_Acc_No { get; set; }
        String DSHIP_Pmt_Ctry_Code { get; set; }
        String DSHIP_Duty_Pmt_Type { get; set; }
        String DSHIP_Duty_Pmt_Acc_No { get; set; }
        String DSHIP_Duty_Pmt_Post_Code { get; set; }
        String DSHIP_Duty_Pmt_Ctry_Code { get; set; }
        String DSHIP_Cust_Broker_Type { get; set; }
        String DSHIP_Comm_Inv_Ltrhd { get; set; }
        String DSHIP_Comm_Inv_Sign { get; set; }
        Boolean BC_DropShip { get; set; }
        String Tax_Area_Code { get; set; }
        String Ship_to_Email_1 { get; set; }
        String Ship_to_Email_2 { get; set; }
        String Currency_Code { get; set; }
        String VAT_Bus_Posting_Group { get; set; }

        public OpportunityWrapper(Opportunity opp, OpportunityLineItem oppProd, Integer prodCount) {
            this.Customer_No = opp.Sell_to_Customer_No__c;
            this.Customer_Name = opp.Sell_To__r.Name;
            this.Contact_No = opp.Sell_to_Contact_No__c;
            this.Contact_Name = opp.Sell_to_Contact__r.Name;
            this.Address = opp.Sell_To_Street__c;
            this.Address_2 = opp.Sell_To_Street_2__c;
            this.Post_Code = opp.Sell_to_Zip__c;
            this.City = opp.Sell_To_City__c;
            this.County = opp.Sell_to_State__c;
            this.Country_Region = opp.Sell_To_Country__c;
            this.Shipment_Date = String.valueOf(opp.Shipment_Date__c);
            this.Bill_to_Customer_No = opp.Bill_To__r.Account_No__c;
            this.Bill_to_Customer_Name = opp.Bill_To__r.Name;
            this.Bill_to_Contact_No = opp.Bill_To_Contact__r.Contact_No__c;
            this.Bill_to_Address = opp.Bill_To_Street__c;
            this.Bill_to_Address_2 = opp.Bill_To_Street_2__c;
            this.Bill_to_Post_Code = opp.Bill_to_Zip__c;
            this.Bill_to_City = opp.Bill_To_City__c;
            this.Bill_to_County = opp.Bill_to_State__c;
            this.Bill_to_Country_Region = opp.Bill_To_Country__c;
            this.Location_Code = opp.Location_Code__c;
            this.Shortcut_Dimension_1_Code = opp.Category_Code__c;
            this.Shortcut_Dimension_2_Code = opp.Progtype_Code__c;
            this.Payment_Method_Code = opp.Payment_Type__c;
            this.Ship_to_Contact = opp.Ship_To_Contact__r.Name;
            this.Ship_to_Phone_No = opp.Ship_To_Phone_Number__c;
            this.Ship_to_Address = opp.Ship_to_Street__c;
            this.Ship_to_Address_2 = opp.Ship_to_Street_2__c;
            this.Ship_to_Post_Code = opp.Ship_to_Zip__c;
            this.Ship_to_City = opp.Ship_To_City__c;
            this.Ship_to_County = opp.Ship_to_State__c;
            this.Ship_to_Country_Region = opp.Ship_to_Country__c;
            this.Shipping_Agent_Code = opp.Shipping_Agent_Code_Courier__c;
            this.Shipping_Agent_Service_Code = opp.Shipping_Agent_Service_Code_Priority__c;
            this.External_Document_No = opp.External_Document_Number__c;
            this.Salesperson_Code = opp.Salesperson_Code__c.length() > 20 ? opp.Salesperson_Code__c.substring(0, 20) : opp.Salesperson_Code__c;
            this.SF_Opportunity_ID = opp.Id;
            this.SF_Record_ID = opp.Id;
            this.Event_Start_Date = String.valueOf(opp.Event_Start_Date__c);
            this.Add_Freight_Line = opp.Add_Freight_Line__c;
            this.Residential_Delivery = opp.Residential_Delivery__c == 'Yes';
            this.No_of_Lines = prodCount;
            this.Venue_Code = opp.Venue_Code__c;
            this.Description = oppProd.Product2.Name;
            this.Item_No = oppProd.ProductCode;
            this.Quantity = oppProd.Quantity;
            this.Unit_Price = oppProd.UnitPrice;
            this.Line_Discount_Amount = oppProd.Line_Discount_Amount__c == null ? 0 : Decimal.valueOf(oppProd.Line_Discount_Amount__c);
            this.Line_Discount_Percent = oppProd.Line_Discount__c;
            this.DSHIP_IncoTerms = opp.IncoTerms__c;
            this.DSHIP_Pmt_Type = opp.Shipping_Cost_Payment_Type__c;
            this.DSHIP_Pmt_Acc_No = opp.Shipping_Payment_Account_No__c;
            this.DSHIP_Pmt_Ctry_Code = opp.Payment_Country_code__c;
            this.DSHIP_Duty_Pmt_Type = opp.Duty_Payment_Type__c;
            this.DSHIP_Duty_Pmt_Acc_No = opp.Duty_Payment_Account_No__c;
            this.DSHIP_Duty_Pmt_Post_Code = opp.Duty_Payment_Post_Code__c;
            this.DSHIP_Duty_Pmt_Ctry_Code = opp.Duty_Payment_Country_code__c;
            this.DSHIP_Cust_Broker_Type = opp.Customs_Broker_Type__c;
            this.DSHIP_Comm_Inv_Ltrhd = opp.Commercial_Inv_Letterhead__c;
            this.DSHIP_Comm_Inv_Sign = opp.Commercial_Inv_Signature__c;
            this.Tax_Area_Code = opp.Tax_Area_Code__c;
            this.Ship_to_Email_1 = opp.Ship_To_Email_1__c;
            this.Ship_to_Email_2 = opp.Ship_To_Email_2__c;
            this.BC_DropShip = false;
            this.Currency_Code = opp.BC_Currency_Code__c;
            this.VAT_Bus_Posting_Group = opp.Vat_Bus_Posting_Group__c;
        }
    }
    public class OpportunityDropShipWrapper extends OpportunityWrapper {
        
        public OpportunityDropShipWrapper(Opportunity opp, OpportunityLineItem oppProd, Integer prodCount){
            super(opp, oppProd, prodCount);
            this.Shortcut_Dimension_1_Code = opp.Dropship_Category_Code__c;
            this.Bill_to_Customer_No = opp.Dropship_Bill_to__r.Account_No__c;
            this.Customer_No = opp.Dropship_Bill_to__r.Account_No__c;
            this.Bill_to_Customer_Name = opp.Dropship_Bill_to__r.Name;
            this.Customer_Name = opp.Dropship_Bill_to__r.Name;
            this.Location_Code = opp.Dropship_Location_Code__c;
            this.BC_DropShip = true;

            this.Bill_to_Contact_No = '';
            this.Bill_to_Address = '';
            this.Bill_to_Address_2 = '';
            this.Bill_to_Post_Code = '';
            this.Bill_to_City = '';
            this.Bill_to_County = '';
            this.Bill_to_Country_Region = '';
            this.Contact_No = '';
            this.Contact_Name = '';
            this.Address = '';
            this.Address_2 = '';
            this.Post_Code = '';
            this.City = '';
            this.County = '';
            this.Country_Region = '';
            this.Salesperson_Code = '';
            this.VAT_Bus_Posting_Group = null;
        }
    }
}