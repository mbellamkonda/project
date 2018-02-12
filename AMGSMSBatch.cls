/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

global class AMGSMSBatch implements Database.Batchable<Event>, Database.AllowsCallouts {

	// MANUAL RUN Id batchJobId = Database.executeBatch(new AMGSMSBatch(), 1);

	//Get list of Events to send reminders for.
	DateTime d = System.now().addHours(1);
	//.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
	List<Event> el = [SELECT Id, OwnerId, Subject, ActivityDate, StartDateTime, WhoId, Phone_for_Reminder__c, ReminderMessage__c, AMGSMSSent__c FROM Event WHERE StartDateTime <: d AND AMGSMSSent__c = false AND Subject = 'SMS Reminder'];
	
	global Iterable<Event> start(database.batchablecontext BC){
	    return (el);
	}
	
	global void execute(Database.BatchableContext BC, List<Event> scope){
	    for(Event e : scope){
	    	Boolean b = false;
    		// Send SMS
            System.debug('SENDING SMS TO: ' + e.Phone_for_Reminder__c + ' WITH MESSAGE: ' + e.ReminderMessage__c);
            nfsms.NotiFireClient nfc = new nfsms.NotiFireClient();
            if(!Test.isRunningTest()) { 
            	b = nfc.sendSMS(e.Phone_for_Reminder__c, e.ReminderMessage__c);
            }
            System.debug('RETURN VALUE FROM SEND SMS: ' + b);
            // If successfully sent mark checkbox on event & log SMS task
            if(b) {
            	e.AMGSMSSent__c = true;
            	update e;
            	
            	/*
            	Task t = new Task();
            	t.OwnerId = e.OwnerId;
            	t.WhoId = e.WhoId;
            	t.Subject = 'Outbound SMS: ' + e.ReminderMessage__c;
            	t.Type = 'SMS/Text';
            	t.Call_Type__c = 'Outbound';
            	t.Status = 'Closed';
            	t.ActivityDate = System.today();
            	insert t;
            	*/
            }
	    }
	}
	
	global void finish(Database.BatchableContext info){
	
	}//global void finish loop

}