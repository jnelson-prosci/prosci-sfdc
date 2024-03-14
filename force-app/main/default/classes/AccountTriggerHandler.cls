/**
 * Account Trigger Handler to orchestrate business logic on Account CRUD operations
 */
public with sharing class AccountTriggerHandler extends TriggerHandler {

    private List<Account> lstNewRecords;
    private Map<Id, Account> mapOldRecords;

    @testVisible
    public static Boolean byPass = false;

    public AccountTriggerHandler(List<Account> lstNewRecords, Map<Id, Account> mapOldRecords) {
        this.lstNewRecords = lstNewRecords;
        this.mapOldRecords = mapOldRecords;
    }

    protected override void afterUpdate() {
        if (byPass) { return; }

        new AccountBCSyncEnqueuer().enqueue(
            new AccountBCSyncFilter().filterRecords(lstNewRecords, mapOldRecords));

    }
}