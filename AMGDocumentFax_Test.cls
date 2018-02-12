@isTest 
public class AMGDocumentFax_Test {
    @isTest 
    public static void doTest() {
    	Test.setMock(WebServiceMock.class, new FaxcomWS_FailAfterN_MockImpl(2147483647));
    	
    	// test data
    	String test_endpoint = 'http://bogus.bogus/bogus?bogus=bogus&bogus2=bogus2';
    	String test_username = 'bogus_user';
    	String test_password = 'bogus_password';
    	String test_fax_number = '5555555555';
    	PageReference test_page = new PageReference('/');
    	Blob test_blob = Blob.valueOf('TEST');

    	// object being tested
    	AMGDocumentFax fax = new AMGDocumentFax();
    	fax = new AMGDocumentFax(test_endpoint, test_username, test_password);
    	
    	// verify blank endpoint throws exception
    	try { fax = new AMGDocumentFax('', test_username, test_password); }
    	catch (Exception e) { System.assert(e.getMessage() == AMGDocumentFax.ERROR_MESSAGE_CREDENTIALS); }
		
		// verify blank username throws exception
    	try { fax = new AMGDocumentFax(test_endpoint, '', test_password); }
    	catch (Exception e) { System.assert(e.getMessage() == AMGDocumentFax.ERROR_MESSAGE_CREDENTIALS); }

		// verify blank password does NOT throw an exception
		fax = new AMGDocumentFax(test_endpoint, test_username, null);
		fax = new AMGDocumentFax(test_endpoint, test_username, '');
    	
    	// verify no recipients throws an exception
    	try { fax.sendFax(); }
    	catch (Exception e) { if (!AMGDocumentFax.TEST_MODE) System.assert(e.getMessage() == AMGDocumentFax.ERROR_MESSAGE_RECIPIENTS); }
    	
    	// verify no attachments throws an exception
    	fax.addRecipient(test_fax_number);
    	try { fax.sendFax(); }
    	catch (Exception e) { System.assert(e.getMessage() == AMGDocumentFax.ERROR_MESSAGE_ATTACHMENTS); }

    	// test adding redipients and attachments
		fax.addRecipient(test_fax_number);
		//fax.addAttachment(test_blob);
		fax.addAttachment(test_page);

		// test the "test send" methods
		//fax.sendTestFax(test_page);
		//fax.sendTestFax(test_blob);

		// get new limits due to "too many callouts", really not necessary here
		Test.startTest();

		// test the standard send methods
		//fax.sendFax(test_fax_number);
		//fax.sendFax(test_blob);
		//fax.sendFax(test_page);
		
		// test the two single-parameter send methods
		//fax.sendFax(test_fax_number, test_blob);
		//fax.sendFax(test_fax_number, test_page);
		
		// test the recipient list + single-parameter attachment methods
		//fax.sendFax(new list<String>{ test_fax_number }, test_blob);
		//fax.sendFax(new list<String>{ test_fax_number }, test_page);
		
		Test.stopTest();
    }
}