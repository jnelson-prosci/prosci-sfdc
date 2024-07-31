/**
* @author William Chu (Slalom)
* @date 7/19/24
* @description Batchable to invalidate emails in Sandbox
**/
public class SandboxPostRefreshInvalidateEmailsBatch implements Database.Batchable<SObject> {

    // Add objects to this list to invalidate emails
    public static final List<String> OBJECT_NAMES = new List<String>{
        'Account',
        'Associated_Training_Contacts__c',
        'Contact',
        'Lead',
        'Portal_Access__c'
    };

    // The object name to query for and replace emails for
    public String currentObjectName;

    public SandboxPostRefreshInvalidateEmailsBatch() {
        // Start with the first object
        this.currentObjectName = OBJECT_NAMES[0];
    }

    // Constructor to accept object name to process job for
    public SandboxPostRefreshInvalidateEmailsBatch(String objectName) {
        this.currentObjectName = objectName;
    }

    // Query for all email fields for the object
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Return the query
        return Database.getQueryLocator(getQuery());
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        for (SObject record :scope) {

            // Iterate over each email field
            for (String emailField :getEmailFieldsForObject()) {

                // Only process not null fields
                if (record.get(emailField) != null) {

                    // Retrieve the email value and append .invalid
                    String emailValue = String.valueOf(record.get(emailField));
                    if(!emailValue.endsWith('.invalid')) {
                        emailValue = emailValue + '.invalid';
                    }

                    // Put back into the field
                    record.put(emailField, emailValue);
                }
            }
        }

        Database.SaveResult[] srList = Database.update(scope, false);

        Map<Id,String> failedIdsMap = new Map<Id,String>();

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, do nothing
            }
            else {
                System.debug('Invalidate Email Post Refresh Failure ' + this.currentObjectName + ' Id: ' + sr.getId());
                // Operation failed, so get all errors 
                String srErrors;               
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                    srErrors = err.getStatusCode() + ': ' + err.getMessage() + err.getFields();
                }
                failedIdsMap.put(sr.getId(), srErrors);
            }
        }

        List<Case> failureCases = new List<Case>();

        if (!failedIdsMap.isEmpty()) {
            for (Id key : failedIdsMap.keySet()) {
                Case failureCase = new Case(
                    Subject = '(' + key + ') ' + this.currentObjectName + ' Invalidate Email Post Refresh Failure',
                    Origin = 'Salesforce',
                    Description = failedIdsMap.get(key)
                );

                failureCases.add(failureCase);
            }

    
            insert failureCases;
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Run on the next object if present
        if (getNextObject() != null) {
            Database.executeBatch(new SandboxPostRefreshInvalidateEmailsBatch(getNextObject()));
        }
    }

    // Retrieve the query for the specific object
    public String getQuery() {
        List<String> allFields = new List<String>();
        allFields.addAll(getEmailFieldsForObject());
        return 'SELECT ' + String.join(allFields, ',') + ' FROM ' + currentObjectName;
    }

    // Return the email fields for the object
    public List<String> getEmailFieldsForObject() {
        List<String> emailFields = new List<String>();

        // Iterate over the fields on the object to retrieve the email fields
        for (Schema.SObjectField field :Schema.getGlobalDescribe().get(currentObjectName).getDescribe().fields.getMap().values()) {
            // If an email field or name contains email and is a Text field
            if (field.getDescribe().isUpdateable() &&
                    (field.getDescribe().getType() == Schema.DisplayType.Email ||
                            (
                                field.getDescribe().getName().containsIgnoreCase('email') &&
                                (
                                    field.getDescribe().getType() == Schema.DisplayType.String ||
                                    field.getDescribe().getType() == Schema.DisplayType.TEXTAREA
                                )
                            )
                    )
            ){
                // Add the field
                emailFields.add(field.getDescribe().getName());
            }
        }
        return emailFields;
    }

    // Determine which object to do next
    public String getNextObject() {
        for (Integer i = 0; i < OBJECT_NAMES.size(); i++) {
            if (currentObjectName == OBJECT_NAMES[i]) {
                try {
                    return OBJECT_NAMES[i + 1];
                }
                catch (Exception ex) {}
            }
        }

        return null;
    }
}