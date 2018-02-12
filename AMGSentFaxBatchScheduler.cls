/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */
global class AMGSentFaxBatchScheduler implements Schedulable{
    global AMGSentFaxBatchScheduler (){}

	// MANUAL RUN AMGSentFaxBatchScheduler.start()
	
    public static void start(){
    	if(Test.isRunningTest()) { 
        	System.schedule('AMGSentFaxBatchHourlyTest', '0 0 * * * ?', new AMGSentFaxBatchScheduler());
    	} else {
    		System.schedule('AMGSentFaxBatchHourly', '0 0 * * * ?', new AMGSentFaxBatchScheduler());
    	}
    }

    global void execute(SchedulableContext ctx){
        AMGSentFaxBatch b = new AMGSentFaxBatch();
        database.executebatch(b, 1);
    }
}