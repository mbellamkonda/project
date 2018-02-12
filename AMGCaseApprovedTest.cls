/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>, March 2017
 */
@isTest 
private class AMGCaseApprovedTest {

    static testMethod void myUnitTest() {
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
    	
    	Contact con = new Contact(FirstName = 'AAA', LastName = 'BBB');
    	insert con;
    	
    	Case c = new Case(
    		Permission_to_Speak_to_HCP__c = 'yes',
    		ContactId = con.Id
    	);
    	insert c;
    	
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData = Blob.valueOf('Unit Test Attachment Body'); 
        insert cv;
        cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.LinkedEntityId = c.Id;
        cl.ShareType = 'V';
        cl.ContentDocumentId = cv.ContentDocumentId;
        insert cl;
    	
    	test.startTest();
        // TO DO: implement unit test
        //Case c = [SELECT id, status FROM Case LIMIT 1];
        c.status = 'ADE Form Submitted';
        c.Permission_to_Speak_to_HCP__c = 'yes';
        update c;
        test.stopTest();
    }

	/*
    static testMethod void myUnitTest() {
    	test.startTest();
        // TO DO: implement unit test
        Case c = [SELECT id, status FROM Case WHERE id = '50046000000xmeK' LIMIT 1];
        c.status = 'ADE Form Submitted';
        c.Permission_to_Speak_to_HCP__c = 'yes';
        update c;
        test.stopTest();
    }
    */
}