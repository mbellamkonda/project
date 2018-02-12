/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

global class AMGSMSScheduler implements Schedulable{
    global AMGSMSScheduler (){}

	// MANUAL RUN AMGSMSScheduler.start()
	
    public static void start(){
    	if(Test.isRunningTest()) { 
        	System.schedule('AMGSMSHourlyTest', '0 0 * * * ?', new AMGSMSScheduler());
    	} else {
    		System.schedule('AMGSMSHourly', '0 0 * * * ?', new AMGSMSScheduler());
    	}
    }

    global void execute(SchedulableContext ctx){
        AMGSMSBatch b = new AMGSMSBatch();
        database.executebatch(b, 1);    
    }
}