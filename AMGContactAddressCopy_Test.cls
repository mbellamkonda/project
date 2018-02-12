/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

@isTest 
private class AMGContactAddressCopy_Test {

	static testMethod void unitTest1()
	{
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
		
		Contact c = new Contact();
		c.LastName = 'Test';
		c.Consent_Received__c = 'Yes';
		c.AccountId = a.Id;
		
		insert c;
		
		c.Is_HCP_Address_from_SRF_Same__c = 'Yes';
		
		update c;
		
		c = [SELECT HCP_Address_1_from_SRF__c, HCP_Address_2_from_SRF__c, HCP_City_from_SRF__c, HCP_State_from_SRF__c, HCP_Zip_Code_from_SRF__c FROM Contact LIMIT 1];
		
		System.assertEquals('Address1', c.HCP_Address_1_from_SRF__c);
		System.assertEquals('Address2', c.HCP_Address_2_from_SRF__c);
		System.assertEquals('City', c.HCP_City_from_SRF__c);
		System.assertEquals('CA', c.HCP_State_from_SRF__c);
		System.assertEquals(z.Id, c.HCP_Zip_Code_from_SRF__c);
		
		test.stopTest();
	}
}