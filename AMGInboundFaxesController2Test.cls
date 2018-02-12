/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by David Boyce <david@acuitymg.com> and James Glaubiger <james@acuitymg.com>
 */
 
@isTest
public class AMGInboundFaxesController2Test {

    @isTest 
    public static void doTest() {
    	
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
  
        User uA = new User(LastName='Apricot', Alias='Apricot', UserName = 'Apricot@Apricot.com.AMG2017TEST', Email='Apricot@Apricot.com',
          IsActive = true, ProfileId = UserInfo.getProfileId(), TimeZoneSidKey = TimeZone.getTimeZone('America/New York').getID(),
          LocaleSidKey = UserInfo.getLocale(), EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Title = 'Sales Rep');
        insert uA; 
    
        Group g = new Group();
        g.Name = 'Inbound Faxes';
        g.Type = 'Queue';
        insert g;
        
        QueueSobject qs = new QueueSobject();
        qs.QueueId = g.Id;
        qs.SobjectType = 'Inbound_Fax__c';
        System.runAs(uA) { insert qs; }

        GroupMember member = new GroupMember();
        member.UserOrGroupId = uA.Id;
        member.GroupId = g.Id;
        System.runAs(uA) { insert member; }

        final Integer FAX_LIST_SIZE = 5;

        System.runAs(uA) {

            List<ContentVersion> versions = new List<ContentVersion>();
            for (Integer i = 0; i < FAX_LIST_SIZE; i++) versions.add(new ContentVersion(Title = 'Test', PathOnClient = 'Test', VersionData = Blob.valueOf('Test'), Origin = 'H'));
            insert versions;
            versions = [SELECT ContentDocumentId FROM ContentVersion];
    
            List<Inbound_Fax__c> faxes = new List<Inbound_Fax__c>();
            for (Integer i = 0; i < FAX_LIST_SIZE; i++) faxes.add(new Inbound_Fax__c(OwnerId = g.Id, Processed__c = false, Unusable_Transmission__c = false));
            insert faxes;
    
            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
            for (Integer i = 0; i < FAX_LIST_SIZE; i++) links.add(new ContentDocumentLink(LinkedEntityId = faxes[i].Id, ShareType = 'V', ContentDocumentId = versions[i].ContentDocumentId));
            insert links;

            AMGInboundFaxesController2 ctrl = new AMGInboundFaxesController2();

            ctrl.userSearch = 'Test';
            ctrl.doSearch();
            ctrl.resetSearch();
            
            ctrl.newAccountNPI = 'Test';
            ctrl.doNPISearch();
            
            ctrl.newAccountNPI = '0123456789';
            ctrl.doNPISearch();
           
            
			Boolean newProviderSelected = ctrl.newProviderSelected;
            
            ctrl.loadNextFax();
            
            ctrl.newPatientFirstName = 'Test';
            ctrl.newPatientLastName = 'Test';
            ctrl.newCurrentPatientId = 'Test';

            ctrl.setCurrentPatient();

            ctrl.toggleConfirmDetails();
        
            
			String patientNameForLink = ctrl.patientNameForLink;
			String providerNameForLink = ctrl.providerNameForLink;
			Boolean attachButtonDisabled = ctrl.attachButtonDisabled;
			String fileType = ctrl.fileType;
            

            ctrl.fileType = 'Test';

            //System.debug('Controller: ' + JSON.serializePretty(ctrl));
        
            //ctrl.unusableFax();
            ctrl.newCurrentAccountId = '001000000000000';
            ctrl.setCurrentAccount();

            ctrl.insertNewLink();
            ctrl.dummy();
            
            ctrl.insertNewProvider();
            
            ctrl.updateProviderForCurrentPatient();
            
            ctrl.userPatientSearch = 'Test';
            ctrl.doPatientSearch();
            ctrl.resetPatientSearch();
            
			Inbound_Fax__c ibf = ctrl.ibf;
			Boolean hasFromFax = ctrl.hasFromFax;
			Boolean hasToFax = ctrl.hasToFax;
			Boolean hasCallerId = ctrl.hasCallerId;
			Boolean hasTextOutput = ctrl.hasTextOutput;
			Integer totalFaxCount = ctrl.totalFaxCount;
			Boolean pdfLoaded = ctrl.pdfLoaded;
			String pdfBlob = ctrl.pdfBlob;
			Set<Account> possibleAccounts = ctrl.possibleAccounts;
			List<Account> possibleAccountMatches = ctrl.possibleAccountMatches;
			Account currentAccount = ctrl.currentAccount;
			Map<String,String> patientCount = ctrl.patientCount;
			Boolean possibleAccountsFound = ctrl.possibleAccountsFound;
			List<Contact> possiblePatientMatches = ctrl.possiblePatientMatches;
			
			Decimal soqlLimitPercent = ctrl.soqlLimitPercent;
			Decimal rowLimitPercent = ctrl.rowLimitPercent;
			Decimal dmlLimitPercent = ctrl.dmlLimitPercent;
			String governorLimitStatus = ctrl.governorLimitStatus;
			//String newAccountURL = ctrl.newAccountURL;
			Boolean errorExists = ctrl.errorExists;
			String backgroundColor1 = ctrl.backgroundColor1;
			String backgroundColor2 = ctrl.backgroundColor2;
			List<SelectOption> availavbleFileTypes = ctrl.availavbleFileTypes;
			Boolean isTestMode = ctrl.isTestMode;
			
			String userPatientSearch = ctrl.userPatientSearch ;
			Boolean patientSearchPerformed = ctrl.patientSearchPerformed ;
			String newCurrentPatientId = ctrl.newCurrentPatientId ;
			String newProviderFirstNameQuick = ctrl.newProviderFirstNameQuick ;
			String newProviderLastNameQuick = ctrl.newProviderLastNameQuick ;
			Boolean agentConfirmation = ctrl.agentConfirmation ;
			String reassignValue = ctrl.reassignValue ;
			Boolean unauthorized = ctrl.unauthorized ;

			Integer userFaxCount = ctrl.userFaxCount;
			Integer queueFaxCount = ctrl.queueFaxCount;
			Boolean emptyQueue = ctrl.emptyQueue;
			List<Contact> possibleAccountPatientMatches = ctrl.possibleAccountPatientMatches;
			Contact currentPatient = ctrl.currentPatient;
			Boolean possiblePatientsFound = ctrl.possiblePatientsFound;
			String currentProviderInfo = ctrl.currentProviderInfo;
			String currentProviderId = ctrl.currentProviderId;
			Boolean npiResultsFound = ctrl.npiResultsFound;
			
			String nextFaxButtonLabel = ctrl.nextFaxButtonLabel;
			String existingPatientsButtonStyle = ctrl.existingPatientsButtonStyle;
			String existingProvidersButtonStyle = ctrl.existingProvidersButtonStyle;
			String npiRegistryButtonStyle = ctrl.npiRegistryButtonStyle;
			List<SelectOption> availableReassigns = ctrl.availableReassigns;
			String newProviderLinkId = ctrl.newProviderLinkId;
			String userName = ctrl.userName;
			
			String label = ctrl.otherLabel;
			Boolean availableOnHoldFaxesExist = ctrl.availableOnHoldFaxesExist;
			String currentVersionId = ctrl.currentVersionId;
			List<SelectOption> availableOnHoldFaxes = ctrl.availableOnHoldFaxes;
			Boolean largeFileMode = ctrl.largeFileMode;
			
			
			String newProviderName = ctrl.newProviderName;
			
			String newProviderNPI = ctrl.newProviderNPI;
			String newProviderFirstName = ctrl.newProviderFirstName;
			String newProviderLastName = ctrl.newProviderLastName;
			Boolean newProviderMultipleAddresses = ctrl.newProviderMultipleAddresses;
			String newProviderSelectedAddressIndex = ctrl.newProviderSelectedAddressIndex;
			String newProviderAddress1 = ctrl.newProviderAddress1;
			String newProviderAddress2 = ctrl.newProviderAddress2;
			String newProviderCity = ctrl.newProviderCity;
			String newProviderState = ctrl.newProviderState;
			String newProviderPhone = ctrl.newProviderPhone;
			String newProviderFax = ctrl.newProviderFax;
			String newProviderZipCode = ctrl.newProviderZipCode;
			/*
			List<SelectOption> newProviderAddresses = ctrl.newProviderAddresses;
			*/

            ctrl.resetTestData();
        }
    }
}