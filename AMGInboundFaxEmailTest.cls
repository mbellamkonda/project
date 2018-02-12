/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */
 
@isTest 
private class AMGInboundFaxEmailTest {

	static testMethod void TestinBoundEmail()
	{
		test.startTest();
		
		Test.setMock(WebServiceMock.class, new FaxcomWS_FailAfterN_MockImpl(2147483647));
		
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
		
		Territory__c t = new Territory__c();
		t.Region__c = r.Id;
		t.OwnerId = g.Id;
		
		insert t;
		
		Zip_Code__c z = new Zip_Code__c();
		z.Name = '33426';
		z.Zip_Code__c = '33426';
		z.MCC_Zone__c = m.Id;
		z.Territories__c = t.Id;
		
		insert z;
			
		Account a = new Account();
		a.Name = 'Test';
		a.Address1__c = 'Address1';
		a.Address2__c = 'Address2';
		a.City__c = 'City';
		a.State__c = 'Ca';
		a.ZipCode__c = z.Id;
		
		insert a;
		
		Contact co = new Contact();
		co.LastName = 'Test';
		co.Consent_Received__c = 'Yes';
		co.AccountId = a.Id;
		
		insert co;
		
		Case c = new Case();
		c.Permission_to_Speak_to_HCP__c = 'No';
		c.Status = 'New';
		c.Date_of_First_Injection__c = System.today();
		c.Date_of_Last_Injection__c = System.today();
		c.ContactId = [SELECT Id FROM Contact LIMIT 1].Id;
		
		insert c;
		
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		
		// setup the data for the email
		email.subject = 'Inbound Fax:' + c.id + '-UTC';
		email.fromAddress = 'james@acuitymg.com';
		email.plainTextBody = 'email body';
		
		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my pdf attachment text');
		attachment.fileName = 'WIN-1APN49EM1LA_1505040854590033.PDF';
		attachment.mimeTypeSubType = 'application/pdf';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

		// call the email service class and test it with the data in the testMethod
		AMGInboundFaxEmail testInbound = new AMGInboundFaxEmail();
		testInbound.handleInboundEmail(email, env);
		
		test.stopTest();
	}
	
	static testMethod void TestinBoundEmail2()
	{
		test.startTest();
			
		Test.setMock(WebServiceMock.class, new FaxcomWS_FailAfterN_MockImpl(2147483647));
		
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		
		// setup the data for the email
		email.subject = 'Inbound Fax:';
		email.fromAddress = 'james@acuitymg.com';
		email.plainTextBody = 'email body';
		
		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my pdf attachment text');
		attachment.fileName = 'WIN-1APN49EM1LA_1505040854590033.PDF';
		attachment.mimeTypeSubType = 'application/pdf';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

		// call the email service class and test it with the data in the testMethod
		AMGInboundFaxEmail testInbound = new AMGInboundFaxEmail();
		testInbound.handleInboundEmail(email, env);
		
		test.stopTest();
	}
}