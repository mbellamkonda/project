/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */
 
@isTest(SeeAllData=true) 
private class AMGReportExporterTest {

    static testMethod void myUnitTest() {
        test.startTest();
        
        AMGSingleRequestMock fakeResponse = new AMGSingleRequestMock(200,
                                                 'Complete',
                                                 Blob.valueOf('"Case_ID","Account_ID"\n"5003D000000hTfH","0013D000002vrQj"\n'),
                                                 null);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        AMGReportExporter re = new AMGReportExporter();
        re.testEmail = 'james@acuitymg.com';
        //re.execute(null);
        
        test.stopTest();
    }
}