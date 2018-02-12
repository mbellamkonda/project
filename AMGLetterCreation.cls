global class AMGLetterCreation implements Database.Batchable<Contact>, Schedulable {
  
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Patient Section
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      
  //@future(callout=true) 
    global static void processPatients(String jsonTriggerNew, String jsonTriggerOldMap) {
      
      System.debug('******** Starting AMGLetterCreation.processPatients()');
      
      // Reconstruct trigger context variables
    List<Contact> triggerNew = (List<Contact>)JSON.deserialize(jsonTriggerNew, List<Contact>.class);
    Map<Id,Contact> triggerOldMap = (Map<Id,Contact>)JSON.deserialize(jsonTriggerOldMap, Map<Id,Contact>.class);
    
    // Documents we care about
    final List<String> letterTypes = new List<String>{
      'Welcome',
      'NonResponse',
      'Withdrawl'
    };
    
    // Initialize the patientMap
      Map<String,List<Contact>> patientMap = new Map<String,List<Contact>>();
      for (String letterType : letterTypes) patientMap.put(letterType, new List<Contact>());
      
      // Categorize work to be done
      for (Contact patient : triggerNew) {
        
        // Identify patients that need a Welcome Letter
        if (needsWelcomeLetter(patient, triggerOldMap.get(patient.Id))) patientMap.get('Welcome').add(patient);
        
        // Identify patients that need a Non-Repsonse Letter
        if (needsNonResponseLetter(patient, triggerOldMap.get(patient.Id))) patientMap.get('NonResponse').add(patient);
        
        // Identify patients that need a Withdrawl Letter
        //else if (needsWithdrawlLetter(patient, triggerOldMap.get(patient.Id))) patientMap.get('Withdrawl').add(patient);
      }
      
      //System.debug('WelcomeLetter' + JSON.serialize(patientMap.get('WelcomeLetter')));
      //System.debug('NonResponse' + JSON.serialize(patientMap.get('NonResponse')));
      //System.debug('Withdrawl' + JSON.serialize(patientMap.get('Withdrawl')));
      
    // For each document type iterate through the patients and flag for what is needed
    
      for (Contact patient : patientMap.get('Welcome')) {
        /*
        AMGUtilities.saveDocument(
          'WelcomeLetter' + '_' + patient.FirstName + '_' + patient.LastName + '_' + System.today().format() + '.pdf',
          (Test.IsRunningTest()) ? Blob.valueOf('TEST') : (new PageReference('/apex/LetterWelcomePatient?id=' + patient.Id)).getContentAsPDF(),
          patient.Id,
          true
        );
        */
        
        System.debug('******** Identified Welcome Letter needed');
        patient.Needed_Documents__c = (String.isBlank(patient.Needed_Documents__c)) ? 'Welcome Letter' : patient.Needed_Documents__c + ';Welcome Letter';
        update patient;
        
      }

      for (Contact patient : patientMap.get('NonResponse')) {
        /*
        AMGUtilities.saveDocument(
          'NonResponse' + '_' + patient.FirstName + '_' + patient.LastName + '_' + System.today().format() + '.pdf',
          (Test.IsRunningTest()) ? Blob.valueOf('TEST') : (new PageReference('/apex/LetterPatientNonResponse?id=' + patient.Id)).getContentAsPDF(),
          patient.Id,
          true
        );
        */
        
        System.debug('******** Identified Non-Response Letter needed');
        patient.Needed_Documents__c = (String.isBlank(patient.Needed_Documents__c)) ? 'Non-Response Letter' : patient.Needed_Documents__c + ';Non-Response Letter';
        update patient;
        
      }
      
      /*
      for (Contact patient : patientMap.get('Withdrawl')) {
        AMGUtilities.saveDocument(
          'Withdrawl' + '_' + patient.FirstName + '_' + patient.LastName + '_' + System.today().format() + '.pdf',
          (Test.IsRunningTest()) ? Blob.valueOf('TEST') : (new PageReference('/apex/LetterPatientWithdrawl?id=' + patient.Id)).getContentAsPDF(),
          patient.Id,
          true
        );
      }
      */
      
      System.debug('******** Finished AMGLetterCreation.processPatients()');
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    // Patient Private Helpers
    ///////////////////////////////////////////////////////////////////////////////////
    
    // Welcome Letter
    private static Boolean needsWelcomeLetter(Contact patientNew, Contact patientOld) {
      return
        (patientNew.Welcome_Kit_Requested__c != null && patientOld.Welcome_Kit_Requested__c == null) ||
      (
        (patientNew.Patient_Status__c == 'Active' && patientNew.Patient_Substatus__c == 'On Therapy') &&
        !(patientOld.Patient_Status__c == 'Active' && patientOld.Patient_Substatus__c == 'On Therapy')
      );
    }
    
    // Non-Response Letter
    private static Boolean needsNonResponseLetter(Contact patientNew, Contact patientOld) {
      return patientNew.Attempt__c == 2 && patientOld.Attempt__c != 2;
    }
    
    // Withdrawl Letter
    /*
    private static Boolean needsWithdrawlLetter(Contact patientNew, Contact patientOld) {
      return
        (patientNew.Patient_Status__c == 'Never Started' && 
        (
          patientNew.Patient_Substatus__c == 'Alternate Therapy' ||
          patientNew.Patient_Substatus__c == 'Social' ||
          patientNew.Patient_Substatus__c == 'Drug Safety Concerns'
        )
      ) &&
        !(patientOld.Patient_Status__c == 'Never Started' && 
        (
          patientOld.Patient_Substatus__c == 'Alternate Therapy' ||
          patientOld.Patient_Substatus__c == 'Social' ||
          patientOld.Patient_Substatus__c == 'Drug Safety Concerns'
        )
      );
    }
    */
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Case Section
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
  @future(callout=true) 
    global static void processCases(String jsonTriggerNew, String jsonTriggerOldMap) {
      
      System.debug('******** Starting AMGLetterCreation.processCases()');
      
      // Reconstruct trigger context variables
    List<Case> triggerNew = (List<Case>)JSON.deserialize(jsonTriggerNew, List<Case>.class);
    Map<Id,Case> triggerOldMap = (Map<Id,Case>)JSON.deserialize(jsonTriggerOldMap, Map<Id,Case>.class);
    
    String uiRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Urgent Initiation' LIMIT 1].Id;
    System.debug('******** RecordType Id: ' + uiRecordTypeId);
    
    List<Case> uiCases = new List<Case>();
    for (Case newCase : triggerNew) {
      Case oldCase = triggerOldMap.get(newCase.Id);
      if (
        (newCase.RecordTypeId == uiRecordTypeId && newCase.Status == 'Shipped') &&
        !(oldCase.RecordTypeId == uiRecordTypeId && oldCase.Status == 'Shipped')
      ) uiCases.add(newCase);
    }
    
    List<String> uiCaseIds = new List<String>();
    for (Case uiCase : uiCases) uiCaseIds.add(uiCase.Id);
    uiCases = [SELECT Id,Contact.FirstName,Contact.LastName FROM Case WHERE Id IN :uiCaseIds];
    
    for (Case uiCase : uiCases) {
        AMGUtilities.saveDocument(
          'UrgentInitiation' + '_' + uiCase.Contact.FirstName + '_' + uiCase.Contact.LastName + '_' + System.today().format() + '.pdf',
          (Test.IsRunningTest()) ? Blob.valueOf('TEST') : (new PageReference('/apex/LetterUrgentInitiation?id=' + uiCase.Id)).getContentAsPDF(),
          uiCase.Id,
          true
        );
    }

    System.debug('******** Finished AMGLetterCreation.processCases()');
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Batch Section
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
  global Iterable<Contact> start(database.batchablecontext BC) {
      return [SELECT Id,FirstName,LastName,Needed_Documents__c FROM Contact WHERE Needed_Documents__c != ''];
  }
  
  global void execute(Database.BatchableContext BC, List<Contact> scope) {
    for (Contact patient : scope) {
      List<String> docs;
      //System.debug('******** Needed during batch: ' + patient.Needed_Documents__c);
      try { docs = patient.Needed_Documents__c.split(';'); } catch (Exception e) { }
      if (docs == null) continue;
      for (String doc : docs) {
        
        if (doc == 'Welcome Letter') {
          System.debug('******** Creating Welcome Letter');
            AMGUtilities.saveDocument(
              'WelcomeLetter' + '_' + patient.FirstName + '_' + patient.LastName + '_' + System.today().format() + '.pdf',
              (Test.IsRunningTest()) ? Blob.valueOf('TEST') : (new PageReference('/apex/LetterWelcomePatient?id=' + patient.Id)).getContentAsPDF(),
              patient.Id,
              true
            );
            patient.Needed_Documents__c = patient.Needed_Documents__c.replaceAll('Welcome Letter', '');
            patient.Welcome_Letter_Issue_date__c = system.now();
        }
        
        else if (doc == 'Non-Response Letter') {
          System.debug('******** Creating Non-Response Letter');
            AMGUtilities.saveDocument(
              'NonResponse' + '_' + patient.FirstName + '_' + patient.LastName + '_' + System.today().format() + '.pdf',
              (Test.IsRunningTest()) ? Blob.valueOf('TEST') : (new PageReference('/apex/LetterPatientNonResponse?id=' + patient.Id)).getContentAsPDF(),
              patient.Id,
              true
            );
            patient.Needed_Documents__c = patient.Needed_Documents__c.replaceAll('Non-Response Letter', '');
            patient.Non_Response_Letter_Date_Time__c = system.now();
        }
        
        patient.Needed_Documents__c = patient.Needed_Documents__c.replaceAll('; ;', ';;').replaceAll(';;', ';').removeStart(';').removeEnd(';');
        update patient;
      }
    }
  }
  
  global void finish(Database.BatchableContext info) { }
  
  
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Schedulable Section
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    public static void start() {
      if(Test.isRunningTest()) System.schedule('AMGLetterGenerationTest', '0 0 * * * ?', new AMGLetterCreation());
      else {
        //Integer nextRun = System.now().minute() + 1;
        System.schedule('AMGLetterGeneration', '0 30 * * * ?', new AMGLetterCreation());
      }
    }

    global void execute(SchedulableContext ctx) {
        database.executebatch(new AMGLetterCreation(), 1);
    }
}