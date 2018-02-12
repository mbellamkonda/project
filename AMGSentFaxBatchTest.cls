/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */
 
@isTest 
private class AMGSentFaxBatchTest {

    static testMethod void myUnitTest() {
        test.startTest();
        
        TerritoryReassignmentSettings__c settings = new TerritoryReassignmentSettings__c(
		    Name = 'Default',
		    BatchEmailsEnabled__c = true,
		    DebuggingEnabled__c = true,
		    ObjectOwnerProfileName__c = 'MCC Care Manager',
		    OwnerReassignmentEnabled__c = true,
		    TaskOwnerProfileName__c = 'MCC Adherence Manager',
		    TaskRecordTypeNames__c = 'Welcome Adherence Call,Continued Adherence Call',
		    TriggerEmailsEnabled__c = false
		);
		
		insert settings;
        
        User uA = new User(LastName='Apricot', Alias='Apricot', UserName = 'Apricot@Apricot.com.AMG2017TEST', Email='Apricot@Apricot.com',
        	IsActive = true, ProfileId = UserInfo.getProfileId(), TimeZoneSidKey = TimeZone.getTimeZone('America/New York').getID(),
        	LocaleSidKey = UserInfo.getLocale(), EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Title = 'Sales Rep');
        insert uA; 
        
        User uB = new User(LastName='Bananna', Alias='Bananna', UserName = 'Bananna@Bananna.com.AMG2017TEST', Email='Bananna@Bananna.com',
        	IsActive = true, ProfileId = UserInfo.getProfileId(), TimeZoneSidKey = TimeZone.getTimeZone('America/New York').getID(),
        	LocaleSidKey = UserInfo.getLocale(), EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', ManagerId = uA.Id, Title = 'Sales Rep');
        insert uB;
        
        MCC_Zone__c m = new MCC_Zone__c();
		m.Name = 'Test';
		
		insert m;
		
		Group g = new Group();
		g.Name = 'Test';
		g.Type = 'Queue';
		
		insert g;
		
		System.runAs(uA) {
			QueueSobject qs = new QueueSobject();
			qs.QueueId = g.Id;
			qs.SobjectType = 'Territory__c';
			
			insert qs;
		}
		
		System.runAs(uB) {
			GroupMember member = new GroupMember();
			member.UserOrGroupId = uB.Id;
			member.GroupId = g.Id;
			
			insert member;
		}
		
		Region__c r = new Region__c();
		r.Name = 'PA/NJ';
		
		insert r;
		
		Territory__c te = new Territory__c();
		te.Region__c = r.Id;
		te.OwnerId = g.Id;
		
		insert te;
		
		Zip_Code__c z = new Zip_Code__c();
		z.Name = '33426';
		z.Zip_Code__c = '33426';
		z.MCC_Zone__c = m.Id;
		z.Territories__c = te.Id;
		
		insert z;
			
		Account a = new Account();
		a.Name = 'Test';
		a.Address1__c = 'Address1';
		a.Address2__c = 'Address2';
		a.City__c = 'City';
		a.State__c = 'Ca';
		a.ZipCode__c = z.Id;
		a.RecordTypeId = '01246000000Q1g5AAC';
		
		insert a;
		
		Contact c = new Contact();
		c.LastName = 'Test';
		c.Consent_Received__c = 'Yes';
		c.AccountId = a.Id;
        
        insert c;
        
        
        Task t = new Task();
    	t.Type = 'Facsimile';
		t.Status = 'Fax Pending';
		t.Call_Outcome__c = 'Scheduled';
		// Set the FaxcomUniqueID field so the batch process can lookup fax status info.
		t.FaxcomUniqueID__c = 'valid-unique-test-idtag';
		t.ActivityDate = System.today();
		t.Call_Type__c = 'Outbound';
		t.Communication_Method__c = 'Fax';
		// Set Task Record Type Based on Rules
		t.RecordTypeId = '01246000000Yzs1AAC';
		t.Fax_Sent_to__c = a.Id;
		t.WhatId = a.Id;
		t.WhoId = c.Id;
		// Set Task Subject Based on Rules
		t.Subject = 'Fax Sent to ' + '8312527742';
		t.Description = 'Files Sent By Fax:\n';
		// Append sentFileNames to Task Comments
		t.Description = 'Files Sent By Fax:\n\nFile1\nFileTwo\n\n\n\nError Code: ( 8000 ) Explanation: This job was manually deleted.';
		t.OwnerId = uB.Id;
		
		insert t;
		
		test.stopTest();
		
		Test.setMock(WebServiceMock.class, new FaxcomWS_FailAfterN_MockImpl(2147483647));
		// ACTUAL TESTS

		Id batchJobId = Database.executeBatch(new AMGSentFaxBatch(), 1);
    }
}