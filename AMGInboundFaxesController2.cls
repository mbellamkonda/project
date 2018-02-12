/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by David Boyce <david@acuitymg.com> and James Glaubiger <james@acuitymg.com>
 */

// TEST NPI # 1720288335

public class AMGInboundFaxesController2 {
    // Test Mode toggle
    private static final Boolean TEST_MODE = false;
    public Boolean isTestMode { get { return TEST_MODE; } }

    // Constants
    private static final Map<String,String> FILE_TYPE_MAP = new Map<String,String>{
        'Prescription Form' => 'RX_Form',
        'Prior Authorization' => 'Prior_Authorization',
        'Consent Form' => 'Consent_Form'
    };
    private static final List<String> BACKGROUND_COLORS = new List<String>{
        '657383',   // slate blue
        '4c787e',   // slate teal
        //'806d7e',   // mauve
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
    
    private static final String FAX_QUEUE_NAME = 'Inbound Faxes';
    private static final Id FAX_QUEUE_ID = [SELECT Id FROM Group WHERE Name = :FAX_QUEUE_NAME and Type = 'Queue' LIMIT 1].Id;
    private static final Id USER_ID = System.UserInfo.getUserId();
	private static final Integer LARGE_FILE_CUTOFF_SIZE = 1500000; // bytes


    // Members
    private NewProvider newProvider;
    private NewDocumentLink newLink;
    private ExistingProviders providers;
    private ExistingPatients patients;
    private InboundFaxes faxes;
    
    // Page properties
    public String errorMessage {get;set;}
    
    public String userSearch {get;set;}
    public String userPatientSearch {get;set;}
    public Boolean searchPerformed {get;set;}
    public Boolean patientSearchPerformed {get;set;}
    public String patientFilter {get;set;}

    public String newAccountNPI {get;set;}
    public String newCurrentAccountId {get;set;}
    public String newCurrentPatientId {get;set;}
    
    public String newPatientFirstName {get;set;}
    public String newPatientLastName {get;set;}
    public String newProviderFirstNameQuick {get;set;}
    public String newProviderLastNameQuick {get;set;}
        
    public String patientIdForLink {get;set;}
    public Boolean agentAtWork {get;set;}
    
    public String activeTab {get;set;}
    public String previousTab {get;set;}
    public Boolean agentConfirmation {get;set;}
    public Boolean npiSearchPerformed {get;set;}
    public Contact patientForUpdate {get;set;}
    public Boolean isExistingPatient {get;set;}
    
    public String backgroundColor1 { get { return '#f5f5f5'; } }
    public String backgroundColor2 {get;set;}
    public String reassignValue {get;set;}
    public Boolean unauthorized {get;set;}
    public Boolean reassignSuccess {get;set;}
    public String otherLabel {get;set;}
    public List<String> selectedOnHoldFaxes {get;set;}
    public String onHoldLabel {get;set;}
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Constructors and Initializers
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public AMGInboundFaxesController2() {
        debug('Starting AMGInboundFaxesController()');
        initialize();
        debug('Finished AMGInboundFaxesController()');
    }
    
    private void initialize() {
        debug('Starting initialize()');
        this.faxes = new InboundFaxes();
        if (!Test.isRunningTest() && !this.faxes.userIsQueueMember) { this.unauthorized = true; this.errorMessage = 'You are not a member of the Inbound Faxes Queue'; return; }
        this.newProvider = null;
        this.providers = new ExistingProviders();
        this.patients = new ExistingPatients();
        //if (TEST_MODE) this.patients.addPatientsBySearch('Test');
        this.newLink = null;
        this.agentAtWork = false;
        this.activeTab = 'EXISTING_PROVIDERS';
        this.previousTab = this.activeTab;
        this.npiSearchPerformed = false;
        this.patientForUpdate = new Contact();
        this.isExistingPatient = false;
        this.backgroundColor2 =  '#' + BACKGROUND_COLORS[(Integer)Math.floor(Math.random() * (BACKGROUND_COLORS.size()))];
        this.reassignSuccess = false;
        this.selectedOnHoldFaxes = new List<String>();
        
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
        this.onHoldLabel = this.faxes.currentFax.Name;
        if (this.faxes.currentFaxHasFrom) this.providers.addProvidersBySearch(this.faxes.currentFax.Received_From__c);
        if (this.faxes.currentFaxHasCallerId) this.providers.addProvidersBySearch(this.faxes.currentFax.CNAME__c);
        debug('Finished initialize()');
    }

    public void resetTestData() {
        debug('Starting resetTestData()');
        this.errorMessage = '';
        List<Inbound_Fax__c> temp = [SELECT id,OwnerId,Status__c FROM Inbound_Fax__c];
        for(Inbound_Fax__c f : temp) {
            f.OwnerId = FAX_QUEUE_ID;
            f.Type__c = 'Inbound';
            f.Status__c = 'Received';
        }
        update temp;
        this.faxes.currentFax = null;
        this.faxes.refreshQueue();
        debug('Finished resetTestData()');
    }

    public void doSearch() {
        debug('Starting doSearch()');
        this.errorMessage = '';
        if (this.userSearch.length() < 2) this.errorMessage = 'Searches terms must have two or more characters';
        else {
	        this.providers.addProvidersBySearch(this.userSearch);
	        this.searchPerformed = true;
        }
        debug('Finished doSearch()');
    }
    
    public void doPatientSearch() {
        debug('Starting doPatientSearch()');
        this.errorMessage = '';
        if (this.userPatientSearch.length() < 2) this.errorMessage = 'Searches terms must have two or more characters';
        else {
        	this.patients.addPatientsBySearch(this.userPatientSearch);
        	this.patientSearchPerformed = true;
        }
        debug('Finished doPatientSearch()');
    }
    
    public void resetSearch() {
        debug('Starting resetSearch()');
        this.errorMessage = '';
        this.providers.initialize();
        if (this.faxes.currentFaxHasFrom) this.providers.addProvidersBySearch(this.faxes.currentFax.Received_From__c);
        if (this.faxes.currentFaxHasCallerId) this.providers.addProvidersBySearch(this.faxes.currentFax.CNAME__c);
        debug('Finished resetSearch()');
    }
    
    public void resetPatientSearch() {
        debug('Starting resetPatientSearch()');
        this.errorMessage = '';
        this.patients.initialize();
        debug('Finished resetPatientSearch()');
    }
    
    public void doNPISearch() {
        debug('Starting doNPISearch()');
        this.errorMessage = '';
        this.newAccountNPI = this.newAccountNPI.replaceAll('\\D', '');
        if (this.newAccountNPI.length() != 10) this.errorMessage = 'Please enter a 10-digit NPI number';
        else {
        	this.npiSearchPerformed = true;
        	this.newProvider = new NewProvider(this.newAccountNPI);
        	this.errorMessage = this.newProvider.errorMessage;
        }
        debug('Finished doNPISearch()');
    }
    
    public void setCurrentAccount() {
        debug('Starting setCurrentAccount()');
        this.errorMessage = '';
        this.providers.setCurrentAccount(this.newCurrentAccountId);
        debug('Finished setCurrentAccount()');
    }

    public void setCurrentPatient() {
        debug('Starting setCurrentPatient()');
        this.errorMessage = '';
        this.patients.setCurrentPatient(this.newCurrentPatientId);
        debug('Finished setCurrentPatient()');
    }

    public void toggleConfirmDetails() {
        debug('Starting toggleConfirmDetails()');
        this.errorMessage = '';
        if (this.activeTab != 'CONFIRM_DETAILS') {
        	this.previousTab = this.activeTab;
        	this.activeTab = 'CONFIRM_DETAILS';
        	this.newLink = new NewDocumentLink();
            this.newLink.faxId = (!Test.isRunningTest()) ? this.faxes.currentFax.Id : '001000000000000';
            // existing provider with new patient
            if (!String.isBlank(patientIdForLink)) {
                this.newLink.patient = this.providers.getPatientById(patientIdForLink);
                this.newLink.provider = this.providers.currentAccount;
            // existing patient and provider
            } else if (this.isExistingPatient) {
                this.newLink.patient = this.patients.currentPatient;
                this.newLink.provider = this.patients.currentProvider;
            }
            // new patient with existing provider
            else {
                Contact c = new Contact(Consent_Received__c = 'No');
                c.LastName = (!Test.isRunningTest()) ? this.newPatientLastName : 'Test';
                c.FirstName = (!Test.isRunningTest()) ? this.newPatientFirstName : 'Test';
                if (!Test.isRunningTest()) c.AccountId = currentAccount.Id;
                
                debug('Creating new Patient: ' + JSON.serialize(c));
                insert c;
                
                this.newLink.patient = c;
                this.newLink.provider = currentAccount;
                this.newPatientLinkId = c.Id;
            }
        } else { this.activeTab = (!String.isBlank(this.previousTab)) ? this.previousTab : 'EXISTING_PROVIDERS'; }
        debug('Finished toggleConfirmDetails()');
    }
    
    public void insertNewProvider() {
    	debug('Starting insertNewProvider()');
    	this.errorMessage = '';
    	Account newProvider = this.newProvider.insertProvider();
    	//this.providers.addProvidersBySearch([SELECT Name FROM Account WHERE Id = :newProviderId].Name);
    	if (newProvider == null || newProvider.Id == null) errorMessage = 'Error inserting record. Duplicate NPI number?';
    	else {
    		this.activeTab = 'EXISTING_PROVIDERS';
    		this.agentConfirmation = false;
    		this.npiSearchPerformed = false;
    		this.userSearch = newProvider.Name;
    	}
    	debug('Finished insertNewProvider()');
    }
    
    public void insertNewLink() {
        debug('Starting insertNewLink()');
        this.errorMessage = '';
        this.newLink.createLink(this.selectedOnHoldFaxes);
        this.faxes.finishCurrentFax();
        this.agentAtWork = true;
        //initialize();
        debug('Finished insertNewLink()');
    }
    
    public void dummy() { debug('Executing dummy()'); }
    
    public void updateProviderForCurrentPatient() {
    	debug('Starting updateProviderForCurrentPatient()');
    	this.patients.updateProviderForCurrentPatient(this.patientForUpdate.AccountId);
    	this.patientForUpdate.AccountId = null;
    	debug('Finished updateProviderForCurrentPatient()');
    }
    
    public void reassignFax() {
    	debug('Starting reassignFax()');
    	if (this.reassignValue == 'queue') this.faxes.currentFax.OwnerId = FAX_QUEUE_ID;
    	else if (this.reassignValue == 'bad') this.faxes.currentFax.Status__c = 'Bad Transmission';
    	else if (this.reassignValue == 'duplicate') this.faxes.currentFax.Status__c = 'Duplicate';
    	else if (this.reassignValue == 'onhold') {
    		
    		this.previousTab = this.activeTab;
    		this.activeTab = 'ONHOLD_LABEL';
    		
    		this.faxes.currentFax.Status__c = 'On Hold';
    	} else if (!String.isBlank(this.reassignValue)) this.faxes.currentFax.OwnerId = this.reassignValue;
    	
    	if (!String.isBlank(this.reassignValue) && this.reassignValue != 'onhold') {
    		this.reassignSuccess = true;
    		update this.faxes.currentFax;
    	}
    	
    	debug('Finished reassignFax()');
    }
    
    public void confirmOnHold() {
    	debug('Starting confirmOnHold()');
    	if (String.isBlank(this.onHoldLabel)) this.errorMessage = 'Please enter a label for this "on hold" fax';
    	else {
    		this.faxes.currentFax.Status__c = 'On Hold';
	    	this.faxes.currentFax.Label__c = this.onHoldLabel;
	    	this.faxes.currentFax.OwnerId = FAX_QUEUE_ID;
	    	update this.faxes.currentFax;
    	}
    	debug('Finished confirmOnHold()');
    }
    
    public void cancelOnHold() {
    	debug('Starting cancelOnHold()');
    	this.activeTab = this.previousTab;
    	this.onHoldLabel = '';
    	debug('Finished cancelOnHold()');
    }
    
    public void clearSelectedOnHoldDocuments() {
    	debug('Starting clearSelectedOnHoldDocuments()');
    	this.selectedOnHoldFaxes = new List<String>();
    	debug('Finished clearSelectedOnHoldDocuments()');
    }
    
    
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
    public Boolean availableOnHoldFaxesExist { get { return !this.faxes.onHoldFaxes.isEmpty(); } }
    public String currentVersionId { get { return this.faxes.currentVersionId; } }
    public List<SelectOption> availableOnHoldFaxes {
    	get {
    		List<SelectOption> options = new List<SelectOption>();
    		for (Inbound_Fax__c fax : this.faxes.onHoldFaxes) options.add(new SelectOption(fax.Id, Fax.Label__c + ' (' + fax.CreatedDate.format() + ')'));
    		return options;
    	}
    }
    public Boolean largeFileMode { get { return this.faxes.largeFileMode; } }
    
    // Existing providers wrapper properties
    public Set<Account> possibleAccounts { get { return this.providers.providerMap.keySet(); } }
    public List<Account> possibleAccountMatches { get { return new List<Account>(this.possibleAccounts); } }
    public Account currentAccount { get { return this.providers.currentAccount; } set { this.providers.currentAccount = value; } }
    public Map<String,String> patientCount { get { return this.providers.patientCount; } }
    public Boolean possibleAccountsFound { get { return this.possibleAccounts != null && !this.possibleAccounts.isEmpty(); } }
    public List<Contact> possibleAccountPatientMatches { get { return this.providers.getPossiblePatientMatches(this.patientFilter); } }
    
    // Existing patients wrapper properties
    public Set<Contact> possiblePatients { get { return this.patients.patientMap.keySet(); } }
    public List<Contact> possiblePatientMatches { get { return new List<Contact>(this.possiblePatients); } }
    public Contact currentPatient { get { return this.patients.currentPatient; } set { this.patients.currentPatient = value; } }
    public Boolean possiblePatientsFound { get { return this.possiblePatients != null && !this.possiblePatients.isEmpty(); } }
    public String currentProviderInfo { get { return this.patients.currentProviderInfo; } }
    public String currentProviderId { get { return this.patients.currentProviderId; } }
    
    /*
    public Contact theCurrentPatient {
    	get { return this.patients.theCurrentPatient; }
    	set {
    		debug('Setter 1.');
    		this.patients.theCurrentPatient = value;
    	}
    }
    */
    // New provider wrapper properties
    public Boolean newProviderSelected { get { return this.newProvider != null && this.newProvider.results != null; } }
    public Boolean npiResultsFound { get { return this.newProvider != null && this.newProvider.results != null; } }
    public String newProviderName { get { return this.newProvider.provider.Name; } set { this.newProvider.provider.Name = value; } }
    public String newProviderNPI { get { return this.newProvider.provider.MD_NPI__c; } set { this.newProvider.provider.MD_NPI__c = value; } }
    public String newProviderFirstName { get { return this.newProvider.provider.MD_First_Name__c; } set { this.newProvider.provider.MD_First_Name__c = value; } }
    public String newProviderLastName { get { return this.newProvider.provider.MD_Last_Name__c; } set { this.newProvider.provider.MD_Last_Name__c = value; } }
    public Boolean newProviderMultipleAddresses { get { return this.newProvider != null && this.newProvider.multipleAddressesExist; } }
    public String newProviderSelectedAddressIndex { get { return this.newProvider.selectedAddressIndex; } set { this.newProvider.selectedAddressIndex = value; } } 
    
    public String newProviderAddress1 { get { return this.newProvider.provider.Address1__c; } set { this.newProvider.provider.Address1__c = value; } }
    public String newProviderAddress2 { get { return this.newProvider.provider.Address2__c; } set { this.newProvider.provider.Address2__c = value; } }
    public String newProviderCity { get { return this.newProvider.provider.City__c; } set { this.newProvider.provider.City__c = value; } }
    public String newProviderState { get { return this.newProvider.provider.State__c; } set { this.newProvider.provider.State__c = value; } }
    public String newProviderPhone { get { return this.newProvider.provider.Phone; } set { this.newProvider.provider.Phone = value; } }
    public String newProviderFax { get { return this.newProvider.provider.Fax; } set { this.newProvider.provider.Fax = value; } }
    public String newProviderZipCode { get { return this.newProvider.newZipCode; } set { this.newProvider.newZipCode = value; } }
    public List<SelectOption> newProviderAddresses {
    	get {
    		List<SelectOption> options = new List<SelectOption>();
    		for (Integer i = 0; i < this.newProvider.results.addresses.size(); i++) {
    			options.add(new SelectOption(String.valueOf(i), this.newProvider.results.addresses[i].address_purpose));
    		}
    		return options;
    	}
    }
    
    
    // NewLink wrapper properties
    public String patientNameForLink {
        get { return !String.isBlank(this.newLink.patient.Name) ? this.newLink.patient.Name : this.newPatientFirstName + ' ' + this.newPatientLastName; }
    }
    public String providerNameForLink { get { return this.newLink.provider.Name; } }
    public Boolean attachButtonDisabled { get { return this.newLink == null || String.isBlank(this.newLink.fileType); } }
    public String fileType {
        get { return this.newLink.fileType; }
        set { this.newLink.fileType = (value != 'Other' || String.isBlank(this.otherLabel)) ? value : this.otherLabel; }
    }
    public String linkedPatientId { get { return this.newLink.patient.Id; } }
    public String linkedProviderId { get { return this.newLink.provider.Id; } }
    
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
    public Boolean errorExists { get { return !String.isBlank(this.errorMessage); } }
    public List<SelectOption> availavbleFileTypes {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for (String s : FILE_TYPE_MAP.keySet()) options.add(new SelectOption(FILE_TYPE_MAP.get(s), s));
            return options;
        }
    }
    
