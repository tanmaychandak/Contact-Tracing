public with sharing class CTStatusUpdateSchedule implements Schedulable{
    //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    public static final String CRON = '0 21 13 * * ?';
    
    public void execute(SchedulableContext sc){
        CTUpdatePersonStatusBatch personBatch = new CTUpdatePersonStatusBatch();
        Database.executeBatch(personBatch, 2000);

        CTUpdateLocationStatusBatch locationBatch = new CTUpdateLocationStatusBatch();
        Database.executeBatch(locationBatch, 2000);
    }
}