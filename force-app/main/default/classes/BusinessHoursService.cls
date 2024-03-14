public with sharing class BusinessHoursService {

    @InvocableMethod(label='Calculate Business Hours' description='Takes a start time and an end time and calculates the business hours between them.')
    public static List<Decimal> calculateBusinessHours(List<List<Datetime>> startEndTimes) {

        List<Decimal> calculatedBusinessHours = new List<Decimal>();

        BusinessHours bizHoursRecord = [SELECT Id FROM BusinessHours WHERE IsDefault = true AND Name = 'US Business Hours'];

        for (List<Datetime> startEndTimesList : startEndTimes) {

            startEndTimesList.sort();

            Datetime startDate = startEndTimesList.get(0); 
            Datetime endDate = startEndTimesList.get(1); 

            Long bizHoursInMS = BusinessHours.diff((String)bizHoursRecord.Id, startDate, endDate);

            Decimal bizHours = bizHoursInMS / Decimal.valueOf(1000 * 60 * 60);

            Decimal bizHoursScaled = bizHours.setscale(2);

            calculatedBusinessHours.add(bizHoursScaled);
        }

        return calculatedBusinessHours;
    }
}