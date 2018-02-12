/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

global class AMGSentFaxBatch implements Database.Batchable<Task>, Database.AllowsCallouts {
	Map<Integer,String> statusCodeToExplanation = new Map<Integer,String>{
		0 => 'All pages were successfully transmitted.',
		1 => 'Lost communication with called fax machine.',
		2 => 'Received page quality deemed unacceptable by fax machine.',
		3 => 'FAXCOM unable to transmit due to noisy phone connection.',
		4 => 'FAXCOM detected voice answer.',
		5 => 'Early disconnect. Remote fax requested a disconnect before image was transmitted.',
		6 => 'Late disconnect; remote fax machine requested a disconnect after image was transmitted.',
		7 => 'No dial tone detected.',
		8 => 'FAXCOM reset during transmission.',
		13 => 'Called fax machine busy.',
		14 => 'Phone network busy.',
		15 => 'Called phone number ringing but no answer.',
		16 => 'Incompatible Group I fax machine detected.',
		17 => 'Incompatible Group II fax machine detected.',
		18 => 'Unknown modem. A modem answer tone was detected, but it is not a fax modem.',
		21 => 'No destination phone number specified.',
		50 => 'After dialing, no telephone network response.',
		671 => 'Error converting attachment to fax format.',
		8000 => 'This job was manually deleted.'
	};
	
	
	// MANUAL RUN Id batchJobId = Database.executeBatch(new AMGSentFaxBatch(), 1);

	//Get list of Tasks to check Fax Status for.
	List<Task> el = [SELECT Id, OwnerId, Status, Subject, Description, Call_Outcome__c, FaxcomUniqueID__c, Fax_Sent_to__c, WhatId, WhoId FROM Task WHERE Type = 'Facsimile' AND Status = 'Fax Pending'];
	
	global Iterable<Task> start(database.batchablecontext BC){
	    return (el);
	}
	
	global void execute(Database.BatchableContext BC, List<Task> scope){
	    for(Task t : scope){
	    	// For each Task Query Faxcom for Fax Status
	    	//String status = AMGSentFaxBatch.getFaxStatus(t.FaxcomUniqueID__c);
	    	
	    	String url;
	    	String username;
	    	String password;
			
			if(!Test.isRunningTest()) {
				Outbound_Fax_Settings__c settings = [SELECT Endpoint__c,Username__c,Password__c FROM Outbound_Fax_Settings__c WHERE Name = 'Faxcom Live'];
		    	url = settings.Endpoint__c;
		    	username = settings.Username__c;
		    	password = settings.Password__c;
			} else {
				url = 'http://faxcom.acuitymg.com/FAXCOM_WS/FAXCOMService.asmx';
		    	username = 'webuser';
		    	password = 'amg123';
			}
	    	
	    	FaxcomAPI faxcom = new FaxcomAPI(url);
	    	FaxcomAPI.MessageStatus status;
	        
	        if(!Test.isRunningTest()) {
		        faxcom.LogIn(username, password);
		        status = faxcom.GetMessageStatusByIDTag(t.FaxcomUniqueID__c);
		        faxcom.ReleaseSession();
	        } else {
	        	FaxcomWS.MessageStatus ms = new FaxcomWS.MessageStatus();
	        	ms.TransmissionStatus = 8000;
	        	status = new FaxcomAPI.MessageStatus(ms);
	        }
	        if(status != null) {
		        System.debug('FAXCOM STATUS CODE: ' + status.TransmissionStatus + ' Explanation: ' + statusCodeToExplanation.get(status.TransmissionStatus));
		    	
		    	// Assign Task field values based on Rules
		    	if(status.TransmissionStatus == 0) {
		    		// If Status is Successful
		    		t.Status = 'Communication Successful';
					t.Call_Outcome__c = 'Fax Sent';
					
					update t;
		    	} else {
		    		// If Status is Successful
		    		t.Status = 'Unable to Complete';
					t.Call_Outcome__c = 'Fax/data/modem';
					t.Description += '\n\n\nError Code: ( ' + status.TransmissionStatus + ' ) Explanation: ' + statusCodeToExplanation.get(status.TransmissionStatus);
					
					update t;
					
					Task ft = new Task();
					ft.RecordTypeID = '01246000000YyrVAAS';
					ft.Status = 'Followup Action';
					ft.Subject = 'Fax Transmission Failure to ' + t.Subject.replace('Fax Sent to','');
					//ft.OwnerID = [SELECT ManagerId FROM User WHERE Id=: t.OwnerId LIMIT 1].ManagerId;
					ft.OwnerID = t.OwnerId;
					ft.ActivityDate = System.today();
					ft.IsReminderset = true;
					ft.ReminderDateTime = System.now();
					ft.Fax_Sent_to__c = t.Fax_Sent_to__c;
					//ft.Priority = 'High';
					ft.WhoId = t.WhoId;
					ft.WhatId = t.WhatId;
					ft.Description = t.Description;
					
					insert ft;
		    	}
	        }
	    }
	}
	
	global void finish(Database.BatchableContext info){
	
	}//global void finish loop

	@future 
	global static void getFaxStatus(String faxcomUniqueId) {
        
	}
}