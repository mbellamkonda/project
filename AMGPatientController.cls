public class AMGPatientController {
  public Contact patient {get;set;}
  public Account provider {get;set;}
  public Account pharmacy {get;set;}
  public Account homeHealth {get;set;}
  public Case patientCase {get;set;}
  public Task patientTask {get;set;}
  public String providedId {get;set;}
  private AMGControllerExtension extension;
  private Makena_Contact_Information__c contactInfo;


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Constructors and Initializers
    ////////////////////////////////////////////////////////////////////////////////////////////////////

  public AMGPatientController(ApexPages.StandardController sc) {
    this.providedId = sc.getRecord().Id;
    initialize();
  }
  
  public AMGPatientController() {
    this.providedId = parameterId;
    initialize();
    //System.debug('**** Extension: ' + this.extension);
  }
  
  private void initialize() {
    // verify the provided Id and load the page extension, returning on fail of either
    if (!verifyProvidedId() && !Test.isRunningTest()) return;
    if (!loadExtension() && !Test.isRunningTest()) return;
    if (!loadContactInfo() && !Test.isRunningTest()) return;
    
    // determine the contact/patient Id
    if (providedIdType == 'Case') this.patientCase = Database.query('SELECT ' + requiredCaseFieldString + ' FROM Case WHERE Id = \'' + this.providedId + '\'');
    else if (providedIdType == 'Task') this.patientTask = Database.query('SELECT ' + requiredTaskFieldString + ' FROM Task WHERE Id = \'' + this.providedId + '\'');
    
    // retrieve the patient, provider, pharmacy, and home health records
    if (!loadContact() && !Test.isRunningTest()) return;
    
    loadProvider();
    loadPharmacy();
    loadHomeHealth();
    
    //if (!loadProvider() && !Test.isRunningTest()) return;
    //if (!loadPharmacy() && !Test.isRunningTest()) return;
    //if (!loadHomeHealth() && !Test.isRunningTest()) return;
  }

  private Boolean loadExtension() {
    try { this.extension = (AMGControllerExtension)Type.forName('AMGPatientController.' + pageName).newInstance(); return true; }
    catch (Exception e) { this.errorMessage = 'Unable to load extension "' + pageName + '"'; return false; }
  }
  
  private Boolean loadContact() {
    try { this.patient = Database.query('SELECT ' + requiredContactFieldString + ' FROM Contact WHERE Id = \'' + contactId + '\''); return true; }
    catch (Exception e) { this.errorMessage = 'Unable to retrieve Contact record with Id ' + contactId; return false; }
  }
  
  private Boolean loadProvider() {
    try { this.provider = Database.query('SELECT ' + requiredAccountFieldString + ' FROM Account WHERE Id = \'' + providerId + '\''); return true; }
    catch (Exception e) { return false; }
    //catch (Exception e) { this.errorMessage = 'Unable to retrieve Provider/Account record with Id ' + providerId + '.'; return false; }
  }

  private Boolean loadPharmacy() {
    try { this.pharmacy = Database.query('SELECT ' + requiredAccountFieldString + ' FROM Account WHERE Id = \'' + pharmacyId + '\''); return true; }
    catch (Exception e) { return false; }
    //catch (Exception e) { this.errorMessage = 'Unable to retrieve Pharmacy/Account record with Id ' + pharmacyId + '.'; return false; }
  }

  private Boolean loadHomeHealth() {
    try { this.homeHealth = Database.query('SELECT ' + requiredAccountFieldString + ' FROM Account WHERE Id = \'' + homeHealthId + '\''); return true; }
    catch (Exception e) { return false; }
    //catch (Exception e) { this.errorMessage = 'Unable to retrieve Home Health/Account record with Id ' + homeHealthId + '.'; return false; }
  }
  
  private Boolean loadContactInfo() {
    try { this.contactInfo = [SELECT Name,Phone__c,Fax__c FROM Makena_Contact_Information__c WHERE Name = 'Makena Care Connection']; return true; }
    catch (Exception e) { this.errorMessage = 'Unable to load public contact information from custom setting.'; return false; }
  }
  

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Public Properties
    ////////////////////////////////////////////////////////////////////////////////////////////////////

  public String errorMessage { get; set; }
  public Boolean errorExists { get { return !String.isBlank(this.errorMessage); } }
    
    public String mccPhone { get { return this.contactInfo.Phone__c; } }
    public String mccFax { get { return this.contactInfo.Fax__c; } }
    public String mccName { get { return this.contactInfo.Name; } }
    
  public String patientName { get { return this.patient.Name; } }
  public String patientDOB { get { return String.valueOf(this.patient.Birthdate); } }
  public String patientHUB {
    get {
      return (!String.isBlank(this.patient.Hub_Pt_ID__c) && this.patient.Hub_Pt_ID__c.substring(0,2) == '57')
        ? this.patient.Hub_Pt_ID__c
        : this.patient.Auto_Number__c;
    }
  }
  public String patientAddress1 { get { return this.patient.PT_Address1__c; } }
  public String patientAddress2 { get { return this.patient.PT_Address2__c; } }
  public String patientCity { get { return this.patient.PT_City__c; } }
  public String patientState { get { return this.patient.PT_State__c; } }
  public String patientZipCode { get { return this.patient.PT_ZipCode__r.Zip_Code__c; } }
  public Boolean patientAddress2Exists { get { return !String.isBlank(this.patient.PT_Address2__c); } }
    
  public String pharmacyName { get { return this.pharmacy.Name; } }
  public String pharmacyPhone { get { return this.pharmacy.Phone; } }
  public String pharmacyFax { get { return this.pharmacy.Fax; } }
  public String pharmacyContact { get { return this.pharmacy.Office_Primary_POC__c; } }

  public String providerName { get { return this.provider.Name; } }
  public String prescriberName { get { return this.provider.MD_First_Name__c + ' ' + this.provider.MD_Last_Name__c; } }
  public String providerPhone { get { return this.provider.Phone; } }
  public String providerFax { get { return this.provider.Fax; } }
  public String providerContact { get { return this.provider.Office_Primary_POC__c; } }
  public String providerAddress1 { get { return this.provider.Address1__c; } }
  public String providerAddress2 { get { return this.provider.Address2__c; } }
  public String providerCity { get { return this.provider.City__c; } }
  public String providerState { get { return this.provider.State__c; } }
  public String providerZipCode { get { return this.provider.ZipCode__r.Zip_Code__c; } }
  public Boolean providerAddress2Exists { get { return !String.isBlank(this.provider.Address2__c); } }

    public String testText { get { return '??????'; } }
    public String testPicklist { get { return 'Pending'; } }
    public Boolean testBoolean { get { return true; } }
    
    public String caseSafePatientId { get { return (!Test.isRunningTest()) ? AMGUtilities.ID15to18(String.valueOf(this.patient.Id)) : 'TEST'; } }
    public String caseSafeProviderId { get { return (!Test.isRunningTest()) ? AMGUtilities.ID15to18(String.valueOf(this.provider.Id)) : 'TEST'; } }
    public String caseSafePharmacyId { get { return (!Test.isRunningTest()) ? AMGUtilities.ID15to18(String.valueOf(this.pharmacy.Id)) : 'TEST'; } }
    public String caseSafeCaseId { get { return (!Test.isRunningTest()) ? AMGUtilities.ID15to18(String.valueOf(this.patientCase.Id)) : 'TEST'; } }
    public String caseSafeTaskId { get { return (!Test.isRunningTest()) ? AMGUtilities.ID15to18(String.valueOf(this.patientTask.Id)) : 'TEST'; } }
    public String caseCopayAmount {
      get {
        return (this.patientCase.Final_Patient_Copay__c != null) ? String.valueOf(this.patientCase.Final_Patient_Copay__c.setScale(2)) : '';
      }
    }
    
    public String providerAutoNumberId { get { return this.provider.AutoNumber__c; } }

  public Boolean isCase { get { return this.patientCase != null; } }
  public Boolean isTask { get { return this.patientTask != null; } }
  
  public String caseRecordTypeName { get { return this.patientCase.RecordType.Name; } }

    public Blob pdfContent {
      get { return (!Test.IsRunningTest()) ? ApexPages.currentPage().getContentAsPDF() : Blob.valueOf('TEST'); }
  }
  public String todayDate { get { return System.today().format(); } }
  
  public Boolean parameterIdMissing { get { return String.isBlank(this.providedId); } }
  public Boolean extensionMissing { get { return this.extension == null; } }
    
    public String pageName {
      get { return (!Test.isRunningTest()) ? ApexPages.currentPage().getUrl().split('apex/')[1].split('\\?')[0] : 'TEST'; }
    }
    
    public String shipToLocation {
      get {
        if (this.patient.Ship_To__c == 'HCP') return 'your healthcare provider';
        else if (this.patient.Ship_To__c == 'Patient') return 'your home address';
        else return '';
      }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Private Properties
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public String fileName { 
      get { return (!Test.isRunningTest()) ? pageName + '_-_' + this.patient.Name + '_[UNSIGNED].pdf' : 'TEST'; }
    }

    private List<String> requiredContactFields {
      get {
        List<String> ss = new List<String>(this.extension.getRequiredContactFields());
        ss.addAll(defaultContactFields);
        return new List<String>(new Set<String>(ss));
      }
    }
    
    private List<String> defaultContactFields {
      get { return new List<String>{'Id','AccountId','Pharmacy__c','Home_Health_Name__c'}; }
    }

    private String requiredContactFieldString {
      get { return String.join(requiredContactFields, ','); }
    }

  //
    private List<String> requiredAccountFields {
      get {
        List<String> ss = new List<String>(this.extension.getRequiredAccountFields());
        ss.addAll(defaultAccountFields);
        return new List<String>(new Set<String>(ss));
      }
    }
    
    private List<String> defaultAccountFields {
      get { return new List<String>{'Id','Name','Phone','Fax','Office_Primary_POC__c','POC_Fax_Number__c','POC_Phone_Number__c','AutoNumber__c'}; }
    }

    private String requiredAccountFieldString {
      get { return String.join(requiredAccountFields, ','); }
    }
  //

    private List<String> defaultCaseFields {
      get { return new List<String>{'Id', 'ContactId'}; }
    }

    private List<String> requiredCaseFields {
      get {
        List<String> ss = new List<String>(this.extension.getRequiredCaseFields());
        ss.addAll(defaultCaseFields);
        return new List<String>(new Set<String>(ss));
      }
    }

    private String requiredCaseFieldString {
      get { return String.join(requiredCaseFields, ','); }
    }

    private List<String> defaultTaskFields {
      get { return new List<String>{'Id', 'WhoId'}; }
    }

    private List<String> requiredTaskFields {
      get {
        List<String> ss = new List<String>(this.extension.getRequiredTaskFields());
        ss.addAll(defaultTaskFields);
        return new List<String>(new Set<String>(ss));
      }
    }

    private String requiredTaskFieldString {
      get { return String.join(requiredTaskFields, ','); }
    }

    private String parameterId {
      get { return ApexPages.currentPage().getParameters().get('id'); }
    }
    
    private String providedIdType {
      get { return (!Test.isRunningTest()) ? AMGUtilities.getRecordType(this.providedId) : 'TEST'; }
    }
    
    private Boolean isProvidedIdSet {
      get { return !String.isBlank(this.providedId); }
    }

  private String contactId {
    get {
      if (this.patientTask != null) return this.patientTask.WhoId;
      else if (this.patientCase != null) return this.patientCase.ContactId;
      else return this.providedId;
    }
  }
  
  private String providerId {
    get { return this.patient.AccountId; }
  }

  private String pharmacyId {
    get { return this.patient.Pharmacy__c; }
  }

  private String homeHealthId {
    get { return this.patient.Home_Health_Name__c; }
  }
  
  public String paStatus {
    get {
      try { return [SELECT Status FROM Case WHERE ContactId = :this.patient.Id AND RecordType.Name = 'Prior Authorization' LIMIT 1].Status; }
      catch (Exception e) { return ''; }
    }
  }
  

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Page Actions
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public void saveDocument() {
      saveDocumentPrivate(this.providedId);
       if(Id.valueOf(this.providedId).getSObjectType().getDescribe().getName() == 'Case'){
           updateContact(fileName, this.providedId);
       }
       
    }

    public void saveDocumentToPatient() {
      saveDocumentPrivate(contactId);
    }

  
    private void updateContact(String fileName, String recordId){
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Case'){
            Case oCase = [SELECT id,contactId from Case where id = : recordId];
            
            if(fileName.contains('LetterPatientAssistanceProgram')){
                contact oCon = new contact(id = oCase.contactId);
                oCon.PAP_Letter_Date_Time__c = system.now();
                update oCOn;
            }
            if(fileName.contains('LetterCopayAssistance')){
                contact oCon = new contact(id = oCase.contactId);
                oCon.Co_Pay_Letter_Date_Time__c = system.now();
                update oCOn;
            }
            
            
        }
        
    
    }
    
  public void dummy() { }


    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Private Helpers
    ////////////////////////////////////////////////////////////////////////////////////////////////////

  private Boolean verifyProvidedId() {
    if (!isProvidedIdSet) { this.errorMessage = 'Missing parameter ID'; return false; }
    else return true;
  }

    private void saveDocumentPrivate(String recordId) {
      AMGUtilities.saveDocument(
        this.fileName,
        (Test.IsRunningTest()) ? Blob.valueOf('TEST') : this.pdfContent,
        recordId,
        true
      );
    }
    

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Extension Interface
    ////////////////////////////////////////////////////////////////////////////////////////////////////
  
  public interface AMGControllerExtension {
    List<String> getRequiredContactFields();
    List<String> getRequiredAccountFields();
    List<String> getRequiredCaseFields();
    List<String> getRequiredTaskFields();
  }
  
  
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Inner Class Extensions
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public class CoverSheetPharmacy implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name','Birthdate','Auto_Number__c','Hub_Pt_ID__c'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() { return null; }
      public List<String> getRequiredTaskFields() { return null; }
    }
    
    public class CoverSheetProvider implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name','Birthdate','Auto_Number__c','Hub_Pt_ID__c'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() { return null; }
      public List<String> getRequiredTaskFields() { return null; }
    }
    
    public class CoverSheet implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name','Birthdate','Auto_Number__c','Hub_Pt_ID__c'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() { return null; }
      public List<String> getRequiredTaskFields() { return null; }
    }
    
    public class CoverSheetACP implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name','Birthdate','Auto_Number__c','Hub_Pt_ID__c'};
      }
      public List<String> getRequiredAccountFields() {
        return new List<String>{'Name','Phone'};
      }
      public List<String> getRequiredCaseFields() {
        return new List<String>{'Copay_ID__c'};
      }
      public List<String> getRequiredTaskFields() { return null; }
    }
    
    public class UnableToContact implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() { return null; }
      public List<String> getRequiredTaskFields() { return null; }
    }

    public class InsertDocuments implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() {
        return new List<String>{
          'RecordType.Name','Insurance_Coverage_Type__c','Insurance_Type__c','ID_Number_Listed_on_Form__c','Plan_Effective_Date__c',
          'Plan_Phone_Number__c','PBM_Name__c','Plan_Termination_Date__c','PBM_Phone_Number__c','PBM_Member_ID__c',
          'CPT_Code__c','PBM_Bin__c','PCN__c','Cardholder_Name_Listed_on_Form__c','ICD_10_Diagnosis__c','PBM_Group__c',
          'Secondary_Insurance__c','J_Code__c','Plan_Deductible_Individual_Amount__c','Plan_Amount_of_Deductible_Applied__c','Max_Ind__c',
          'Insurance_Plan__r.Name','Is_Makena_Covered_by_Plan__c','Is_Makena_Covered__c','Will_HCP_Buy_and_Bill__c',
          'Plan_In_Network_Pharmacy__r.Name','PBM_In_Network_Pharmacy__r.Name','PBM_Deductible_Individual_Amount__c',
          'PBM_Amount_of_Deductible_Applied__c','PBM_Max_Out_of_Pocket_Individual_Amount__c','Plan_Max_Out_of_Pocket_Applied__c',
          'Plan_Lifetime_Cap_Amount__c','PBM_Lifetime_Cap_Amount__c','Plan_Limitations__c','PBM_Limitations__c','Copay_Amount__c',
          'Coinsurance_Amount__c','Is_Pharmacy_Restricted__c','Optum_Home_Health_Covered__c','Other_Home_Health_Covered__c',
          'PA_Required__c','Pre_Determination_Required__c','Prior_Authorization_Dept_Phone_Number__c','PA_Dept_Phone_Number__c',
          'Prior_Authorization_Dept_Fax_Number__c','PA_Dept_Fax_Number__c','Plan_Appeal_LOMN_Required__c','PBM_Appeal_LOMN_Required__c',
          'Supporting_Documentation_Required__c','Status','PA_Approval_Effective_Date__c','PBM_Name_of_Restricted_Pharmacy__r.Name'
        };
      }
      public List<String> getRequiredTaskFields() { return null; }
    }

    public class HCPBIResults implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() {
        return new List<String>{
          'Insurance_Coverage_Type__c','Insurance_Type__c','ID_Number_Listed_on_Form__c','Plan_Effective_Date__c',
          'Plan_Phone_Number__c','PBM_Name__c','Plan_Termination_Date__c','PBM_Phone_Number__c','PBM_Member_ID__c',
          'CPT_Code__c','PBM_Bin__c','PCN__c','Cardholder_Name_Listed_on_Form__c','ICD_10_Diagnosis__c','PBM_Group__c',
          'Secondary_Insurance__c','J_Code__c','Plan_Deductible_Individual_Amount__c','Plan_Amount_of_Deductible_Applied__c','Max_Ind__c',
          'Insurance_Plan__r.Name','Is_Makena_Covered_by_Plan__c','Is_Makena_Covered__c','Will_HCP_Buy_and_Bill__c',
          'Plan_In_Network_Pharmacy__r.Name','PBM_In_Network_Pharmacy__r.Name','PBM_Deductible_Individual_Amount__c',
          'PBM_Amount_of_Deductible_Applied__c','PBM_Max_Out_of_Pocket_Individual_Amount__c','Plan_Max_Out_of_Pocket_Applied__c',
          'Plan_Lifetime_Cap_Amount__c','PBM_Lifetime_Cap_Amount__c','Plan_Limitations__c','PBM_Limitations__c','Copay_Amount__c',
          'Coinsurance_Amount__c','Is_Pharmacy_Restricted__c','Optum_Home_Health_Covered__c','Other_Home_Health_Covered__c',
          'PA_Required__c','Pre_Determination_Required__c','Prior_Authorization_Dept_Phone_Number__c','PA_Dept_Phone_Number__c',
          'Prior_Authorization_Dept_Fax_Number__c','PA_Dept_Fax_Number__c','Plan_Appeal_LOMN_Required__c','PBM_Appeal_LOMN_Required__c',
          'Supporting_Documentation_Required__c','Status','PA_Approval_Effective_Date__c','PBM_Name_of_Restricted_Pharmacy__r.Name'
        };
      }
      public List<String> getRequiredTaskFields() { return null; }
    }
    
    public class LetterCopayAssistance implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name','PT_Address1__c','PT_Address2__c','PT_City__c','PT_State__c','PT_ZipCode__r.Zip_Code__c'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() {
        return new List<String>{'Final_Patient_Copay__c'};
      }
      public List<String> getRequiredTaskFields() { return null; }
    }

    public class LetterPatientWithdrawl implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name'};
      }
      public List<String> getRequiredAccountFields() {
        return new List<String>{'MD_First_Name__c','MD_Last_Name__c','Address1__c','Address2__c','City__c','State__c','ZipCode__r.Zip_Code__c'};
      }
      public List<String> getRequiredCaseFields() {
        return null;
      }
      public List<String> getRequiredTaskFields() { return null; }
    }

    public class LetterUrgentInitiation implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name'};
      }
      public List<String> getRequiredAccountFields() {
        return new List<String>{'MD_First_Name__c','MD_Last_Name__c','Address1__c','Address2__c','City__c','State__c','ZipCode__r.Zip_Code__c'};
      }
      public List<String> getRequiredCaseFields() {
        return null;
      }
      public List<String> getRequiredTaskFields() { return null; }
    }
    
    public class LetterPatientNonResponse implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name','PT_Address1__c','PT_Address2__c','PT_City__c','PT_State__c','PT_ZipCode__r.Zip_Code__c'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() {
        return new List<String>{'Final_Patient_Copay__c'};
      }
      public List<String> getRequiredTaskFields() { return null; }
    }
    
    public class LetterWelcomePatient implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name','PT_Address1__c','PT_Address2__c','PT_City__c','PT_State__c','PT_ZipCode__r.Zip_Code__c'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() { return null; }
      public List<String> getRequiredTaskFields() { return null; }
    }
    
    public class LetterPatientAssistanceProgram implements AMGControllerExtension {
      public List<String> getRequiredContactFields() {
        return new List<String>{'Name','PT_Address1__c','PT_Address2__c','PT_City__c','PT_State__c','PT_ZipCode__r.Zip_Code__c','Ship_To__c'};
      }
      public List<String> getRequiredAccountFields() { return null; }
      public List<String> getRequiredCaseFields() { return null; }
      public List<String> getRequiredTaskFields() { return null; }
    }
}