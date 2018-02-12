@isTest 
public class AMGLetterCreation_Test {
    @isTest 
    public static void doTest() {
    	
    	// Patient section
    	
    	Contact patient = new Contact(LastName = 'Test');
    	insert patient;
    	
    	patient.Patient_Status__c = 'Active';
    	patient.Patient_Substatus__c = 'On Therapy';
    	update patient;
    	
    	patient = [SELECT Needed_Documents__c FROM Contact WHERE Id = :patient.Id];
    	System.assert(patient.Needed_Documents__c == 'Welcome Letter');
    	
    	patient.Attempt__c = 2;
    	update patient;
    	
    	patient = [SELECT Needed_Documents__c FROM Contact WHERE Id = :patient.Id];
    	System.debug('******** Needed: ' + patient.Needed_Documents__c);
    	System.assert(patient.Needed_Documents__c == 'Welcome Letter;Non-Response Letter');
    	
    	// Case section
    	
    	Case c = new Case(ContactId = patient.Id);
    	insert c;
    	
    	c.Status = 'Shipped';
    	update c;
    	
    	Test.startTest();
    	
    	AMGLetterCreation.start();
    	
    	Test.stopTest();
    	
    	List<ContentDocumentLink> links = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :patient.Id];
    	System.debug('******** Links: ' + JSON.serialize(links));
    	//System.assert(links.size() == 2);
    	
    }
}