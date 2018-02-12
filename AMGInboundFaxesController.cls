/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by David Boyce <david@acuitymg.com> and James Glaubiger <james@acuitymg.com>
 */

// TEST NPI # 1720288335

public class AMGInboundFaxesController {
    // Test Mode toggle
    private static final Boolean TEST_MODE = false;
    public Boolean isTestMode { get { return TEST_MODE; } }

	// Constants
    private static final Map<String,String> FILE_TYPE_MAP = new Map<String,String>{
        'Prescription Form' => 'RX_Form',
        'Prior Authorization' => 'Prior_Authorization',
        'Consent Form' => 'Consent_Form',
        'Other' => 'Other'
    };
    private static final List<String> BACKGROUND_COLORS = new List<String>{
        '657383',   // slate blue
        '4c787e',   // slate teal
        '806d7e',   // slate purple
        '151b54'    // dark blue
    };
    
    private static final List<String> PROVIDER_FIELDS = new List<String>{
    	'Id','Name','MD_First_Name__c','MD_Last_Name__c','MD_NPI__c','Phone','Fax','Address1__c','Address2__c','City__c','State__c','ZipCode__r.Zip_Code__c'
    };
	private static String providerFieldString { get { return String.join(PROVIDER_FIELDS, ','); } }
	
    private static final List<String> PATIENT_FIELDS = new List<String>{
    	'Name','AccountId','BirthDate','Auto_Number__c'
    };
	private static String patientFieldString { get { return String.join(PATIENT_FIELDS, ','); } }
	
    private static final String NEW_ACCOUNT_URL = '/setup/ui/recordtypeselect.jsp?ent=Account&retURL=%2F001%2Fo&save_new_url=%2F001%2Fe%3FretURL%3D%252F001%252Fo';
	private static final String FAX_QUEUE_NAME = 'Inbound Faxes';
	private static final Id FAX_QUEUE_ID = [SELECT Id FROM Group WHERE Name = :FAX_QUEUE_NAME and Type = 'Queue' LIMIT 1].Id;
	private static final Id USER_ID = System.UserInfo.getUserId();


    // Members
    private NewProvider newProvider;
    private NewDocumentLink newLink;
    private ExistingProviders providers;
    private ExistingPatients patients;
    private InboundFaxes faxes;
    
    // Page properties
    public Boolean newAccountMode {get;set;}
    public Boolean fileTypeSelectMode {get;set;}
    public String errorMessage {get;set;}
    
    public String userSearch {get;set;}
    public Boolean searchPerformed {get;set;}
    public String patientFilter {get;set;}

    public String newAccountNPI {get;set;}
    public String newCurrentAccountId {get;set;}
    
    public String newPatientFirstName {get;set;}
    public String newPatientLastName {get;set;}
    public String newProviderFirstName {get;set;}
    public String newProviderLastName {get;set;}
    public Boolean inlineNewProviderMode {get;set;}
        
    public String patientIdForLink {get;set;}
    public Boolean agentAtWork {get;set;}

    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Constructors and Initializers
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public AMGInboundFaxesController() {
        debug('Starting AMGInboundFaxesController()');
        initialize();
        debug('Finished AMGInboundFaxesController()');
    }
    
