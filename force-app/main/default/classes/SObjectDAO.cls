public with sharing class SObjectDAO {

    private List<SObject> lstSObjs;
    @testVisible
    private List<Database.SaveResult> lstSaveResult;

    public List<SObject> insertRecords(List<SObject> lstSObjs){
        Database.insert(lstSObjs, true);
        return lstSObjs;
    }

    public List<SObject> updateRecords(List<SObject> lstSObjs){

        return updateRecords(lstSObjs, true, false, null);
    }

    public List<SObject> updateRecordsAllowPartialSuccess(List<SObject> lstSObjs){

        return updateRecords(lstSObjs, false, false, null);
    }

    public List<SObject> updateRecordsAndLogErrors(List<SObject> lstSObjs, String strErrorCategory){

        return updateRecords(lstSObjs, false, true, strErrorCategory);
    }

    public List<SObject> updateRecords(List<SObject> lstSObjs, Boolean allOrNone, Boolean logErrors, String strErrorCategory){

        this.lstSObjs = lstSObjs;
        this.lstSaveResult = Database.update(lstSObjs, allOrNone);
        
        if(logErrors){
            logSaveResultErrors(strErrorCategory);
        }

        return lstSObjs;
    }

    public List<Database.SaveResult> getSaveResult(){
        return this.lstSaveResult;
    }

    public void logSaveResultErrors(String strErrorCategory){
        List<Error_Log__c> lstErrorLogs = new List<Error_Log__c>();

        if(this.lstSaveResult != null){

            for(Integer i=0; i < this.lstSaveResult.size(); i++){
                
                Database.SaveResult sr = this.lstSaveResult[i];
                SObject sObj = this.lstSObjs[i];

                if(!sr.isSuccess()){

                    String strErrorMsgs = '';
                    for(Database.Error err : sr.getErrors()){
                        strErrorMsgs += err.getStatusCode() + ': ' + err.getMessage() + '\r\n';
                    }
                    Error_Log__c errorLog = new Error_Log__c(
                        Associated_Records__c = sObj.Id
                        , Exception_Type__c = new DmlException().getTypeName()
                        , Category__c = strErrorCategory
                        , Error_Message__c = strErrorMsgs
                    );
                    lstErrorLogs.add(errorLog);
                }
            }
            if(!lstErrorLogs.isEmpty()){
                insert lstErrorLogs;
            }
        }
    }

}