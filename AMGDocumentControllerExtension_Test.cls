@isTest 
public class AMGDocumentControllerExtension_Test {
    @isTest 
    public static void doTest() {
    	Case c = new Case(Permission_to_Speak_to_HCP__c = 'yes');
    	insert c;
    	AMGDocumentControllerExtension e = new AMGDocumentControllerExtension(new ApexPages.StandardController(c));
    	e.dummy();
    	String s = e.caseSafeId;
    	s = e.fileName;
    	s = String.valueOf(e.pdfContent);
    	e.saveDocument();
    }
}