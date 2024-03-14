/**
 * A trigger handler framework to facilitate implementation of lightweight and easily testable object specific trigger
 * handlers. To implement an object specific trigger:
 * - Create a new Apex class called {SObject}TriggerHandler eg. AccountTriggerHandler which extends TriggerHandler
 * - Define two class variables: (1) List<{SObject}> newRecords (2) Map<Id, {SObject}> oldMap
 * - Create a Constructor accepting two parameters: (1) List<{SObject}> newRecords (2) Map<Id, {SObject}> oldMap and assigm
 *   to respective class variables
 * - Override event methods as needed and call business logic from overridden method
 * - Create Object Trigger
 * - In Object Trigger add single line: new {SObject}TriggerHandler().execute();
 */
public virtual with sharing class TriggerHandler {

    private static Trigger_Management__c triggerManagement {
        get {
            if(triggerManagement == null){
                triggerManagement = Trigger_Management__c.getInstance();
            }
            return triggerManagement;
        }
        set;
    }

    private static Set<String> triggerManagementFields {
        get {
            if(triggerManagementFields == null){
                triggerManagementFields = Schema.SObjectType.Trigger_Management__c.fields.getMap().keySet();
            }
            return triggerManagementFields;
        }
        set;
    }

    public void execute(){
        if(!byPassTrigger()){
            executeOperationType(Trigger.operationType);
        }
    }

    /**
     * A router method to invoke the appropriate event method depending on the Trigger Context's System.TriggerOperation enum
     * @param  operationType System.TriggerOperation Enum value from Trigger Context
     */
    @testVisible
    private void executeOperationType(System.TriggerOperation operationType){
        switch on operationType {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
            when else {
                throw new TriggerException('Undefined trigger operation');
            }
        }
    }

    protected virtual void beforeInsert(){}

    protected virtual void afterInsert(){}

    protected virtual void beforeUpdate(){}

    protected virtual void afterUpdate(){}

    protected virtual void beforeDelete(){}

    protected virtual void afterDelete(){}

    protected virtual void afterUndelete(){}
    
    @testVisible
    private Boolean byPassTrigger(){
        String strByPassFieldName = (this.toString().split(':')[0].replace('TriggerHandler','') + '__c').toLowerCase();
        if(triggerManagement != null && triggerManagementFields.contains(strByPassFieldName)){
            return (Boolean)triggerManagement.get(strByPassFieldName) == true;
        }
        return false;
    }
    
    public class TriggerException extends Exception {}
}