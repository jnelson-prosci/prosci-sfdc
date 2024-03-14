@isTest
private with sharing class StringUtilsTest {

    @isTest static void contains_StringDoesContain_returnTrue(){
        String inputString = 'AAAABBBBCCC';
        String subString = 'BB';

        Test.startTest();

        Boolean res = StringUtils.contains(inputString, subString);

        Test.stopTest();

        System.assert(res, 'Test string contains substring and should return true');
    }

    @isTest static void contains_StringDoesNotContain_returnFalse(){
        String inputString = 'AAAAAA';
        String subString = 'XXXXX';

        Test.startTest();

        Boolean res = StringUtils.contains(inputString, subString);

        Test.stopTest();

        System.assert(!res, 'Test string does not contain substring and should return false');
    }

    @isTest static void contains_nullString_returnFalse(){
        String inputString = null;
        String subString = 'XXXXX';

        Test.startTest();

        Boolean res = StringUtils.contains(inputString, subString);

        Test.stopTest();

        System.assert(!res, 'Null Test string should return false');
    }

    @isTest static void doesNotContain_StringDoesContain_returnFalse(){
        String inputString = 'AAAABBBBCCC';
        String subString = 'BB';

        Test.startTest();

        Boolean res = StringUtils.doesNotContain(inputString, subString);

        Test.stopTest();

        System.assert(!res, 'Test string contains substring and should return false');
    }

    @isTest static void doesNotContain_StringDoesNotContain_returnTrue(){
        String inputString = 'AAAAAA';
        String subString = 'XXXXX';

        Test.startTest();

        Boolean res = StringUtils.doesNotContain(inputString, subString);

        Test.stopTest();

        System.assert(res, 'Test string does not contain substring and should return true');
    }

    @isTest static void doesNotContain_nullString_returnTrue(){
        String inputString = null;
        String subString = 'XXXXX';

        Test.startTest();

        Boolean res = StringUtils.doesNotContain(inputString, subString);

        Test.stopTest();

        System.assert(res, 'Null Test string should return true');
    }

    @isTest 
    private static void addNullMultiSelectPicklistValueTest(){
        String strCurrentValue = null;
        String strNewValue = 'TestString01';
        String testString;

        Test.startTest();

        testString = StringUtils.addMultiSelectPicklistValue(strCurrentValue, strNewValue); 

        Test.stopTest();

        system.assertEquals('TestString01', testString);

    }

    @isTest 
    private static void addValidMultiSelectPicklistValueTest(){
        String strCurrentValue = 'TestString01;TestString02';
        String strNewValue = 'TestString03';
        String testString;

        Test.startTest();

        testString = StringUtils.addMultiSelectPicklistValue(strCurrentValue, strNewValue); 

        Test.stopTest();

        system.assertEquals('TestString01;TestString02;TestString03', testString);

    }

    @isTest 
    private static void addValidDuplicateMultiSelectPicklistValueTest(){
        String strCurrentValue = 'TestString01;TestString02';
        String strNewValue = 'TestString01';
        String testString;

        Test.startTest();

        testString = StringUtils.addMultiSelectPicklistValue(strCurrentValue, strNewValue); 

        Test.stopTest();

        system.assertEquals('TestString01;TestString02', testString);

    }

    @isTest 
    private static void addMultipleValidMultiSelectPicklistValueTest(){
        String strCurrentValue = 'TestString01';
        String strNewValue = 'TestString02;TestString03';
        String testString;

        Test.startTest();

        testString = StringUtils.addMultiSelectPicklistValue(strCurrentValue, strNewValue); 

        Test.stopTest();

        system.assertEquals('TestString01;TestString02;TestString03', testString);

    }

}