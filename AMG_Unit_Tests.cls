@isTest 
public class AMG_Unit_Tests {
    
    @isTest 
    public static void test_AMGCoverSheetController() {
        AMGCoverSheetController c = new AMGCoverSheetController(new AMGPatientController());
        Boolean b = c.isPaStatus;
        b = c.otherReasonExists;
        b = c.isAppealStatus;
        
        String s = c.todayDate;
        s = c.recipientName;
        s = c.recipientFax;
        s = c.recipientPhone;
        
        Integer i = c.pageCount;
    }
    
    @isTest 
    public static void test_AMGPatientController() {
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
    	
        Contact p = new Contact(LastName = 'TEST');
        insert p;
        AMGPatientController c = new AMGPatientController();
        c = new AMGPatientController(new ApexPages.StandardController(p));
        c.saveDocument();
        c.saveDocumentToPatient();
        c.dummy();
        
        Boolean b = c.errorExists;
        b = c.testBoolean;
        
        Blob l = c.pdfContent;
        
        String s = c.mccPhone;
        s = c.mccFax;
        s = c.mccName;
        
        s = c.patientName;
        s = c.patientDOB;
        s = c.patientHUB;
        
        s = c.pharmacyName;
        s = c.pharmacyPhone;
        s = c.pharmacyFax;
        s = c.pharmacyContact;
    
        s = c.providerName;
        s = c.providerPhone;
        s = c.providerFax;
        s = c.providerContact;
    
        s = c.testText;
        s = c.testPicklist;
        
        s = c.caseSafePatientId;
        s = c.caseSafeProviderId;
        s = c.caseSafePharmacyId;
        s = c.caseSafeCaseId;
        s = c.caseSafeTaskId;
        
        AMGPatientController.AMGControllerExtension e = new AMGPatientController.CoverSheetPharmacy();
        List<String> ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();
        
        e = new AMGPatientController.CoverSheetProvider();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();

        e = new AMGPatientController.CoverSheet();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();

        e = new AMGPatientController.CoverSheetACP();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();

        e = new AMGPatientController.UnableToContact();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();
        
        e = new AMGPatientController.HCPBIResults();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();
        
        e = new AMGPatientController.InsertDocuments();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();
        
        e = new AMGPatientController.LetterCopayAssistance();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();
        
        e = new AMGPatientController.LetterPatientWithdrawl();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();
        
        e = new AMGPatientController.LetterUrgentInitiation();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();
        
        e = new AMGPatientController.LetterPatientNonResponse();
        ss = e.getRequiredContactFields();
        ss = e.getRequiredAccountFields();
        ss = e.getRequiredCaseFields();
        ss = e.getRequiredTaskFields();
    }
}