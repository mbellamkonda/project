public class AMGDocumentControllerExtension {
	private sObject record {get;set;}


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Constructor
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public AMGDocumentControllerExtension(ApexPages.StandardController sc) { this.record = sc.getRecord(); }


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Properties
    ////////////////////////////////////////////////////////////////////////////////////////////////////

	public String caseSafeId { get { return AMGUtilities.ID15to18(String.valueOf(this.record.Id)); } }
	
    public String fileName {
    	get {
    		if (!Test.IsRunningTest())
    			return ApexPages.currentPage().getUrl().split('apex/')[1].split('\\?')[0] + '_-_' + this.record.Id + '.pdf';
    		else
    			return 'TEST.pdf';
    	}
    }
    
    public Blob pdfContent {
    	get {
    		if (!Test.IsRunningTest())
    			return ApexPages.currentPage().getContentAsPDF();
    		else
    			return Blob.valueOf('TEST');
    	}
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Page Actions
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public void saveDocument() {
    	AMGUtilities.saveDocument(
    		this.fileName,
    		(Test.IsRunningTest()) ? Blob.valueOf('TEST') : this.pdfContent,
    		this.record.Id,
    		true
    	);
    }

	public void dummy() { }
}