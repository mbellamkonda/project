public class AMGDocumentFax {
	public static final Boolean TEST_MODE = false;
    private static final String TEST_FAX_NUMBER = '1000';

    public String url = '';
    public String username = '';
    public String password = '';
    public String idTag = null;
    public Integer priority = 3;
	public String sendTime = '0.0';
	public Integer resolution = 1;
	public String subject = 'Sending fax';
	public String coverPage = '';
	public String memo = 'Documents sent from Salesforce';
	public FaxcomAPI.SenderInfo senderInfo = null;
	public List<FaxcomAPI.RecipientInfo> recipients = new List<FaxcomAPI.RecipientInfo>();
	public List<FaxcomAPI.Attachment> attachments = new List<FaxcomAPI.Attachment>();
	public String tsi = null;
    
    private FaxcomAPI api;
    
    public static final String ERROR_MESSAGE_CREDENTIALS = 'Please provide a valid url endpoint, username, and password.';
    public static final String ERROR_MESSAGE_LOGIN = 'Unable to log in, please check credentials and try again.';
    public static final String ERROR_MESSAGE_RECIPIENTS = 'Recipient(s) not set, please do so before sending fax.';
	public static final String ERROR_MESSAGE_ATTACHMENTS = 'Attachment(s) not set, please do so before sending fax.';
	public static final String ERROR_MESSAGE_SENDING = 'Faxcom has indicated a failure occured when sending, please check parameters and try again.';


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Constructors and initializers
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public AMGDocumentFax() {
    	Outbound_Fax_Settings__c settings;
    	if (!Test.isRunningTest()) settings = [SELECT Endpoint__c,Username__c,Password__c FROM Outbound_Fax_Settings__c WHERE Name = 'Faxcom Live'];
    	this.url = settings != null ? settings.Endpoint__c : 'TEST';
    	this.username = settings != null ? settings.Username__c : 'TEST';
    	this.password = settings != null ? settings.Password__c : 'TEST';
    	login();
    }
    
    public AMGDocumentFax(String url, String username, String password) {
    	this.url = url;
    	this.username = username;
    	this.password = password;
    	login();
    }
    
    private Boolean login() {
    	if (!credentialsSet) throw new FaxException(ERROR_MESSAGE_CREDENTIALS);
		api = new FaxcomAPI(url);
		if (this.password == null) this.password = '';
		return api.LogIn(this.username, this.password).Result;
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Properties
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public Boolean loggedIn {
    	get { return this.api != null && this.api.IsLoggedIn(); }
    }
    
    public Boolean credentialsSet {
    	get { return !String.isBlank(this.url) && !String.isBlank(this.username); }
    }
    
    public Boolean recipientsSet {
    	get { return this.recipients != null && !this.recipients.isEmpty(); }
    }

    public Boolean attachmentsSet {
    	get { return this.attachments != null && !this.attachments.isEmpty(); }
    }	
	
	
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Recipient and Attachment setting methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public void addRecipient(String toNumber) {
		addRecipients(new List<String>{ toNumber });
	}
	
	public void addRecipients(List<String> toNumbers) {
		if (this.recipients == null) this.recipients = new List<FaxcomAPI.RecipientInfo>();
		for (String toNumber : toNumbers) this.recipients.add(new FaxcomAPI.RecipientInfo(toNumber));
	}
	
	public void addAttachment(Blob b, String extension) {
		this.attachments.add(new FaxcomAPI.Attachment('attachment.' + extension, b));
		//addAttachments(new List<Blob>{ b });
	}
	
	/*
	public void addAttachments(List<Blob> blobs) {
		if (this.attachments == null) this.attachments = new List<FaxcomAPI.Attachment>();
		for (Blob b : blobs) this.attachments.add(new FaxcomAPI.Attachment('attachment.tiff', b));
	}
	*/

	public void addAttachment(PageReference page) {
		addAttachments(new List<PageReference>{ page });
	}

	public void addAttachments(List<PageReference> pages) {
		if (this.attachments == null) this.attachments = new List<FaxcomAPI.Attachment>();
		for (PageReference page : pages) this.attachments.add(new FaxcomAPI.Attachment('attachment.pdf', getBlob(page)));
	}
	
	
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Send methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
    // 1 recipient, 1 page
	public FaxcomAPI.ResultMessage sendFax(String toNumber, PageReference page) {
		return sendFax(new List<String>{ toNumber }, new List<PageReference>{ page });
	}

	// 1 recipient, 1 blob
	public FaxcomAPI.ResultMessage sendFax(String toNumber, Blob b) {
		return sendFax(new List<String>{ toNumber }, new List<Blob>{ b });
	}
	
	// 1 recipient, X pages
	public FaxcomAPI.ResultMessage sendFax(String toNumber, List<PageReference> pages) {
		return sendFax(new List<String>{ toNumber }, pages);
	}

	// 1 recipient, X blobs
	public FaxcomAPI.ResultMessage sendFax(String toNumber, List<Blob> blobs) {
		return sendFax(new List<String>{ toNumber }, blobs);
	}
	
	// X recipients, 1 page
	public FaxcomAPI.ResultMessage sendFax(List<String> toNumbers, PageReference page) {
		return sendFax(toNumbers, new List<PageReference>{ page });
	}
	
	// X recipients, 1 blob
	public FaxcomAPI.ResultMessage sendFax(List<String> toNumbers, Blob b) {
		return sendFax(toNumbers, new List<Blob>{ b });
	}

	// X recipients, X pages
    public FaxcomAPI.ResultMessage sendFax(List<String> toNumbers, List<PageReference> pages) {
    	addRecipients(toNumbers);
    	addAttachments(pages);
    	return sendFax();
    }
	
	// X recipients, X blobs
    public FaxcomAPI.ResultMessage sendFax(List<String> toNumbers, List<Blob> blobs) {
    	addRecipients(toNumbers);
    	addAttachments(blobs);
    	return sendFax();
    }

	// 1 recipient
    public FaxcomAPI.ResultMessage sendFax(String toNumber) {
    	return sendFax(new List<String>{ toNumber });
    }
	
	// X recipients
    public FaxcomAPI.ResultMessage sendFax(List<String> toNumbers) {
    	return sendFax(toNumbers, new List<Blob>());
    }
    
	// 1 page
	public FaxcomAPI.ResultMessage sendFax(PageReference page) {
		return sendFax(new List<PageReference>{ page });
	}
	
	// X pages
	public FaxcomAPI.ResultMessage sendFax(List<PageReference> pages) {
		return sendFax(new List<String>(), pages);
	}

	// 1 blob
	public FaxcomAPI.ResultMessage sendFax(Blob b) {
		return sendFax(new List<Blob>{ b });
	}
	
	// X blobs
	public FaxcomAPI.ResultMessage sendFax(List<Blob> blobs) {
		return sendFax(new List<String>(), blobs);
	}
	*/
	
	// actually send something
    public FaxcomAPI.ResultMessage sendFax() {
    	if (TEST_MODE) loadTestRecipient();
    	
    	if (!this.loggedIn && !login()) {
    		throw new FaxException(ERROR_MESSAGE_LOGIN);
    	
    	} else if (!this.recipientsSet) {
    		this.api.ReleaseSession();
    		throw new FaxException(ERROR_MESSAGE_RECIPIENTS);
    		
    	} else if (!this.attachmentsSet) {
    		this.api.ReleaseSession();
    		throw new FaxException(ERROR_MESSAGE_ATTACHMENTS);
    	}
        else {
        	FaxcomAPI.ResultMessage resultMessage = this.api.SendNewFaxMessage(
	            this.idTag,
	            this.priority,
	            this.sendTime,
	            this.resolution,
	            this.subject,
	            this.coverpage,
	            this.memo,
	            this.senderInfo,
	            this.recipients,
	            this.attachments,
	            this.tsi
            );
            this.api.ReleaseSession();
            if (!resultMessage.Result) throw new FaxException(ERROR_MESSAGE_SENDING);
            else return resultMessage;
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Test send methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////
	/*
	public void sendTestFax(List<PageReference> pages) {
		sendFax(TEST_FAX_NUMBER, pages);
	}

	public void sendTestFax(List<Blob> blobs) {
		sendFax(TEST_FAX_NUMBER, blobs);
	}
	
	public void sendTestFax(PageReference page) {
		sendTestFax(new List<PageReference>{ page });
	}

	public void sendTestFax(Blob b) {
		sendTestFax(new List<Blob>{ b });
	}
	*/
	

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Helpers
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    	
    private static Blob getBlob(PageReference page) {
    	return !Test.isRunningTest() ? page.getContentAsPDF() : Blob.valueOf('TEST');
    }
    
    public void loadTestRecipient() {
    	this.recipients = new List<FaxcomAPI.RecipientInfo>{new FaxcomAPI.RecipientInfo(TEST_FAX_NUMBER)};
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Custom exception
    ////////////////////////////////////////////////////////////////////////////////////////////////////

	public class FaxException extends Exception { }
}