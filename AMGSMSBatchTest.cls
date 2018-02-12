/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

@isTest(SeeAllData=true) 
private class AMGSMSBatchTest {
    static testMethod void myUnitTest() {
    	
    	test.startTest();
    	
    	Test.setMock(HttpCalloutMock.class, new nfsms.NotiFireClientHTTPMockTest());
    	
    	//SELECT Id, OwnerId, Subject, ActivityDate, StartDateTime, WhoId, Phone_for_Reminder__c, ReminderMessage__c, AMGSMSSent__c FROM 
    	// Event WHERE StartDateTime <: d AND AMGSMSSent__c = false AND Subject = 'SMS Reminder'
    	
    	Event e = new Event();
    	e.Subject = 'SMS Reminder';
    	e.StartDateTime = System.now().addHours(-1);
    	e.EndDateTime = System.now();
    	e.Phone_for_Reminder__c = '50050050000';
    	e.AMGSMSSent__c = false;
    	
    	insert e;
    	
    	Id batchJobId = Database.executeBatch(new AMGSMSBatch(), 1);
    	
    	test.stopTest();
    }
}