/**
 * @author CloudMasonry
 * @date 2024
 * @group Filter
 * @description Filters ContentVersion Records for processing by ContentVersionRedlinesReturnedService
 */
public with sharing class ContentVersionRedlinesReturnedFilter {

    @testVisible
    private static final String Title_Redlines_Return = 'Redlines Returned';

    public List<ContentVersion> filterRecords(List<ContentVersion> lstNewRecords) {
        List<ContentVersion> filteredContentVersions = new List<ContentVersion>();
        
        for (ContentVersion cv : lstNewRecords) {

            if (cv.Title != null && cv.Title.contains(Title_Redlines_Return)) {
                   filteredContentVersions.add(cv);
            }
        }
        
        return filteredContentVersions;
    }
}