    public String existingPatientsButtonStyle {
        get {
            return 'slds-button slds-button--neutral ' + ((this.activeTab == 'EXISTING_PATIENTS') ? 'selected_button' : 'non-selected_button');
        }
    }

    public String existingProvidersButtonStyle {
        get {
            return 'slds-button slds-button--neutral ' + ((this.activeTab == 'EXISTING_PROVIDERS') ? 'selected_button' : 'non-selected_button');
        }
    }
    
    public String npiRegistryButtonStyle {
        get {
            return 'slds-button slds-button--neutral ' + ((this.activeTab == 'NEW_PROVIDER') ? 'selected_button' : 'non-selected_button');
        }
    }

    
    public List<SelectOption> availableReassigns {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select--'));
            options.add(new SelectOption('bad', '! Unusable Fax !'));
            options.add(new SelectOption('duplicate', '& Duplicate Fax &'));
            options.add(new SelectOption('queue', '< Back to Queue <'));
            options.add(new SelectOption('onhold', '# Place on Hold #'));
            for (User u : this.faxes.queueMembers) if (u.Id != USER_ID) options.add(new SelectOption(u.Id, u.Name));
            return options;
        }
    }
    
    public String newPatientLinkId {get;set;}
    public String newProviderLinkId {get;set;}
    public String userName { get { return System.UserInfo.getName(); } }
    

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  INNER CLASS: NewProvider
    //
    //  Represents a provider to be inserted into the system from NPI query data.
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private class NewProvider {
        private AMGNpiResult.results results;
        private final String DEFAULT_LOCATION_TYPE = 'LOCATION';
        private String errorMessage;
        private Account provider;
		private String newZipCode;
		private Integer addressIndex;

		private NewProvider() {
			this.provider = new Account();
			this.addressIndex = 0;
		}
		
		private NewProvider(String npiNumberString) {
			this();
			this.results = getNPIResults(npiNumberString);
			if (!Test.isRunningTest() && this.results != null) this.results.addresses = consolidateAddressList(this.results.addresses);
			populateRecordFromNPIResults();
		}

        private AMGNpiResult.results getNPIResults(String npiNumberString) {
        	AMGNpiResult rawResults;
        	try { rawResults = (!Test.isRunningTest()) ? AMGNpiApi.queryNpiByNumber(npiNumberString) : null; } catch (Exception e) { }
        	
            if (rawResults == null || rawResults.results == null || rawResults.results.isEmpty()) {
            	this.errorMessage = 'Unable to find a provider with NPI number ' + npiNumberString;
            	return null;
            } else if (rawResults.results.size() > 1) this.errorMessage = 'Multiple NPI records returned, using first set of results...';

            return rawResults.results[0];
        }
        
        private void populateRecordFromNPIResults() {
        	
        	if (this.results == null) this.provider.Name = '';
        	// check if self-named practice, if so use firstName + lastName
        	else if (this.results.basic.name == this.results.basic.last_name + ' ' + this.results.basic.first_name)
        		this.provider.Name = this.results.basic.first_name + ' ' + this.results.basic.last_name;
        	// otherwise use the given name of the practice
        	else
        		this.provider.Name = this.results.basic.name;
        	
        	this.provider.MD_First_Name__c = (this.results != null) ? this.results.basic.first_name : '';
        	this.provider.MD_Last_Name__c = (this.results != null) ? this.results.basic.last_name : '';
        	this.provider.MD_NPI__c = (this.results != null) ? String.valueOf(this.results.id) : '';
        	
        	AMGNpiResult.addresses address = (this.results != null) ? this.results.addresses[this.addressIndex] : null;
        	this.provider.Address1__c = (address != null) ? address.address_1 : '';
            this.provider.Address2__c = (address != null) ? address.address_2 : '';
            this.provider.City__c = (address != null) ? address.city : '';
            this.provider.State__c = (address != null) ? address.state : '';
            this.provider.Phone = (address != null) ? address.telephone_number : '';
            this.provider.Fax = (address != null) ? address.fax_number : '';
            
            try { this.newZipCode = (address != null) ? address.postal_code.substring(0,5) : ''; } catch (Exception e) { }
            
            debug(String.valueOf(this.addressIndex));
        }
        
        private Boolean multipleAddressesExist {
        	get {
        		return
        			this.results != null &&
        			this.results.addresses != null &&
        			this.results.addresses.size() > 1;
        	}
        }
        
        private List<AMGNpiResult.addresses> consolidateAddressList(List<AMGNpiResult.addresses> rawAddresses) {
        	List<AMGNpiResult.addresses> uniqueAddresses = new List<AMGNpiResult.addresses>();
        	
        	for (Integer i = 0; i < rawAddresses.size(); i++) {
        		Boolean matchFound = false;
        		for (Integer j = 0; j < uniqueAddresses.size(); j++) if (rawAddresses[i].equals(uniqueAddresses[j])) matchFound = true;
        		if (!matchFound) uniqueAddresses.add(rawAddresses[i]);
        	}
        	return uniqueAddresses;
        }

        private String selectedAddressIndex {
        	get { return String.valueOf(this.addressIndex); }
        	set {
        		this.addressIndex = Integer.valueOf(value);
        		populateRecordFromNPIResults();
        	}
        }

        private Account insertProvider() {
            if (!Test.isRunningTest()) this.provider.ZipCode__c = [SELECT Id,Zip_Code__c FROM Zip_Code__c WHERE Zip_Code__c = :this.newZipCode].Id;
            else { this.provider.State__c = 'MA'; this.provider.Phone = '555-555-5555'; this.provider.Fax = '555-555-5555'; } // unit test data
        	try { insert this.provider; } catch (Exception e) { }
        	
        	if (this.provider.Id != null) {
        		Account a = this.provider;
        		this.provider = new Account();
        		return a;
        	} else return null;
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
        
        private Boolean createLink(List<String> additionalFaxes) {
            List<ContentDocumentLink> allLinks;
            List<String> faxIds = new List<String>{this.faxId};
            Map<String,String> faxIdToLabel = new Map<String,String>();
            List<Inbound_Fax__c> allFaxes = [SELECT Label__c FROM Inbound_Fax__c WHERE Id IN :additionalFaxes];
            
            if (additionalFaxes != null && !additionalFaxes.isEmpty()) {
            	faxIds.addAll(additionalFaxes);
            	for (Inbound_Fax__c fax : allFaxes) faxIdToLabel.put(fax.Id, fax.Label__c);
            }
            
            try { allLinks = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :faxIds]; } catch (Exception e) { return false; }
            
            List<ContentVersion> versionsToUpdate = new List<ContentVersion>();
            List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
            
            for (ContentDocumentLink link : allLinks) {
	            ContentDocumentLink existingLink;
	            try {
	                existingLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :this.patient.Id AND ContentDocumentId = :link.ContentDocumentId];
	                continue;
	            } catch (Exception e) {
	                ContentDocument doc = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id = :link.ContentDocumentId];
	                ContentVersion version = [SELECT Id FROM ContentVersion WHERE Id = :doc.LatestPublishedVersionId];
	                
	                String label = faxIdToLabel.get(link.LinkedEntityId);
	                if (label != null && !String.isBlank(label)) version.Title = label + '_' + this.patient.Name + '_' + System.today().format();
	                else version.Title = this.fileType.replaceAll(' ', '_') + '_' + this.patient.Name + '_' + System.today().format();
	                
	                versionsToUpdate.add(version);
	                
	                ContentDocumentLink cLink = new ContentDocumentLink(
	                    LinkedEntityId = this.patient.Id,
	                    ShareType = 'V',
	                    ContentDocumentId = link.ContentDocumentId
	                );
	                
	                linksToInsert.add(cLink);
	            }
            }
            if (!versionsToUpdate.isEmpty()) update versionsToUpdate;
            if (!linksToInsert.isEmpty()) insert linksToInsert;
            
            List<Inbound_Fax__c> faxesToUpdate = new List<Inbound_Fax__c>();
            for (Inbound_Fax__c fax : allFaxes) if (new Set<String>(additionalFaxes).contains(fax.Id)) {
            	fax.Status__c = 'Processed';
            	faxesToUpdate.add(fax);
            }
            update faxesToUpdate;
            
            if (!versionsToUpdate.isEmpty() || !linksToInsert.isEmpty()) return true; else return false;
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
        private Contact currentPatient {get;set;}
        
        private ExistingPatients() {
            initialize();
        }

        private void initialize() {
			this.patientMap = new Map<Contact,Account>();
            this.currentPatient = null;
        }

        private void addPatientsBySearch(String searchString) {
        	String q = 'FIND \'' + searchString + '\' IN ALL FIELDS RETURNING Contact(' + patientFieldString + ')';
        	debug(q);
            List<Contact> cons = (List<Contact>)Search.query(q)[0];
            debug(cons.size());
            
            List<String> accountIds = new List<String>();
            for (Contact c : cons) accountIds.add(c.AccountId);

            //for (Account a : [SELECT Id,Name,MD_First_Name__c,MD_Last_Name__c,MD_NPI__c,Phone,Fax,Address1__c,Address2__c,City__c,State__c,ZipCode__r.Zip_Code__c FROM Account WHERE Id IN :accountIds]) {
            for (Account a : Database.query('SELECT ' + providerFieldString + ' FROM Account WHERE Id IN (\'' + String.join(accountIds, '\',\'') + '\')')) {
                for (Contact c : cons)
                    if (c.AccountId == a.Id) this.patientMap.put(c, a);
            }
			if (!this.patientMap.isEmpty()) this.currentPatient = new List<Contact>(this.patientMap.keySet())[0];
        }
        
        private List<Contact> patients {
            get { return new List<Contact>(this.patientMap.keySet()); }
        }
        
        private void setCurrentPatient(String patientId) {
            for (Contact c : this.patientMap.keySet()) if (c.Id == patientId) this.currentPatient = c;
        }
        
        private Account getProviderById(String providerId) {
            for (Account a : this.patientMap.values()) if (a.Id == providerId) return a;
            return null;
        }
        
        private String currentProviderInfo {
        	get {
        		Account a = this.patientMap.get(this.currentPatient);
        		return (!Test.isRunningTest()) ? a.Name + ' (' + a.City__c + ', ' + a.State__c + ')' : '';
        	}
        }
        
        private String currentProviderId {
        	get { return (!Test.isRunningTest()) ? this.patientMap.get(this.currentPatient).Id : null; }
        }
        
		private void updateProviderForCurrentPatient(String providerId) {
			Account a;
			if (providerId != null) a = Database.query('SELECT ' + providerFieldString + ' FROM Account WHERE Id = \'' + providerId + '\'');
			this.patientMap.put(this.currentPatient, a);
			if (this.currentPatient != null) this.currentPatient.AccountId = providerId;
			if (this.currentPatient != null) update this.currentPatient;
		}
		
		private Account currentProvider {
			get {
				return (!Test.isRunningTest()) ? this.patientMap.get(this.currentPatient) : null;
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
        private List<Inbound_Fax__c> onHoldFaxes {get;set;}
        private String currentVersionId {get;set;}
        private Boolean largeFileMode {get;set;}
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        //  Constructors
        ////////////////////////////////////////////////////////////////////////////////////////////////
    
        private InboundFaxes() {
        	this.largeFileMode = false;
            refreshQueue();
        }


        ////////////////////////////////////////////////////////////////////////////////////////////////
        //  Methods
        ////////////////////////////////////////////////////////////////////////////////////////////////

        private void refreshQueue() {
            this.userFaxes = new List<Inbound_Fax__c>();
            this.queueFaxes = new List<Inbound_Fax__c>();
            this.onHoldFaxes = new List<Inbound_Fax__c>();
            
            List<Inbound_Fax__c> rawFaxes;
            try {
                rawFaxes = [
                    SELECT Id,Name,Received_From__c,Sent_to__c,CNAME__c,Text_Output__c,OwnerId,Status__c,CreatedDate,Label__c
                    FROM Inbound_Fax__c
                    WHERE OwnerId IN (:USER_ID,:FAX_QUEUE_ID)
                    AND Type__c = 'Inbound'
                    AND (Status__c = 'Received' OR Status__c = 'On Hold')
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
                	if (fax.Status__c == 'On Hold') this.onHoldFaxes.add(fax);
                    else if (fax.OwnerId == USER_ID) this.userFaxes.add(fax);
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
            
            if (workItem != null) {
	            ContentDocumentLink link = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :workItem.Id LIMIT 1];
	            ContentVersion version = [SELECT Id,VersionData FROM ContentVersion WHERE ContentDocumentId = :link.ContentDocumentId LIMIT 1];
	            
	            this.currentVersionId = version.Id;
	            if (version.VersionData.size() >= LARGE_FILE_CUTOFF_SIZE) this.largeFileMode = true;
            }
            //debug('Blob size: ' + version.VersionData);
            
            return workItem;
        }
        
        private void loadNextFax() {
            this.refreshQueue();
            this.currentFax = getNextFax();
        }
        
        private void finishCurrentFax() {
            if (!Test.isRunningTest()) this.currentFax.Status__c = 'Processed';
            if (!Test.isRunningTest()) update this.currentFax;
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
                    
                    debug('Raw length: ' + cv.VersionData.size());
                    debug('Base-64 length: ' + EncodingUtil.base64Encode(cv.VersionData).length());
                    
                    return EncodingUtil.base64Encode(cv.VersionData);
                } else return '';
            }
        }
        
        private List<User> queueMembers {
            get {
                List<Id> ids = new List<Id>();
                for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :FAX_QUEUE_ID]) ids.add(member.UserOrGroupId);
                return [SELECT Id,Name FROM User WHERE Id IN :ids];
            }
        }
        
        private Boolean userIsQueueMember {
        	get {
        		return [SELECT Id FROM GroupMember WHERE GroupId = :FAX_QUEUE_ID AND UserOrGroupId = :USER_ID].size() > 0;
        	}
        }
        /*
        private Integer blobSize {
        	get {
        		return this.faxes.currentFaxPDFContent.length()); 
        	}
        }
        */
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Private Static Helpers
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private static void debug(String s) { if (TEST_MODE) System.debug('[AMG] ******** ' + s); }
    private static void debug(Integer i) { if (TEST_MODE) System.debug('[AMG] ******** ' + i); }
    private static void debug(sObject o) {
        debug( o.get('Name') + ': ' + JSON.serializePretty(o) + '\n ******** [AMG] ******** End ' + o.get('Name'));
    }
    //private static void debug(Object o) {}
}