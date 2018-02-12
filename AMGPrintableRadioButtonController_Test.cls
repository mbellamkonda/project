@isTest 
public class AMGPrintableRadioButtonController_Test {
    @isTest 
    public static void doTest() {
    	AMGPrintableRadioButtonController c = new AMGPrintableRadioButtonController();
    	c.theRecord = new Case(Permission_to_Speak_to_HCP__c = 'yes');
    	c.fieldName = 'Status';
    	List<SelectOption> options = c.options;
    }
}