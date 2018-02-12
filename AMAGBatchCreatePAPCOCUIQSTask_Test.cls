@isTest 
public class AMAGBatchCreatePAPCOCUIQSTask_Test {
    @isTest 
    public static void doTest() {
      
      
    List<Contact> cs = new List<Contact>{
      new Contact(
        LastName = 'TEST_0',
        PT_Gest_Age_Date__c = System.today(),
        PT_Gest_Age_at_Enrollment__c = 16.1,
          Previous_Pre_Term_Birth__c = 'Yes',
          Currently_Pregnant_with_Singleton__c = 'Yes',
          Patient_Currently_on_Makena_or_17_P__c = '',
          Patient_Substatus__c = 'PA',
          Patient_Status__c='Pending'
 
        ),
      new Contact(
        LastName = 'TEST_1',
        PT_Gest_Age_Date__c = System.today(),
        PT_Gest_Age_at_Enrollment__c = 17.1,
          Previous_Pre_Term_Birth__c = 'Yes',
          Currently_Pregnant_with_Singleton__c = 'Yes',
          Patient_Currently_on_Makena_or_17_P__c = 'Yes',
            Patient_Substatus__c = 'COC',
          Patient_Status__c='Active'


        ),
      new Contact(
        LastName = 'TEST_3',
        PT_Gest_Age_Date__c = System.today(),
        PT_Gest_Age_at_Enrollment__c = 17.1,
          Previous_Pre_Term_Birth__c = '',
          Currently_Pregnant_with_Singleton__c = '',
          Patient_Currently_on_Makena_or_17_P__c = '',
          Patient_Substatus__c = 'Patient Non-Responsive',
          Patient_Status__c='Pending'
 

        ),
      new Contact(
        LastName = 'TEST_4',
        PT_Gest_Age_Date__c = System.today(),
        PT_Gest_Age_at_Enrollment__c = 19.1,
          Previous_Pre_Term_Birth__c = 'No',
          Currently_Pregnant_with_Singleton__c = '',
          Patient_Currently_on_Makena_or_17_P__c = '',
          Patient_Substatus__c = 'Shipment Requested',
          Patient_Status__c='Pending'

        ),
      new Contact(
        LastName = 'TEST_5',
        PT_Gest_Age_Date__c = System.today(),
        PT_Gest_Age_at_Enrollment__c = 18.1,
          Previous_Pre_Term_Birth__c = '',
          Currently_Pregnant_with_Singleton__c = 'No',
          Patient_Currently_on_Makena_or_17_P__c = '',
  Patient_Substatus__c = 'Patient Non-Responsive',
          Patient_Status__c='Pending'
          ),
      new Contact(
        LastName = 'TEST_6',
        PT_Gest_Age_Date__c = System.today(),
        PT_Gest_Age_at_Enrollment__c = 17.1,
          Previous_Pre_Term_Birth__c = 'Yes',
          Currently_Pregnant_with_Singleton__c = 'No',
          Patient_Currently_on_Makena_or_17_P__c = 'No',
          Patient_Substatus__c = 'HCP Withdrew',
          Patient_Status__c= 'DISCONTINUED')
    };
    
    
    insert cs;
   
    
    List<Task> logTaskList = new List<Task>();
    List<Contact> lstCons = new List<Contact>();
    Contact c = [SELECT Id,OwnerId,Meets_FDA_Indication__c FROM Contact WHERE Id = :cs[0].Id];
 lstCons = [SELECT Id,Name,OwnerId,Patient_Status__c,Patient_Substatus__c,Last_Ship_Date__c,Last_Ship_Date_Verbal__c,Current_Calculated_GA_as_of_TODAY__c,Patient_Created_Age__c FROM Contact where Meets_FDA_Indication__c ='On Label' AND Last_Ship_Date__c= null and Last_Ship_Date_Verbal__c =null AND ((Current_Calculated_GA_as_of_TODAY__c>=16 AND Patient_Created_Age__c >=5) OR Current_Calculated_GA_as_of_TODAY__c>=18 OR (Current_Calculated_GA_as_of_TODAY__c>=16 AND Patient_Created_Age__c >=10)) AND((Patient_Status__c <> 'Active' AND Patient_Substatus__c <> 'On Therapy') OR (Patient_Status__c <> 'Pending' AND Patient_Substatus__c <> 'COC') OR (Patient_Status__c <> 'Pending' AND Patient_Substatus__c <> 'PAP') OR Patient_Status__c <> 'Discontinued' OR Patient_Status__c <> 'Never Started' OR Patient_Status__c <> 'Complete')];
    
    for(Contact cnt:lstCons)
    {
    Task t = new Task();
    t.RecordTypeId = [SELECT Id from RecordType where sObjectType='Task' and Name='ACP Communication'].Id;
    t.subject= 'Needs Evaluation for PAP/COC/UI/QS';
    t.Status ='Open';
    t.WhoId= cnt.Id;
    t.OwnerId = cnt.OwnerId;
    t.ActivityDate = Date.TODAY();
    t.Priority = 'Normal';
    logTaskList.add(t); 
    }

    if(!logTaskList.isEmpty())
          insert logTaskList;
          
          Test.startTest();
          AMAGBatchCreatePAPCOCUIQSTask batch = new AMAGBatchCreatePAPCOCUIQSTask();
         database.executebatch(batch);
        Test.stopTest();

    
    }
    }