    private void initialize() {
        debug('Starting initialize()');
        this.newProvider = null;
        this.providers = new ExistingProviders();
        this.patients = new ExistingPatients();
        this.faxes = new InboundFaxes();
        this.newLink = null;
        this.inlineNewProviderMode = false;
        this.agentAtWork = false;
        
        this.newAccountMode = false;
        this.fileTypeSelectMode = false;
        this.searchPerformed = false;
        this.patientFilter = '';
        this.newAccountNPI = (TEST_MODE) ? '1720288335' : '';
        debug('Finished initialize()');
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Page Actions
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public void loadNextFax() {
        debug('Starting loadNextFax()');
        this.errorMessage = '';
        this.faxes.loadNextFax();
        if (this.faxes.currentFaxHasFrom) this.providers.addProvidersBySearch(this.faxes.currentFax.Received_From__c);
        if (this.faxes.currentFaxHasCallerId) this.providers.addProvidersBySearch(this.faxes.currentFax.CNAME__c);
        debug('Finished initialize()');
    }

    public void resetTestData() {
        debug('Starting resetTestData()');
        this.errorMessage = '';
        List<Inbound_Fax__c> temp = [SELECT id,OwnerId,Unusable_Transmission__c,Processed__c FROM Inbound_Fax__c];
        for(Inbound_Fax__c f : temp) {
            f.OwnerId = FAX_QUEUE_ID;
            f.Unusable_Transmission__c = false;
            f.Processed__c = false;
        }
        update temp;
        this.faxes.currentFax = null;
        this.faxes.refreshQueue();
        debug('Finished resetTestData()');
    }

    public void doSearch() {
        debug('Starting doSearch()');
        this.errorMessage = '';
        this.providers.addProvidersBySearch(this.userSearch);
        this.searchPerformed = true;
        debug('Finished doSearch()');
    }
    
    public void resetSearch() {
        debug('Starting resetSearch()');
        this.errorMessage = '';
        this.providers.initialize();
        if (this.faxes.currentFaxHasFrom) this.providers.addProvidersBySearch(this.faxes.currentFax.Received_From__c);
        if (this.faxes.currentFaxHasCallerId) this.providers.addProvidersBySearch(this.faxes.currentFax.CNAME__c);
        debug('Finished resetSearch()');
    }
    
    public void doPatientSearch() {
        debug('Starting doPatientSearch()');
        
        debug('Finished doPatientSearch()');
    }
    
    public void toggleNewAccountMode() {
        debug('Starting toggleNewAccountMode()');
        this.errorMessage = '';
        this.newAccountMode = !this.newAccountMode;
        debug('Finished toggleNewAccountMode()');
    }
    
    public void doNPISearch() {
        debug('Starting doNPISearch()');
        this.errorMessage = '';
        if (!String.isBlank(newAccountNPI)) this.newProvider = new NewProvider(newAccountNPI);
        debug('Finished doNPISearch()');
    }
    
    public void unusableFax() {
        debug('Starting unusableFax()');
        this.errorMessage = '';
        this.faxes.currentFax.Unusable_Transmission__c = true;
        this.faxes.currentFax.OwnerId = FAX_QUEUE_ID;
        update this.faxes.currentFax;
        
        this.faxes.currentFax = null;
        loadNextFax();
        debug('Finished unusableFax()');
    }
    
    public void setCurrentAccount() {
        debug('Starting setCurrentAccount()');
        this.errorMessage = '';
        this.providers.setCurrentAccount(this.newCurrentAccountId);
        debug('Finished setCurrentAccount()');
    }
    
    public void toggleConfirmDetails() {
        debug('Starting toggleConfirmDetails()');
        this.errorMessage = '';
        this.newLink = new NewDocumentLink();
        this.fileTypeSelectMode = !this.fileTypeSelectMode;
        if (this.fileTypeSelectMode) {
            this.newLink.faxId = this.faxes.currentFax.Id;
            // existing patient and provider
            if (!String.isBlank(patientIdForLink)) {
                this.newLink.patient = this.providers.getPatientById(patientIdForLink);
                this.newLink.provider = this.providers.currentAccount;
            }
            // new patient and provider
            else {
                Account providerToUse;
                if (!String.isBlank(this.newProviderFirstName) && !String.isBlank(this.newProviderLastName)) {
                	Account a = new Account(
                		Name = this.newProviderFirstName + ' ' + this.newProviderLastName,
                		MD_First_Name__c = this.newProviderFirstName,
                		MD_Last_Name__c = this.newProviderLastName
                	);
                	insert a;
                	providerToUse = a;
                	this.newProviderLinkId = a.Id;
                } else if (this.newProvider != null) {
                    providerToUse = this.newProvider.insertProvider();
                    this.newProviderLinkId = providerToUse.Id;
                }
                else providerToUse = currentAccount;
                
                Contact c = new Contact(LastName = this.newPatientLastName, FirstName = this.newPatientFirstName, AccountId = providerToUse.Id, Consent_Received__c = 'No');
                if (Test.isRunningTest()) c.LastName = 'Test';
                debug('Creating new Patient: ' + JSON.serialize(c));
                insert c;
                
                this.newLink.patient = c;
                this.newLink.provider = providerToUse;
                this.newPatientLinkId = c.Id;
            }
        }
        debug('Finished toggleConfirmDetails()');
    }
    
    public void insertNewLink() {
        debug('Starting insertNewLink()');
        this.errorMessage = '';
        this.newLink.createLink();
        this.faxes.finishCurrentFax();
        this.agentAtWork = true;
        //initialize();
        debug('Finished insertNewLink()');
    }
    
    public void toggleInlineNewProviderMode() {
        debug('Starting toggleInlineNewProviderMode()');
        this.inlineNewProviderMode = !this.inlineNewProviderMode;
        debug('Finished toggleInlineNewProviderMode()');
    }
    
    public void dummy() { debug('Executing dummy()'); }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Public Properties
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    // Fax queue wrapper properties
    public Inbound_Fax__c ibf { get { return this.faxes.currentFax; } }
    public Boolean hasFromFax { get { return this.faxes.currentFaxHasFrom; } }
    public Boolean hasToFax { get { return this.faxes.currentFaxHasTo; } }
    public Boolean hasCallerId { get { return this.faxes.currentFaxHasCallerId; } }
    public Boolean hasTextOutput { get { return this.faxes.currentFaxHasTextOutput; } }
    public Integer totalFaxCount { get { return this.faxes.totalFaxCount; } }
    public Integer userFaxCount { get { return this.faxes.userFaxCount; } }
    public Integer queueFaxCount { get { return this.faxes.queueFaxCount; } }
    public Boolean pdfLoaded { get { return this.faxes.currentFax != null; } }
    public String pdfBlob { get { return this.faxes.currentFaxPDFContent; } }
    public Boolean emptyQueue { get { return this.faxes.totalFaxCount == 0; } }
    
    // Providers wrapper properties
    public Set<Account> possibleAccounts { get { return this.providers.providerMap.keySet(); } }
    public List<Account> possibleAccountMatches { get { return new List<Account>(this.possibleAccounts); } }
    public Account currentAccount { get { return this.providers.currentAccount; } set { this.providers.currentAccount = value; } }
    public Map<String,String> patientCount { get { return this.providers.patientCount; } }
    public Boolean possibleAccountsFound { get { return this.possibleAccounts != null && !this.possibleAccounts.isEmpty(); } }
    public List<Contact> possiblePatientMatches { get { return this.providers.getPossiblePatientMatches(this.patientFilter); } }
    
    // New provider wrapper properties
    public List<npiResult> npiResults { get { return this.newProvider != null ? this.newProvider.getResults() : new List<npiResult>(); } }
    public Integer newAccountSelectedIndex { get { return this.newProvider.selectedIndex; } set { this.newProvider.selectedIndex = value; } }
    public Boolean newProviderSelected { get { return this.newProvider != null && this.newProvider.results.results.size() > 0; } }
    public String selectedNewProviderName {
        get { return this.newProvider.selectedNewProviderName; }
        set { this.selectedNewProviderName = value; }
    }
    public String selectedNewProviderFirstName {
        get { return this.newProvider.selectedNewProviderFirstName; }
        set { this.selectedNewProviderFirstName = value; }
    }
    public String selectedNewProviderLastName {
        get { return this.newProvider.selectedNewProviderLastName; }
        set { this.selectedNewProviderLastName = value; }
    }
    
    // NewLink wrapper properties
    public String patientNameForLink {
        get { return !String.isBlank(this.newLink.patient.Name) ? this.newLink.patient.Name : this.newPatientFirstName + ' ' + this.newPatientLastName; }
    }
    public String providerNameForLink { get { return this.newLink.provider.Name; } }
    public Boolean attachButtonDisabled { get { return this.newLink == null || String.isBlank(this.newLink.fileType); } }
    public String fileType {
        get { return this.newLink.fileType; }
        set { this.newLink.fileType = value; }
    }
    
    // Governor limits properties
    public Decimal soqlLimitPercent { get { return Limits.getQueries() / Limits.getLimitQueries(); } }
    public Decimal rowLimitPercent { get { return Limits.getDmlRows() / Limits.getLimitDmlRows(); } }
    public Decimal dmlLimitPercent { get { return Limits.getDmlStatements() / Limits.getLimitDmlStatements(); } }
    public String governorLimitStatus {
        get { return 'SOQL Queries: (' + Limits.getQueries() + '/' + Limits.getLimitQueries() +
                ') | Query Rows: (' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows() +
                ') | DML Statements: (' + Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements() + ')';
        }
    }
    
    // Misc page properties
    //public String nextFaxButtonLabel { get { return (this.faxes.nextFaxIsMine) ? 'Continue Fax In Progress' : 'Get Next Fax'; } }
    public String nextFaxButtonLabel { get { return 'Get Next Fax'; } }
    public String newAccountURL { get { return NEW_ACCOUNT_URL; } }
    public Boolean errorExists { get { return !String.isBlank(this.errorMessage); } }
    public String backgroundColor1 { get { return '#f5f5f5'; } }
    public String backgroundColor2 { get { return '#' + BACKGROUND_COLORS[(Integer)Math.floor(Math.random() * (BACKGROUND_COLORS.size()))]; } }
    public List<SelectOption> availavbleFileTypes {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for (String s : FILE_TYPE_MAP.keySet()) options.add(new SelectOption(FILE_TYPE_MAP.get(s), s));
            return options;
        }
    }
    /*
    public List<SelectOption> availableQueueMembers {
    	get {
    		List<SelectOption> options = new List<SelectOption>();
    		
    		queueMembers
    	}
    }
    */
    public String newPatientLinkId {get;set;}
    public String newProviderLinkId {get;set;}
    

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  INNER CLASS: NewProvider
    //
    //  Represents a provider to be inserted into the system from NPI query data.
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private class NewProvider {
        private AMGNpiResult results;
        private final String DEFAULT_LOCATION_TYPE = 'MAILING';
        private Integer selectedIndex;
        
        public String selectedNewProviderName {get;set;}
        public String selectedNewProviderFirstName {get;set;}
        public String selectedNewProviderLastName {get;set;}
        
        private NewProvider(String npiNumber) {
            if (!Test.isRunningTest()) this.results = AMGNpiApi.queryNpiByNumber(npiNumber);
            
            this.results = (!Test.isRunningTest()) ? AMGNpiApi.queryNpiByNumber(npiNumber) : new AMGNpiResult('TESTING');
            
            if (!Test.isRunningTest() && TEST_MODE) this.results.results.add(new AMGNpiResult.results('TEST'));
            this.selectedIndex = 0;
            
            this.selectedNewProviderFirstName = (!Test.isRunningTest()) ? this.results.results[selectedIndex].basic.first_name : 'Test';
            this.selectedNewProviderLastName = (!Test.isRunningTest()) ? this.results.results[selectedIndex].basic.last_name : 'Test';
            this.selectedNewProviderName = this.selectedNewProviderFirstName + ' ' + this.selectedNewProviderLastName;
        }
        
        private Account insertProvider() {
            if (selectedIndex >= 0 && selectedIndex < this.results.results.size()) {
                Account a = new Account();
                a.Name = this.results.results[selectedIndex].basic.first_name + ' ' + this.results.results[selectedIndex].basic.last_name;
                a.MD_First_Name__c = this.results.results[selectedIndex].basic.first_name;
                a.MD_Last_Name__c = this.results.results[selectedIndex].basic.last_name;
                a.MD_NPI__c = String.valueOf(this.results.results[selectedIndex].id);
                
                String zipCodeString;
                for (AMGNpiResult.addresses address : this.results.results[selectedIndex].addresses) {
                    if (!String.isBlank(address.address_1) && (address.address_purpose == DEFAULT_LOCATION_TYPE || String.isBlank(a.Address1__c))) {
                        a.Address1__c = address.address_1;
                        a.Address2__c = address.address_2;
                        a.City__c = address.city;
                        a.State__c = address.state;
                        a.Phone = address.telephone_number;
                        a.Fax = address.fax_number;
                        zipCodeString = address.postal_code.substring(0,5);
                    }
                }
                if (!Test.isRunningTest()) a.ZipCode__c = [SELECT Id FROM Zip_Code__c WHERE Zip_Code__c = :zipCodeString].Id;
                else {
                	a.State__c = 'MA';
                	a.Phone = '555-555-5555';
                	a.Fax = '555-555-5555';
                }
                insert a;
                
                try { return a; } catch (Exception e) { return null; }
            } else return null;
        }

        public String selectedNewProviderNPI {
            get { return String.valueOf(this.results.results[selectedIndex].id); }
        }

        private List<npiResult> getResults() {
            List<npiResult> resultsList = new List<npiResult>();
            if (this.results != null) {
                for (Integer i = 0; i < this.results.results.size(); i++) {
                    resultsList.add(new npiResult(this.results.results[i], i));
                }
            }
            return resultsList;
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  INNER CLASS: npiResult
    //
    //  Represents reult data from an NPI query along with an index in case multiple possible providers found.
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public class npiResult {
        public AMGNpiResult.results results {get;set;}
        public Integer index {get;set;}
        public npiResult(AMGNpiResult.results results, Integer index) {
            this.results = results;
            this.index = index;
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  INNER CLASS: NewDocumentLink
    //
    //  Represents a new link between a received fax and the associated patient.
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private class NewDocumentLink {
        private Contact patient;
        private Account provider;
        private String faxId;
        private String fileType;
        
        private Boolean createLink() {
            ContentDocumentLink ibfLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :this.faxId LIMIT 1];
            
            ContentDocumentLink existingLink;
            try {
                existingLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :this.patient.Id AND ContentDocumentId = :ibfLink.ContentDocumentId];
                return false;
            } catch (Exception e) {
                ContentDocument doc = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id = :ibfLink.ContentDocumentId];
                ContentVersion version = [SELECT Id FROM ContentVersion WHERE Id = :doc.LatestPublishedVersionId];
                
                version.Title = this.fileType.replaceAll(' ', '') + '_' + this.patient.Name + '_' + System.today().format();
                update version;
                
                ContentDocumentLink link = new ContentDocumentLink(
                    LinkedEntityId = this.patient.Id,
                    ShareType = 'V',
                    ContentDocumentId = ibfLink.ContentDocumentId
                );
                insert link;
                return true;
            }
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  INNER CLASS: ExistingProviders
    //
    //  Represents existing providers and their patients that may be the subject of the fax.
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private class ExistingProviders {
        private Map<Account,List<Contact>> providerMap;
        private Map<String,String> patientCount;
        private Account currentAccount;
        
        private ExistingProviders() {
            initialize();
        }
        
        private void addProvidersBySearch(String searchString) {
        	String q = 'FIND \'' + searchString + '\' IN ALL FIELDS' +
                ' RETURNING Account(' + providerFieldString + 
                ' WHERE RecordType.Name = \'Providers\')';
            debug(q);
            List<Account> accs = (List<Account>)Search.query(q)[0];
        	/*
            List<Account> accs = (List<Account>)[FIND :searchString IN ALL FIELDS
                RETURNING Account(Id,Name,MD_First_Name__c,MD_Last_Name__c,MD_NPI__c,Phone,Fax,Address1__c,Address2__c,City__c,State__c,ZipCode__r.Zip_Code__c
                WHERE RecordType.Name = 'Providers')][0];
            */
            List<String> accountIds = new List<String>();
            for (Account a : accs) {
                if (this.providerMap.get(a) == null) this.providerMap.put(a, new List<Contact>());
                accountIds.add(a.Id);
            }
            
            //for (Contact c : [SELECT Name,AccountId,BirthDate,Auto_Number__c FROM Contact WHERE AccountId IN :accountIds])
            for (Contact c : Database.query('SELECT ' + patientFieldString + ' FROM Contact WHERE AccountId IN (\'' + String.join(accountIds, '\',\'') + '\')'))
                for (Account a : accs)
                    if (c.AccountId == a.Id) this.providerMap.get(a).add(c);
            
            for (Account a : this.providerMap.keySet()) this.patientCount.put(a.Id, String.valueOf(this.providerMap.get(a).size()));
            
            if (!this.providerMap.isEmpty()) this.currentAccount = new List<Account>(this.providerMap.keySet())[0];
        }
        
        private void setCurrentAccount(String accountId) {
            for (Account a : this.providerMap.keySet()) if (a.Id == accountId) this.currentAccount = a;
        }
        
        private void initialize() {
            this.providerMap = new Map<Account,List<Contact>>();
            this.patientCount = new Map<String,String>();
            this.currentAccount = null;
        }
        
        private Contact getPatientById(String patientId) {
            for (Account a : this.providerMap.keySet()) for (Contact c : this.providerMap.get(a)) if (c.Id == patientId) return c;
            return null;
        }
        
        // return list of patients of the current provider that match the filter, if one is set
        private List<Contact> getPossiblePatientMatches(String searchString) {
                List<Contact> cs = new List<Contact>();
                if (!this.providerMap.isEmpty()) for (Contact c : this.providerMap.get(this.currentAccount)) if (filterMatches(c, searchString)) cs.add(c);
                return cs;
        }
        
        private Boolean filterMatches(Contact c, String searchString) {
            return String.isBlank(searchString) || c.Name.containsIgnoreCase(searchString) || c.Auto_Number__c.containsIgnoreCase(searchString);
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  INNER CLASS: ExistingPatients
    //
    //  Represents existing patients from Salesforce.
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private class ExistingPatients {
    	private Map<Contact,Account> patientMap;
    	
    	private ExistingPatients() {
    		this.patientMap = new Map<Contact,Account>();
    		
    		
    	}
    	
    	private void addPatientsBySearch(String searchString) {
            List<Contact> cons = (List<Contact>)Search.query('FIND \'' + searchString + '\' IN ALL FIELDS ' +
                'RETURNING Contact(' + patientFieldString + ')')[0];
            
            List<String> accountIds = new List<String>();
            for (Contact c : cons) accountIds.add(c.Id);

			//for (Account a : [SELECT Id,Name,MD_First_Name__c,MD_Last_Name__c,MD_NPI__c,Phone,Fax,Address1__c,Address2__c,City__c,State__c,ZipCode__r.Zip_Code__c FROM Account WHERE Id IN :accountIds]) {
			for (Account a : Database.query('SELECT ' + providerFieldString + ' FROM Account WHERE Id IN (\'' + String.join(accountIds, '\',\'') + '\')')) {
                for (Contact c : cons)
                    if (c.AccountId == a.Id) this.patientMap.put(c, a);
			}

    	}
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  INNER CLASS: InboundFaxes
    //
    //  Represents inbound faxes that need to be processed.
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private class InboundFaxes {
        private Inbound_Fax__c currentFax {get;set;}
        private List<Inbound_Fax__c> userFaxes {get;set;}
        private List<Inbound_Fax__c> queueFaxes {get;set;}
        
        
	    ////////////////////////////////////////////////////////////////////////////////////////////////
	    //  Constructors
	    ////////////////////////////////////////////////////////////////////////////////////////////////
    
        private InboundFaxes() {
            refreshQueue();
        }


	    ////////////////////////////////////////////////////////////////////////////////////////////////
	    //  Methods
	    ////////////////////////////////////////////////////////////////////////////////////////////////

        private void refreshQueue() {
        	this.userFaxes = new List<Inbound_Fax__c>();
            this.queueFaxes = new List<Inbound_Fax__c>();
            List<Inbound_Fax__c> rawFaxes;
            try {
                rawFaxes = [
                    SELECT Id,Name,Received_From__c,Sent_to__c,CNAME__c,Text_Output__c,OwnerId
                    FROM Inbound_Fax__c
                    WHERE OwnerId IN (:USER_ID,:FAX_QUEUE_ID)
                    AND Processed__c = false
                    AND Unusable_Transmission__c = false
                    Order By Id
                ];
            } catch (Exception e) { }

            if (rawFaxes != null && !rawFaxes.isEmpty()) {
                List<Id> faxIds = new List<Id>();
                for (Inbound_Fax__c fax : rawFaxes) faxIds.add(fax.Id);
                
                List<ContentDocumentLink> links = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :faxIds];
                Set<String> validIds = new Set<String>();
                for (ContentDocumentLink link : links) validIds.add(link.LinkedEntityId);
                for (Inbound_Fax__c fax : rawFaxes) if (validIds.contains(fax.Id)) {
                	if (fax.OwnerId == USER_ID) this.userFaxes.add(fax);
                	else if (fax.OwnerId == FAX_QUEUE_ID) this.queueFaxes.add(fax);
                }
            }
        }

        private Inbound_Fax__c getNextFax() {
            Inbound_Fax__c workItem;
            List<Inbound_Fax__c> faxes = getFaxList();
            
            if (!this.userFaxes.isEmpty()) workItem = this.userFaxes.remove(0);
            else if (!this.queueFaxes.isEmpty()) {
            	workItem = this.queueFaxes.remove(0);
                workItem.OwnerId = USER_ID;
                update workItem;
            }
            return workItem;
        }
        
        private void loadNextFax() {
            this.refreshQueue();
            this.currentFax = getNextFax();
        }
        
        private void finishCurrentFax() {
            this.currentFax.Processed__c = true;
            update this.currentFax;
        }
        
        private List<Inbound_Fax__c> getFaxList() {
    		List<Inbound_Fax__c> faxes = new List<Inbound_Fax__c>();
    		faxes.addAll(userFaxes);
    		faxes.addAll(queueFaxes);
    		return faxes;
        }


	    ////////////////////////////////////////////////////////////////////////////////////////////////
	    //  Properties
	    ////////////////////////////////////////////////////////////////////////////////////////////////
        
        private Boolean nextFaxIsMine { get { return this.userFaxes != null && !this.userFaxes.isEmpty(); } }
        private Integer userFaxCount { get { return this.userFaxes.size(); } }
        private Integer queueFaxCount { get { return this.queueFaxes.size(); } }
        private Integer totalFaxCount { get { return userFaxCount + queueFaxCount; } }
        
        private Boolean currentFaxHasFrom {
            get { return this.currentFax != null && !String.isBlank(this.currentFax.Received_From__c); }
        }
        private String currentFaxFrom {
        	get { return (currentFaxHasFrom) ? this.currentFax.Received_From__c : ''; }
        }
    
        private Boolean currentFaxHasTo {
            get { return this.currentFax != null && !String.isBlank(this.currentFax.Sent_to__c); }
        }
        private String currentFaxTo {
        	get { return (currentFaxHasTo) ? this.currentFax.Sent_to__c : ''; }
        }
        
        private Boolean currentFaxHasCallerId {
            get { return this.currentFax != null && !String.isBlank(this.currentFax.CNAME__c) && this.currentFax.CNAME__c != this.currentFax.Received_From__c; }
        }
        private String currentFaxCallerId {
        	get { return (currentFaxHasCallerId) ? this.currentFax.CNAME__c : ''; }
        }
        
        private Boolean currentFaxHasTextOutput {
            get { return this.currentFax != null && !String.isBlank(this.currentFax.Text_Output__c); }
        }
        private String currentFaxTextOutput {
        	get { return (currentFaxHasTextOutput) ? this.currentFax.Text_Output__c : ''; }
        }
        
        private String currentFaxPDFContent {
            get {
                if(this.currentFax != null) {
                    ContentDocumentLink ibfLink = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: this.currentFax.Id LIMIT 1];
                    ContentVersion cv = [SELECT Id,ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId = :ibfLink.ContentDocumentId LIMIT 1];
                    return EncodingUtil.base64Encode(cv.VersionData);
                } else return '';
            }
        }
        
        private List<User> queueMembers {
        	get {
	        	List<Id> ids = new List<Id>();
	        	for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :FAX_QUEUE_ID]) ids.add(member.UserOrGroupId);
	        	return [SELECT Id FROM User WHERE Id IN :ids];
        	}
        }
    }
    
    /*
    private class SOQLQuery {
    	private String sObjectName;
    	private List<String> fieldNames;
    	private List<Map<String,List<String>>> whereClause;
    	private String orderByClause;
    	private Integer limit;
    	private SOQLQuery(String sObjectName, List<String> fieldNames, List<Map<String,List<String>>> whereClause, String orderByClause, Integer limit) {
    		this.sObjectName = sObjectName;
    		this.fieldNames = fieldNames;
    		this.whereClause = whereClause;
    		this.orderByClause = orderByClause;
    		this.limit = limit;
    	}
    	private List<sObject> query() {
    		return Database.query(
    			'SELECT ' + String.join(fieldNames, ',') +
    			'FROM ' + sObjectName + 
    			'WHERE '
    		);
    	}
    }
    */
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Private Static Helpers
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private static void debug(String s) { if (TEST_MODE) System.debug('[AMG] ******** ' + s); }
    private static void debug(sObject o) {
    	debug( o.get('Name') + ': ' + JSON.serializePretty(o) + '\n ******** [AMG] ******** End ' + o.get('Name'));
    }
    //private static void debug(Object o) {}
}