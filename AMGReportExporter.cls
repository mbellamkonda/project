/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

global class AMGReportExporter implements System.Schedulable {
    global String testEmail {get;set;}
    
    global void execute(SchedulableContext sc) {
  		AMGReportExporter.processReports(testEmail);
    }
    
    @future(callout=true) 
    global static void processReports(String testEmail) {
    	// Grab CSV For each Report
        // https://rxallcare--amagdev.cs70.my.salesforce.com/00O46000003NNXa CONTACT
        // https://rxallcare--amagdev.cs70.my.salesforce.com/00O46000003NNYd CONTACT
        // https://rxallcare--amagdev.cs70.my.salesforce.com/00O46000003NNYY CASE
        List<String> reportUrls = new List<String>{'00O46000003NNXa', '00O46000003NNYd', '00O46000003NNYY'};
        Map<String,String> customFieldNames = new Map<String,String>();
        customFieldNames.put('Account.Account_ID__c','ACCOUNT_ID');
        
        customFieldNames.put('Contact.Patient_ID__c','CONTACT_ID');
        customFieldNames.put('Contact.Account_ID__c','ACCOUNT_ID');
        
        customFieldNames.put('Case.Account_ID__c','ACCOUNT_ID');
        customFieldNames.put('Case.Case_ID__c','CASE_ID');
        customFieldNames.put('Case.Patient_ID__c','CONTACT_ID');
        
        
    	// Create Attachment List to hold payload
		List<Messaging.EmailFileAttachment> attachmentsList = new List<Messaging.EmailFileAttachment>();
		
    	for(String url : reportUrls) {
        	// Get the report ID
			List<Report> reportList = [SELECT Id,DeveloperName FROM Report where Id =: url];
			String reportId = (String)reportList.get(0).get('Id');
			
			// Get the report metadata
			Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
			Reports.ReportMetadata reportMd = describe.getReportMetadata();
			
			// Override Row limits to get around 50001 Row Limit Error
			Reports.TopRows tr = new Reports.TopRows();
			Integer myRowLimit = 1;
			tr.setRowLimit(myRowLimit);
			tr.setDirection('ASCENDING');
			system.debug(tr);
			reportMd.setTopRows(tr);
			system.debug(tr);
			//Run Report with filter metadata
			Reports.ReportResults results = Reports.ReportManager.runReport(reportId, reportMd);
			
			// Get the report metadata and build a CSV header
			String csvHeader = '';
			for(String s : results.getReportMetadata().getDetailColumns()){
				System.debug('---> ' + s);
				if(customFieldNames.containsKey(s)) s = customFieldNames.get(s);
				csvHeader += '"' + s + '",';
			}
			csvHeader.removeEnd(',');
			csvHeader += '\n';
        	String csv = '';
        	if(!Test.isRunningTest()) {
		        ApexPages.PageReference report = new ApexPages.PageReference('/' + url + '?csv=1');
		        // Grab entire CSV minus header row and append
				csv = report.getContent().toString().substringAfter('\n');
        	}
	        
	        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
	        DateTime dt = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
	        String filename = (String)reportList.get(0).get('DeveloperName') + '.csv';
	        attachment.setFileName(filename.replace('YYYYMMDD', dt.format('yyyyMMdd')));
	        attachment.setBody(Blob.valueOf(csvHeader + csv));
	        attachment.setContentType('text/csv');
	        attachmentsList.add(attachment);
        }
        
        // Send the email with attachments
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(attachmentsList);
        message.setSubject('Shyft Report Exports ' + System.today());
        message.setPlainTextBody('The reports are attached.');
        if(testEmail != null) message.setToAddresses( new String[] { testEmail } );
        else message.setToAddresses( new String[] { 'scott.robinson@rxallcare.com' , 'Jane.McDonald@rxallcare.com' } );
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
    }
}