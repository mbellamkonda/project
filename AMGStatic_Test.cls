@isTest 
public class AMGStatic_Test {
    @isTest 
    public static void testIsDST() {
    	System.assert(!AMGStatic.isDST(Date.newInstance(2017,03,01)));
    	//System.assert(!AMGStatic.isDST(Date.newInstance(2017,03,11)));
    	//System.assert(AMGStatic.isDST(Date.newInstance(2017,03,12)));
    	System.assert(AMGStatic.isDST(Date.newInstance(2017,03,31)));
    	
    	System.assert(AMGStatic.isDST(Date.newInstance(2017,11,01)));
    	System.assert(!AMGStatic.isDST(Date.newInstance(2017,11,30)));
    }
    
    @isTest 
    public static void testUpdateFDAIndication() {
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
		
		Account a = new Account(Name = 'TEST_ACCOUNT');
		insert a;
    	
		List<Contact> cs = new List<Contact>{
			new Contact(
				AccountId = a.Id,
				LastName = 'TEST_0',
				PT_Gest_Age_Date__c = System.today(),
				PT_Gest_Age_at_Enrollment__c = 1.1,
    			Previous_Pre_Term_Birth__c = 'Yes',
    			Currently_Pregnant_with_Singleton__c = 'Yes',
    			Patient_Currently_on_Makena_or_17_P__c = '',
    			Patient_Status__c = 'Pending',
    			Patient_Substatus__c = 'Early GA'
    		),
			new Contact(
				AccountId = a.Id,
				LastName = 'TEST_1',
				PT_Gest_Age_Date__c = System.today(),
				PT_Gest_Age_at_Enrollment__c = 17.1,
    			Previous_Pre_Term_Birth__c = 'Yes',
    			Currently_Pregnant_with_Singleton__c = 'Yes',
    			Patient_Currently_on_Makena_or_17_P__c = 'Yes'
    		),
			new Contact(
				AccountId = a.Id,
				LastName = 'TEST_3',
				PT_Gest_Age_Date__c = System.today(),
				PT_Gest_Age_at_Enrollment__c = 17.1,
    			Previous_Pre_Term_Birth__c = '',
    			Currently_Pregnant_with_Singleton__c = '',
    			Patient_Currently_on_Makena_or_17_P__c = ''
    		),
			new Contact(
				AccountId = a.Id,
				LastName = 'TEST_4',
				PT_Gest_Age_Date__c = System.today(),
				PT_Gest_Age_at_Enrollment__c = 17.1,
    			Previous_Pre_Term_Birth__c = 'No',
    			Currently_Pregnant_with_Singleton__c = '',
    			Patient_Currently_on_Makena_or_17_P__c = ''
    		),
			new Contact(
				AccountId = a.Id,
				LastName = 'TEST_5',
				PT_Gest_Age_Date__c = System.today(),
				PT_Gest_Age_at_Enrollment__c = 17.1,
    			Previous_Pre_Term_Birth__c = '',
    			Currently_Pregnant_with_Singleton__c = 'No',
    			Patient_Currently_on_Makena_or_17_P__c = ''
    		),
			new Contact(
				AccountId = a.Id,
				LastName = 'TEST_6',
				PT_Gest_Age_Date__c = System.today(),
				PT_Gest_Age_at_Enrollment__c = 18.1,
    			Previous_Pre_Term_Birth__c = 'Yes',
    			Currently_Pregnant_with_Singleton__c = 'No',
    			Patient_Currently_on_Makena_or_17_P__c = 'No',
    			Patient_Status__c = 'Pending',
    			Patient_Substatus__c = 'Early GA'
    		)
		};
		insert cs;
		
		Test.startTest();
		for (Integer i = 0; i < cs.size(); i++) {
			cs[i].recalculateFormulas();
			AMGStatic.updateFDAIndication(cs[i]);
		}
		update cs;
		Test.stopTest();
		
		Contact c = [SELECT Meets_FDA_Indication__c,Patient_Substatus__c FROM Contact WHERE Id = :cs[0].Id];
		System.debug('******** c.Meets_FDA_Indication__c: ' + c.Meets_FDA_Indication__c);
		System.assert(c.Meets_FDA_Indication__c == 'Off Label');
		System.assert(c.Patient_Substatus__c == 'Early GA');
		
		c = [SELECT Meets_FDA_Indication__c,Current_Calculated_GA_as_of_TODAY__c FROM Contact WHERE Id = :cs[1].Id];
		System.debug('******** c.Current_Calculated_GA_as_of_TODAY__c: ' + c.Current_Calculated_GA_as_of_TODAY__c);
		System.assert(c.Meets_FDA_Indication__c == 'On Label');
		
		c = [SELECT Meets_FDA_Indication__c,Current_Calculated_GA_as_of_TODAY__c FROM Contact WHERE Id = :cs[2].Id];
		System.debug('******** c.Meets_FDA_Indication__c: ' + c.Meets_FDA_Indication__c);
		System.assert(c.Meets_FDA_Indication__c == 'Unable to Determine');
		
		c = [SELECT Meets_FDA_Indication__c,Patient_Substatus__c FROM Contact WHERE Id = :cs[5].Id];
		System.debug('******** c.Patient_Substatus__c: ' + c.Patient_Substatus__c);
		System.assert(c.Meets_FDA_Indication__c == 'Off Label');
		System.assert(c.Patient_Substatus__c == 'BI');
    }
}