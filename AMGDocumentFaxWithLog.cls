/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

public class AMGDocumentFaxWithLog {    
    public static void sendFaxAndLog(AMGDocumentFax fax, Id whoId, Id whatId, Id sentToId, List<String> sentFileNames, String toNumber) {
    	// Send the fax and capture result
    	FaxcomAPI.ResultMessage result = fax.sendFax();
    	// Grab Faxcom UniqueJobID from result
    	String faxcomUniqueId = result.Data;
    	
    	AMGDocumentFaxWithLog.sendFaxAndLog(faxcomUniqueId, whoId, whatId, sentToId, sentFileNames, toNumber);
    }
    
    // Param Id - whoId ID of object the task should be associated with WHOID.
    // Param Id - whatId ID of object the task should be associated with WHATID.
    // Param List<String> - sentFileNames a List of Strings containing the Form Names that were sent in the Fax.
    public static void sendFaxAndLog(String faxcomUniqueId, Id whoId, Id whatId, Id sentToId, List<String> sentFileNames, String toNumber) {
    	Map<String,String> acctRtToTaskRt = new Map<String,String>{
    								'01246000000QXnRAAW'=>'01246000000YzSCAA0', 
									'01246000000YztEAAS'=>'01246000000YzSCAA0', 
									'01246000000Yzt9AAC'=>'01246000000YzSCAA0', 
									'01246000000Q1gFAAS'=>'01246000000Z0T2AAK',
									'01246000000Q1g5AAC'=>'01246000000Yzs1AAC'
		};
		
		whoId = AMGUtilities.ID15to18(whoId);
		whatId = AMGUtilities.ID15to18(whatId);
		sentToId = AMGUtilities.ID15to18(sentToId);
		
    	// Build Task
    	Task t = new Task();
		t.WhoId = whoId;
    	t.Type = 'Facsimile';
		t.Status = 'Fax Pending';
		t.Call_Outcome__c = 'Scheduled';
		// Set the FaxcomUniqueID field so the batch process can lookup fax status info.
		t.FaxcomUniqueID__c = faxcomUniqueId;
		t.ActivityDate = System.today();
		t.Call_Type__c = 'Outbound';
		t.Communication_Method__c = 'Fax';
		
		String toObjectType = AMGDocumentFaxWithLog.findObjectAPIName(whatId);
		
		//System.debug('******** ' + toObjectType);
		
		if(toObjectType == 'Account') {
			Account a = [SELECT id, Name, RecordType.Name FROM Account WHERE Id =: whatId LIMIT 1];
			// If sent to All-Care On-Site Pharmacy
			if(sentToId == '0014600000YAh7QAAT' /*|| sentToId == '0013D000002wTP0QAM'*/){
				t.RecordTypeId = '01246000000Z0TRAA0';
				// Set Task Subject Based on Rules
				t.Subject = 'Fax Sent to AllCare Pharmacy ' + toNumber;
			} else {
				// Set Task Record Type Based on Rules
				t.RecordTypeId = acctRtToTaskRt.get(AMGUtilities.ID15to18(a.RecordTypeId));
				// Set Task Subject Based on Rules
				if(t.RecordTypeId == null) {
					t.Subject = 'Fax Sent to ' + toNumber;
				} else {
					t.Subject = 'Fax Sent to ' + a.RecordType.Name + ' ' + a.Name + ' ' + toNumber;
				}
			}
			t.Fax_Sent_to__c = sentToId;
			t.WhatId = whatId;
			
		} else if(toObjectType == 'Case') {
			Case c = [SELECT id, Account.Name, Account.Id, Account.RecordTypeId, Account.RecordType.Name FROM Case WHERE Id =: whatId LIMIT 1];
			
			Account a;
			try { a = [SELECT id, Name, RecordType.Name FROM Account WHERE Id =: sentToId LIMIT 1]; } catch (exception e) { }
			
			if(sentToId == '0014600000YAh7QAAT' /*|| sentToId == '0013D000002wTP0QAM'*/){
				t.RecordTypeId = '01246000000Z0TRAA0';
				// Set Task Subject Based on Rules
				t.Subject = 'Fax Sent to AllCare Pharmacy ' + toNumber;
			} else {
				// Set Task Record Type Based on Rules
				t.RecordTypeId = acctRtToTaskRt.get(AMGUtilities.ID15to18(c.Account.RecordTypeId));
				// Set Task Subject Based on Rules
				if(t.RecordTypeId != null && a != null) {
					t.Subject = 'Fax Sent to ' + a.RecordType.Name + ' ' + a.Name + ' ' + toNumber;
				} else {
					t.Subject = 'Fax Sent to ' + toNumber;
				}
			}
			
			// Set Task Record Type Based on Rules
			t.Fax_Sent_to__c = sentToId;
			t.WhatId = whatId;

		} else if(toObjectType == 'Contact') {
			t.RecordTypeId = '01246000000YzrwAAC';
			// Set Task Subject Based on Rules
			t.Subject = 'Fax Sent to ' + toNumber;
		} else { // "Other" fax option
			t.RecordTypeId = '01246000000YyrVAAS';
			t.Subject = 'Fax Sent to ' + toNumber;
		}
		
		t.Description = 'Files Sent By Fax:\n';
		// Append sentFileNames to Task Comments
		for(String s : sentFileNames){
			t.Description += '\n' + s;
		}
		
		//System.debug('Inserting: ' + JSON.serialize(t));
		
		insert t;
    }
    
    public static String findObjectAPIName(String recordId){
    	if(recordId == null) return null;
    	String objectAPIName = '';
    	String keyPrefix = recordId.substring(0,3);
    	for(Schema.SObjectType obj : Schema.getGlobalDescribe().Values()){
    		String prefix = obj.getDescribe().getKeyPrefix();
    		if(prefix == keyPrefix){
    			objectAPIName = obj.getDescribe().getName();
    			break;
    		}
    	}
    	return objectAPIName;
    }
}