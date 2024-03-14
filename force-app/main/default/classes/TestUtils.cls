@isTest
public with sharing class TestUtils {

    public static User ADMIN_USER {
        get { 
            if(ADMIN_USER == null){
                ADMIN_USER = [SELECT Id
                              FROM User
                              WHERE Profile.PermissionsModifyAllData = true
                              AND IsActive = true
                              LIMIT 1];
            }
            return ADMIN_USER;
        }
        set;
    }

    private static Integer dummyIdCount = 0;
    private static final String ID_PATTERN = '000000000000';

    public String generateDummyId(SObjectType sObjType){
        String keyPrefix = sObjType.getDescribe().getKeyPrefix();
        Id dummyId = Id.valueOf(keyPrefix + ID_PATTERN.substring(0, 12 - dummyIdCount.format().length()) + dummyIdCount);
        dummyIdCount++;
        return dummyId;
    }

    public String generateDummyId(SObject sObj){
        return generateDummyId(sObj.getSObjectType());
    }

}