/**
 * 
 */
public with sharing class BCSyncDAO {

    public List<BC_Integration_Mapping__mdt> getIntegrationFieldMapping(String strIntegrationName) { 
       
        return [
            SELECT 
                BC_Instance__c
                , Field_Api_Name__c
                , Json_Key__c
                , Insert_Only__c
            FROM BC_Integration_Mapping__mdt 
            WHERE integration_Name__c = :strIntegrationName
            AND Active__c = true
        ];
    }

    public Map<String, List<BC_Integration_Mapping__mdt>> buildIntegrationFieldMappingsMap(List<BC_Integration_Mapping__mdt> lstFieldMaps) { 

        Map<String, List<BC_Integration_Mapping__mdt>> mapInstanceLstFieldMap = new Map<String, List<BC_Integration_Mapping__mdt>>();

        for (BC_Integration_Mapping__mdt fieldMap : lstFieldMaps) {
            List<BC_Integration_Mapping__mdt> lstInstanceFieldMap = mapInstanceLstFieldMap.get(fieldMap.BC_Instance__c);
            if(lstInstanceFieldMap == null){
                lstInstanceFieldMap = new List<BC_Integration_Mapping__mdt>();
            }
            lstInstanceFieldMap.add(fieldMap);
            mapInstanceLstFieldMap.put(fieldMap.BC_Instance__c, lstInstanceFieldMap);
        }
        return mapInstanceLstFieldMap;
    } 

    public Map<String, BC_Integration_Config__mdt> getIntegrationConfigMap(String strIntegrationName) { 
        Map<String, BC_Integration_Config__mdt> mapIntegrationConfig = new Map<String, BC_Integration_Config__mdt>();

        for (BC_Integration_Config__mdt mdt : [
            SELECT 
                Named_Credential__c
                , URI_Path__c
                , Division__c 
            FROM BC_Integration_Config__mdt 
            WHERE integration_Name__c = :strIntegrationName 
            AND Active__c = true]) {

            mapIntegrationConfig.put(mdt.Named_Credential__c, mdt);
        }
        return mapIntegrationConfig;
    }

    public List<SObject> getRecords(String sOBjectType, Set<String> setFields, List<BC_Integration_Mapping__mdt> lstFieldMap, Set<Id> setRecordIds){
        for(BC_Integration_Mapping__mdt fieldMap : lstFieldMap){
            setFields.add(fieldMap.Field_Api_Name__c);
        }
        String strQuery = 'SELECT ' + String.join(new List<String>(setFields), ',') + ' FROM ' + sOBjectType + ' WHERE Id IN :setRecordIds';
        return Database.query(strQuery);
    }

    public List<Opportunity> getOpportunities(String statusSynced, Set<Id> setOppIds){

        return [
            SELECT
                Sell_to_Customer_No__c
                , Sell_To__c
                , Sell_To__r.Name
                , Sell_to_Contact_No__c
                , Sell_to_Contact__r.Name
                , Sell_To_Street__c
                , Sell_To_Street_2__c
                , Sell_to_Zip__c
                , Sell_To_City__c
                , Sell_to_State__c
                , Sell_To_Country__c
                , Shipment_Date__c
                , Bill_To__r.Account_No__c
                , Bill_To__r.Name
                , Bill_To_Contact__c
                , Bill_To_Contact__r.Contact_No__c
                , Bill_To_Street__c
                , Bill_To_Street_2__c
                , Bill_to_Zip__c
                , Bill_To_City__c
                , Bill_to_State__c
                , Bill_To_Country__c
                , Location_Code__c
                , Category_Code__c
                , Owner.Division              
                , Progtype_Code__c
                , Payment_Type__c
                , Ship_To_Contact__c
                , Ship_To_Contact__r.Name
                , Ship_To_Phone_Number__c
                , Ship_to_Street__c
                , Ship_to_Street_2__c
                , Ship_to_Zip__c
                , Ship_To_City__c
                , Ship_to_State__c
                , Ship_to_Country__c
                , Shipping_Agent_Code_Courier__c
                , Shipping_Agent_Service_Code_Priority__c
                , External_Document_Number__c
                , Salesperson_Code__c
                , Event_Start_Date__c
                , Residential_Delivery__c
                , Venue_Code__c
                , Add_Freight_Line__c
                , BC_Sync_Status__c
                , BC_Synced__c
                , IncoTerms__c
                , Shipping_Cost_Payment_Type__c
                , Shipping_Payment_Account_No__c
                , Payment_Country_code__c
                , Duty_Payment_Type__c
                , Duty_Payment_Account_No__c
                , Duty_Payment_Post_Code__c
                , Duty_Payment_Country_code__c
                , EEI_ITN__c
                , Customs_Broker_Type__c
                , Commercial_Inv_Letterhead__c
                , Commercial_Inv_Signature__c
                , Dropship__c
                , Dropship_Category_Code__c
                , Dropship_Bill_to__r.Account_No__c
                , Dropship_Bill_to__r.Name
                , Dropship_Location_Code__c
                , Tax_Area_Code__c
                , Ship_To_Email_1__c
                , Ship_To_Email_2__c
                , BC_Currency_Code__c
                , Vat_Bus_Posting_Group__c
                , (SELECT
                    Name
                    , Product2.Name
                    , ProductCode
                    , Quantity
                    , UnitPrice
                    , Line_Discount__c
                    , Line_Discount_Amount__c
                    , BC_Sync_Status__c
                    , BC_Synced_Instances__c
                    , Product2.Dropship_Only__c
                   FROM OpportunityLineItems
                   WHERE BC_Sync_Status__c != :statusSynced)
            FROM Opportunity
            WHERE Id IN :setOppIds
        ];
    }
}