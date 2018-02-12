/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

global class AMGTerritoryBatchScheduler implements Schedulable{
    global AMGTerritoryBatchScheduler (){}

	// MANUAL RUN AMGTerritoryBatchScheduler.start()
	
    public static void start(){
    	if(Test.isRunningTest()) { 
        	System.schedule('AMGTerritoryHourlyTest', '0 0 * * * ?', new AMGTerritoryBatchScheduler());
    	} else {
    		System.schedule('AMGTerritoryHourly', '0 0 * * * ?', new AMGTerritoryBatchScheduler());
    	}
    }

    global void execute(SchedulableContext ctx){
        AMGTerritoryMapperBatch b = new AMGTerritoryMapperBatch();
        database.executebatch(b, 1);    
    }
}