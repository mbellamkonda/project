/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

global class AMGInboundFaxEmail implements Messaging.InboundEmailHandler {
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope) {
  		
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		String url;
    	String username;
    	String password;
		
		if(!Test.isRunningTest()) {
			Outbound_Fax_Settings__c settings = [SELECT Endpoint__c,Username__c,Password__c FROM Outbound_Fax_Settings__c WHERE Name = 'Faxcom Live'];
	    	url = settings.Endpoint__c;
	    	username = settings.Username__c;
	    	password = settings.Password__c;
		} else {
			url = 'http://faxcom.acuitymg.com/FAXCOM_WS/FAXCOMService.asmx';
	    	username = 'webuser';
	    	password = 'amg123';
		}
		
		try {
        	if(email.binaryAttachments != null)
        	{
            	for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
              		// Attachment filename should contain ObjectId
              		// This needs to be refactored to use REGEX for cases where barcode exists and when it doesn't. 
              		String attachmentName = bAttachment.filename;
              		
              		List<ContentDocumentLink> links = new List<ContentDocumentLink>();
              		List<String> subject = email.subject.split(':');
              		String objectId;
              		String suffix;
					String fileName;
					Boolean isFound = false;
					              		
              		if(subject.size() > 1) {
              			// IF Inbound Email Subject Contains Barcode
              			objectId = subject[1].split('-')[0];
              			suffix = subject[1].split('-')[1];
              			
              			if(!Test.isRunningTest()) {
              				try {
		              			fileName = [SELECT Name FROM amgpdfgen__AMG_Customizable_Template__c WHERE amgpdfgen__Suffix__c =: suffix LIMIT 1].Name;
		              		
			              		fileName += '_' + [SELECT Contact.Name FROM Case WHERE Id =: objectId LIMIT 1].Contact.Name.replace(' ', '_');
			              		
			              		fileName += '_' + System.now().format('MM-dd-yyyy') + '.pdf';
			              		
			              		isFound = true;
              				} catch (Exception e) { filename = attachmentName; isFound = false; }
              			} else {
              				filename = attachmentName;
              				isFound = false;
              			}
              		} else {
              			// ELSE Inbound Email Contains NO Barcode
              			filename = attachmentName;
              			
              			// Additional Search steps to locate matching record
              		}
              		
          			// Callout to Faxcom API to get Metadata
          			String faxcomFilename = attachmentName.replace('.PDF', '.TIF').replace('.pdf', '.TIF');
          			string[] ids = new string[] {faxcomFilename};
			        FaxcomAPI faxcom = new FaxcomAPI(url);
			        FaxcomAPI.ReceivedMessageData[] apiRxMessages;
			        
			        try {
				        // The Username & Password should be set to the final destination fax inbox based on inbound faxcom workflow.
				        faxcom.LogIn(username, password);
				        apiRxMessages = faxcom.GetReceivedMessagesByIDs(ids, 'PDF');//(false, 0, true, 0, -1, 'PDF');
				        faxcom.ReleaseSession();
			        } catch (Exception e) {
			        	// Do nothing with exception
			        	System.Debug('---->>>> FAXCOM WEB SERVICES ERROR: ' + e.getMessage() + '\n\n For Filename: ' + faxcomFilename);
			        }
			        
			        integer size = (apiRxMessages != null) ? apiRxMessages.size() : 0;
			        
			        // Create Inbound Fax object and link up
              		Inbound_Fax__c ibf = new Inbound_Fax__c();
              		ibf.Type__c = 'Inbound';
	              	ibf.Status__c = 'Received';
	              	ibf.OriginalFileName__c = attachmentName;
			        
			        if(!Test.isRunningTest()) ibf.OwnerId = [SELECT Id FROM Group WHERE Name = 'Inbound Faxes' and Type = 'Queue' LIMIT 1].Id;
			        
			        System.Debug('size = ' + size);
			        if(size > 0) {
			            System.Debug('---->>>> ' + apiRxMessages[0].Metadata.DID + ' ' + apiRxMessages[0].Metadata.CallerID + ' ' + apiRxMessages[0].Metadata.TSI);
						
	              		ibf.CNAME__c = apiRxMessages[0].Metadata.TSI;
	              		ibf.Received_From__c = apiRxMessages[0].Metadata.CallerID;
	              		ibf.Sent_to__c = apiRxMessages[0].Metadata.DID;	
			        }
			        
			        insert ibf;
	              		
              		ContentVersion version = new ContentVersion(
				   		Title = fileName,
				   		PathOnClient = fileName,
				   		VersionData = bAttachment.body,
				   		Origin = 'H'
				  	);
				  
				  	insert version;
				  	
				  	version = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :version.Id];
				  	
				  	ContentDocumentLink ibfLink = new ContentDocumentLink(
				    	LinkedEntityId = ibf.Id,
				    	ShareType = 'V',
				    	ContentDocumentId = version.ContentDocumentId
				    );
				    
				    links.add(ibfLink);
				  	
				  	// If isFound = true create additional ContentDocumentLink to identified record
				  	if(isFound) {
					    ContentDocumentLink link = new ContentDocumentLink(
					    	LinkedEntityId = objectId,
					    	ShareType = 'V',
					    	ContentDocumentId = version.ContentDocumentId
					    );
					    
					    links.add(link);
				  	}
				  	
				  	insert links;
            	}
        	}
        	
			result.success = true;
      		result.message = ('Faxcom Inboud Fax Received and Attached to Record!');
    	} catch (Exception e) {
    		result.success = false;
      		result.message = 'Oops, I failed. Error : '+e.getMessage();
    	}
   		
    	return result;
	}
	
	/*
	global String getMCCZoneIdFromCallerId(String callerId) {
		String zoneId;
		// Format number for query
		String fax = this.formatNumber(callerId);
		// Attempt to find an account from CallerId
		Account a = [SELECT id, ZipCode__c FROM Account WHERE Fax =: fax LIMIT 1];
		
		if(a != null) {
			// We found an account by CallerId
			zoneId = [SELECT MCC_Zone__r.Id FROM Zip_Code__c WHERE Id =: a.ZipCode__c].MCC_Zone__r.Id;
		} else {
			// We could not find account by CallerId
			zoneId = [SELECT Id FROM MCC_Zone__c WHERE Name = 'Zone X' LIMIT 1].Id;
		}
		
		return zoneId;
	}
	*/
	
	global String formatNumber(String phone) {
		phone = phone.replaceAll('[^0-9]','');
		phone = '(' + phone.substring(0, 3) + ') ' + phone.substring(3, 6) + '-' + phone.substring(6, 10);
		return phone; 
	} 
}