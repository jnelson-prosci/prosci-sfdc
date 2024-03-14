@isTest
public with sharing class BusinessHoursServiceTest {

    @isTest
    private static void test_hours_calculation_within_day() {

        Datetime testStartTime = Datetime.newInstance(2023, 05, 01, 7, 30, 0);
        Datetime testEndTime = Datetime.newInstance(2023, 05, 01, 9, 30, 0);
        List<Datetime> startEndTimes = new List<Datetime>{testStartTime, testEndTime};
        List<List<Datetime>> testStartEndTimes = new List<List<Datetime>>{startEndTimes};

        Test.startTest();

        List<Decimal> resultCalculatedBusinessHours = BusinessHoursService.calculateBusinessHours(testStartEndTimes);

        Test.stopTest();

        Assert.areEqual(2, resultCalculatedBusinessHours[0], 'The result number of business hours should be 2');
    }

    @isTest
    private static void test_hours_calculation_over_days() {

        Datetime testStartTime = Datetime.newInstance(2023, 05, 01, 7, 30, 0);
        Datetime testEndTime = Datetime.newInstance(2023, 05, 02, 9, 30, 0);
        List<Datetime> startEndTimes = new List<Datetime>{testStartTime, testEndTime};
        List<List<Datetime>> testStartEndTimes = new List<List<Datetime>>{startEndTimes};

        Test.startTest();

        List<Decimal> resultCalculatedBusinessHours = BusinessHoursService.calculateBusinessHours(testStartEndTimes);

        Test.stopTest();

        Assert.areEqual(11, resultCalculatedBusinessHours[0], 'The result number of business hours should be 11');
    }

    @isTest
    private static void test_hours_calculation_over_a_weekend() {

        Datetime testStartTime = Datetime.newInstance(2023, 04, 28, 13, 00, 0);
        Datetime testEndTime = Datetime.newInstance(2023, 05, 01, 10, 00, 0);
        List<Datetime> startEndTimes = new List<Datetime>{testStartTime, testEndTime};
        List<List<Datetime>> testStartEndTimes = new List<List<Datetime>>{startEndTimes};

        Test.startTest();

        List<Decimal> resultCalculatedBusinessHours = BusinessHoursService.calculateBusinessHours(testStartEndTimes);

        Test.stopTest();

        Assert.areEqual(3.5, resultCalculatedBusinessHours[0], 'The result number of business hours should be 3.5');
    }


}