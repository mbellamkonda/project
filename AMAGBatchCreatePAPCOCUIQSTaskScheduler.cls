global class AMAGBatchCreatePAPCOCUIQSTaskScheduler implements Schedulable{
  
    global void execute(SchedulableContext ctx){
        AMAGBatchCreatePAPCOCUIQSTask b = new AMAGBatchCreatePAPCOCUIQSTask();
        database.executebatch(b);    
    }
}