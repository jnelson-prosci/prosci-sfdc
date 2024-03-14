public with sharing class StringUtils {
    
    public static Boolean contains(String inputString, String subString){
        return inputString != null && inputString.contains(subString);
    }

    public static Boolean doesNotContain(String inputString, String subString){
        return !contains(inputString, subString);
    }

    public static String addMultiSelectPicklistValue(String currentValue, String newValue) { 
        Set<String> uniqueSplitValues = new Set<String>();
        List<String> splitValues = new List<String>();
        if (newValue != null) {
            splitValues = newValue.split(';');
        
        }
        if(currentValue != null){
            
            splitValues.addAll(currentValue.split(';'));
        }
        
        uniqueSplitValues.addAll(splitValues);
        splitValues.clear();
        splitValues.addAll(uniqueSplitValues);
        splitValues.sort();
        
        newValue = String.join(splitValues, ';');
        
        return newValue;
    } 
}