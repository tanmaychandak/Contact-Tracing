public with sharing class CTDataCleanupSchedule implements Schedulable{
    //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    public static final String CRON = '0 40 12 * * ?';
    
    public void execute(SchedulableContext sc){
        CTPeopleTracingDataCleanupBatch peopleTracingBatch = new CTPeopleTracingDataCleanupBatch();
        Database.executeBatch(peopleTracingBatch, 2000);

        CTLocationTracingDataCleanupBatch locationTracingBatch = new CTLocationTracingDataCleanupBatch();
        Database.executeBatch(locationTracingBatch, 2000);
    }
}