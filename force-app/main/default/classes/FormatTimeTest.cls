@isTest
public class FormatTimeTest {

    @isTest
    private static void test_formatted_time_null() {
        
        Time t = null;
        
        Test.startTest();
        String actualTime = new FormatTime(t).getFormattedTime();
        Test.stopTest();
        
        Assert.areEqual('', actualTime);
    }
    
    @isTest
    private static void test_formatted_time_not_null() {
        
        Time t1 = Time.newInstance(16, 30, 00, 00);
        Time t2 = Time.newInstance(11, 30, 00, 00);
        Time t3 = Time.newInstance(23, 00, 00, 00);
        Time t4 = Time.newInstance(00, 00, 00, 00);
        
        Test.startTest();
        String actualTime1 = new FormatTime(t1).getFormattedTime();
        String actualTime2 = new FormatTime(t2).getFormattedTime();
        String actualTime3 = new FormatTime(t3).getFormattedTime();
        String actualTime4 = new FormatTime(t4).getFormattedTime();
        Test.stopTest();
        
        Assert.areEqual('4:30 PM', actualTime1);
        Assert.areEqual('11:30 AM', actualTime2);
        Assert.areEqual('11:00 PM', actualTime3);
        Assert.areEqual('12:00 AM', actualTime4);

    }
}