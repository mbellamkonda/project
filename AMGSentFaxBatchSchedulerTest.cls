/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */
 
@isTest
private class AMGSentFaxBatchSchedulerTest {

    static testMethod void myUnitTest() {
        test.startTest();
        
        AMGSentFaxBatchScheduler.start();
		
		test.stopTest();
    }
}