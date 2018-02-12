@isTest 
public class AMGPDFCustomSubstitutions_Test {
    @isTest 
    public static void doTest() {
    	
    	Case c = new Case(
    		Permission_to_Speak_to_HCP__c = 'yes'
    	);
    	insert c;
    	//c = [SELECT Id,Additional_Comments__c FROM Case WHERE Id = :c.Id];
    	
    	amgpdfgen__Letterhead__c lh = new amgpdfgen__Letterhead__c(Name = 'TEST LETTERHEAD');
    	insert lh;
    	
    	amgpdfgen__Template__c t = new amgpdfgen__Template__c(
    		Name = 'TEST TEMPLATE',
    		amgpdfgen__Base_Object__c = 'Case',
    		amgpdfgen__Active__c = true,
    		amgpdfgen__LetterHead__c = lh.Id,
    		amgpdfgen__Content__c = 'TEST CONTENT',
    		amgpdfgen__Type__c = 'TEST TYPE',
    		amgpdfgen__Custom_Substitutions__c = 'AMGPDFCustomSubstitutions.AdditionalComments'
    	);
    	insert t;
    	
    	AMGPDFCustomSubstitutions.AdditionalComments acSub = new AMGPDFCustomSubstitutions.AdditionalComments();
    	acSub.getIncludedFields();
    	acSub.substitute(
    		'TEST CONTENT',
    		new amgpdfgen.ParentRecord(
    			c.Id,
    			'Case',
    			new List<String>{'Additional_Comments__c'}
    		),
    		new amgpdfgen.Template(t.Name)
    	);
    	
    	AMGPDFCustomSubstitutions.FieldLabels flSub = new AMGPDFCustomSubstitutions.FieldLabels();
    	flSub.getIncludedFields();
    	flSub.substitute(
    		'TEST CONTENT',
    		new amgpdfgen.ParentRecord(
    			c.Id,
    			'Case',
    			new List<String>{'Id'}
    		),
    		new amgpdfgen.Template(t.Name)
    	);
    	
    	//AMGPDFCustomSubstitutions.functionWithParameter('TestFunction', 'Test text.');
    }
}