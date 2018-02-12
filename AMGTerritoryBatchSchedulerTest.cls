/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */
 
@isTest
private class AMGTerritoryBatchSchedulerTest {

    static testMethod void myUnitTest() {
        test.startTest();
        
        AMGTerritoryBatchScheduler.start();
		
		test.stopTest();
    }
}