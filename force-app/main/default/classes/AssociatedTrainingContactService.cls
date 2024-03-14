public with sharing class AssociatedTrainingContactService {

    @AuraEnabled
    public static List<Associated_Training_Contacts__c> getDataByTrainingEventId(Id trainingEventId){
        return [
            SELECT 
                Id, 
                Training_Event__c, 
                Name, 
                First_Name_Feedback__c, 
                Last_Name_Feedback__c, 
                Contact_Email_for_GetFeedback__c, 
                Account_Name__c, 
                Status__c, 
                Internal_Notes__c, 
                prework_task_status__c, 
                Project_Grouping__c, 
                Material_Opportunity__c, 
                Material_Opportunity__r.Name,
                Materials_Delivered__c,
                Contact__c,
                Order_No__c,
                Contact__r.AccountId
            FROM Associated_Training_Contacts__c
            WHERE Training_Event__c = :trainingEventId
        ];
    }

}