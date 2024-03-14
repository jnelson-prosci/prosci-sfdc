public with sharing class BCSyncUtils {

    public static Map<String, Object> buildRequestBody(SObject sObj, Object obj, List<BC_Integration_Mapping__mdt> lstFieldMappings, Boolean isInsert){ 
        //  convert object to Map<String, Object> and add in field mapping values. 
        Map<String, Object> mapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
        if (lstFieldMappings != null) {
            
            for(BC_Integration_Mapping__mdt fieldMapping : lstFieldMappings){
                if(fieldMapping.Insert_Only__c && !isInsert){
                    continue;
                }
                mapObject.put(fieldMapping.Json_Key__c, sObj.get(fieldMapping.Field_Api_Name__c));
            }
        }
        return mapObject;
    }

}