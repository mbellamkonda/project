/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */
 
@isTest
public class AMGInboundFaxesControllerTest {

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

            AMGInboundFaxesController ctrl = new AMGInboundFaxesController();
            ctrl.resetTestData();
            ctrl.userSearch = 'Test';
            ctrl.doSearch();
            ctrl.resetSearch();
            ctrl.toggleNewAccountMode();
            ctrl.newAccountNPI = 'Test';
            
            ctrl.doNPISearch();
			List<AMGInboundFaxesController.npiResult> npiResults = ctrl.npiResults;
			Integer newAccountSelectedIndex = ctrl.newAccountSelectedIndex;
			Boolean newProviderSelected = ctrl.newProviderSelected;
			String selectedNewProviderName = ctrl.selectedNewProviderName;
			String selectedNewProviderFirstName = ctrl.selectedNewProviderFirstName;
			String selectedNewProviderLastName = ctrl.selectedNewProviderLastName;
            
            ctrl.loadNextFax();
            
            ctrl.toggleConfirmDetails();
			String patientNameForLink = ctrl.patientNameForLink;
			String providerNameForLink = ctrl.providerNameForLink;
			Boolean attachButtonDisabled = ctrl.attachButtonDisabled;
			String fileType = ctrl.fileType;
            
            
            ctrl.fileType = 'Test';

            //System.debug('Controller: ' + JSON.serializePretty(ctrl));
        
            ctrl.unusableFax();
            ctrl.newCurrentAccountId = '001000000000000';
            ctrl.setCurrentAccount();

            ctrl.insertNewLink();
            ctrl.dummy();
            
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
			String newAccountURL = ctrl.newAccountURL;
			Boolean errorExists = ctrl.errorExists;
			String backgroundColor1 = ctrl.backgroundColor1;
			String backgroundColor2 = ctrl.backgroundColor2;
			List<SelectOption> availavbleFileTypes = ctrl.availavbleFileTypes;


        }
    }
}