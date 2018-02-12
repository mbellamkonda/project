public class AMGStatic {
	public static final Boolean DEBUG = true;
	/*
    @future(callout=true) 
    public static void generateAndEmailDocument(Id caseId) {
    	final String EMAIL_RECIPIENT = 'amag@druginfo.com';
    	
        Case c = [SELECT Id,CaseNumber,Case_ThreadId__c,Contact.FirstName,Contact.LastName FROM Case WHERE Id = :caseId];
        
        System.debug('******** Doing document generation.');
        amgpdfgen.Execute.generateDocument(String.valueOf(c.Id), 'AMAG Adverse Event', true, true);
        System.debug('******** Finished document generation.');
        
        ContentDocumentLink cdl = [SELECT id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: c.id LIMIT 1];
        System.debug('******** Link: ' + JSON.serialize(cdl));
        
        if(cdl != null) {
            ContentDocument pdf = [SELECT id, LatestPublishedVersionId FROM ContentDocument WHERE id =: cdl.ContentDocumentId];
            System.debug('******** Doc: ' + JSON.serialize(pdf));
            
            if(pdf != null) {
                ContentVersion contentVersion = [SELECT id, PathOnClient, VersionData, Origin FROM ContentVersion WHERE id =: pdf.LatestPublishedVersionId];
                System.debug('******** Version: ' + JSON.serialize(contentVersion));
                
                if(contentVersion != null) {
                    
                    ContentDistribution contentDistribution = new ContentDistribution();
                    contentDistribution.ContentVersionId = contentVersion.Id;
                    contentDistribution.Name = contentVersion.PathOnClient;
                    contentDistribution.PreferencesAllowOriginalDownload = true;
                    contentDistribution.PreferencesAllowPDFDownload = true;
                    contentDistribution.PreferencesAllowViewInBrowser = true;
                    contentDistribution.PreferencesLinkLatestVersion = true;
                    contentDistribution.PreferencesNotifyOnVisit = false;
                    contentDistribution.PreferencesExpires = true;
                    contentDistribution.ExpiryDate = System.today().addDays(7);
                    contentDistribution.PreferencesPasswordRequired = false;
                    contentDistribution.RelatedRecordId = c.id;
                    //contentDistribution.Password = 'AMAG';
                    insert contentDistribution;
                    
                    String url = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE id =: contentDistribution.id].DistributionPublicUrl;
                    
                    OrgWideEmailAddress fromAddress;
                    try { fromAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'mcc@rxallcare.com' LIMIT 1]; }
                    catch (Exception e) { }
                    
                    // Send Email
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    
					if (fromAddress != null) message.setOrgWideEmailAddressId(fromAddress.Id);
                    
                    // Set recipients to two contact IDs.
                    // Replace IDs with valid record IDs in your org.
                    message.toAddresses = new String[] {EMAIL_RECIPIENT};
                    message.optOutPolicy = 'FILTER';
                    message.subject = 'ADE-' + c.Contact.FirstName.subString(0,1) + c.Contact.LastName.subString(0,1) + '-' + System.today();
                    message.HtmlBody =
                    	'An Adverse Event has been reported. Please click on the link below and download the report; ' +
                    	'this link will expire in 7 days. If there are any issues or questions regarding this report, ' +
                    	'you may reply to this email or contact the Makena Care Connection team at (800) 847-3418. ' +
                    	'\n\n' + url + ' \n\n\n\n' + c.Case_ThreadId__c;
                    	
                    if (!Test.isRunningTest()) {
	                    Messaging.SingleEmailMessage[] emailList = new List<Messaging.SingleEmailMessage> {message};
	                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                                            
                    	// Log Email Sent
	                    EmailMessage emailMsg = new EmailMessage(ToAddress=(emailList[0].getToAddresses())[0], Subject=emailList[0].getSubject(),
		                    HtmlBody=emailList[0].getHtmlBody(), ParentId = c.Id, MessageDate = system.now(), Status = '3', Incoming = false);
	                    insert emailMsg;
                    }
                    
                }
            }
        }
    }
    */
    
    @future(callout=true) 
    public static void generateAndEmailDocument(Id caseId) {
    	final String EMAIL_RECIPIENT = 'amag@druginfo.com';
    	
        Case c = [SELECT Id,CaseNumber,Case_ThreadId__c,Contact.Auto_Number__c,Contact.FirstName,Contact.LastName FROM Case WHERE Id = :caseId];
        
        System.debug('******** Doing document generation.');
        amgpdfgen.Execute.generateDocument(String.valueOf(c.Id), 'AMAG Adverse Event', true, true);
        System.debug('******** Finished document generation.');
        
        ContentDocumentLink cdl = [SELECT id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: c.id LIMIT 1];
        System.debug('******** Link: ' + JSON.serialize(cdl));
        
        if(cdl != null) {
            ContentDocument pdf = [SELECT id, LatestPublishedVersionId FROM ContentDocument WHERE id =: cdl.ContentDocumentId];
            System.debug('******** Doc: ' + JSON.serialize(pdf));
            
            if(pdf != null) {
                ContentVersion contentVersion = [SELECT id, PathOnClient, VersionData, Origin FROM ContentVersion WHERE id =: pdf.LatestPublishedVersionId];
                System.debug('******** Version: ' + JSON.serialize(contentVersion));
                
                if(contentVersion != null) {
                    OrgWideEmailAddress fromAddress;
                    try { fromAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'mcc@rxallcare.com' LIMIT 1]; }
                    catch (Exception e) { }
                    
                    // Send Email
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    
					if (fromAddress != null) message.setOrgWideEmailAddressId(fromAddress.Id);
                    
                    // Set recipients to two contact IDs.
                    // Replace IDs with valid record IDs in your org.
                    message.toAddresses = new String[] {EMAIL_RECIPIENT};
                    message.optOutPolicy = 'FILTER';
                    //message.subject = 'ADE-' + c.Contact.Auto_Number__c + ' '+ c.Contact.FirstName.subString(0,1) + c.Contact.LastName.subString(0,1) + '-' + System.today();
                    message.subject = 'Case # - ADE #xxxxxx';
                    message.HtmlBody =
                    	'An Adverse Event has been reported. Please see the report attached to this email. ' +
                    	'If there are any issues or questions regarding this report, ' +
                    	'you may reply to this email or contact the Makena Care Connection team at (800) 847-3418. ' +
                    	' \n\n\n\n' + c.Case_ThreadId__c;
                    
                    // Set Email Attachment
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
					efa.setFileName(contentVersion.PathOnClient);
					efa.setBody(contentVersion.VersionData);
					message.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    	
                    if (!Test.isRunningTest()) {
	                    Messaging.SingleEmailMessage[] emailList = new List<Messaging.SingleEmailMessage> {message};
	                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                                            
                    	// Log Email Sent
	                    EmailMessage emailMsg = new EmailMessage(ToAddress=(emailList[0].getToAddresses())[0], Subject=emailList[0].getSubject(),
		                    HtmlBody=emailList[0].getHtmlBody(), ParentId = c.Id, MessageDate = system.now(), Status = '3', Incoming = false);
	                    insert emailMsg;
                    }
                    
                }
            }
        }
    }
    
    public static Boolean isDST(DateTime dt) {
	    //Date dtDate = dt.date();
	    Date dtDate = dt.dateGMT();
	    Date dtWeekStart = dtDate.toStartofWeek();
	    Integer yy = dt.year();
	    
	    Date beginDST = Date.newInstance(yy,03,Math.mod(Date.newInstance(yy,03,31).toStartofWeek().day(), 7) + 7);
		Date endDST = Date.newInstance(yy,11,Math.mod(Date.newInstance(yy,11,30).toStartofWeek().day(), 7));
	    
	    if (dtDate >= beginDST && dtDate <= endDST) return true;
	    else return false;
    }
    
    public static void updateFDAIndication(Contact c) {
		//System.debug('******** c: ' + JSON.serialize(c));
		
		// UPDATE Meets_FDA_Indication__c
		if (!isWithinGARange(c.Current_Calculated_GA_as_of_TODAY__c) && c.Patient_Currently_on_Makena_or_17_P__c != 'Yes') {
			//System.debug('Off Label #1, ' + c.Current_Calculated_GA_as_of_TODAY__c + ', ' + c.Patient_Currently_on_Makena_or_17_P__c);
			c.Meets_FDA_Indication__c = 'Off Label';
		} else if (c.Previous_Pre_Term_Birth__c == 'No') {
			//System.debug('Off Label #2');
			c.Meets_FDA_Indication__c = 'Off Label';
		} else if (c.Currently_Pregnant_with_Singleton__c == 'No') {
			//System.debug('Off Label #3');
			c.Meets_FDA_Indication__c = 'Off Label';
		}
		else if (c.Patient_Currently_on_Makena_or_17_P__c == 'Yes') {
			//System.debug('On Label #1');
			c.Meets_FDA_Indication__c = 'On Label';
		} else if (
				isWithinGARange(c.Current_Calculated_GA_as_of_TODAY__c) &&
    			c.Previous_Pre_Term_Birth__c == 'Yes' &&
    			c.Currently_Pregnant_with_Singleton__c == 'Yes'
    	) {
    		//System.debug('On Label #2');
    		c.Meets_FDA_Indication__c = 'On Label';
    	}
		else {
			//System.debug('Unable to Determine');
			c.Meets_FDA_Indication__c = 'Unable to Determine';
		}
		
		// UPDATE GA_From_Trigger__c
		c.GA_From_Trigger__c = c.Current_Calculated_GA_as_of_TODAY__c;
		if (c.GA_From_Trigger__c >= 13.0 && c.Patient_Status__c == 'Pending' && c.Patient_Substatus__c == 'Early GA') c.Patient_Substatus__c = 'BI';
    }
    
    private static Boolean isWithinGARange(Decimal d) {
    	final Decimal LOWER_BOUND = 16.0;
    	final Decimal UPPER_BOUND = 20.8;
    	System.debug('d: ' + d);
    	return d != null && d > LOWER_BOUND && d < UPPER_BOUND;
    }

}