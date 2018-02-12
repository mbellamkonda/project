/* Written by Venugopal R*/

global class AMAGBatchCreatePAPCOCUIQSTask implements Database.Batchable<Contact>{  

List<Contact> lstCons;
List<Task> logTasksList = new List<Task>();
List<Contact> logConstoUpdate = new List<Contact>();

global AMAGBatchCreatePAPCOCUIQSTask()
{
this.lstCons = [SELECT Id,Name,OwnerId,Patient_Status__c,PAP_Task_created__c,Patient_Substatus__c,Last_Ship_Date__c,Last_Ship_Date_Verbal__c,Current_Calculated_GA_as_of_TODAY__c,Patient_Created_Age__c FROM Contact where Meets_FDA_Indication__c ='On Label' AND Last_Ship_Date__c= null and Patient_Status__c != 'Active' and Patient_Status__c != 'Cancelled' and Last_Ship_Date_Verbal__c =null AND ((Current_Calculated_GA_as_of_TODAY__c>=16 AND Patient_Created_Age__c >=5) OR Current_Calculated_GA_as_of_TODAY__c>=18 OR (Current_Calculated_GA_as_of_TODAY__c>=16 AND Patient_Created_Age__c >=10)) AND Patient_Status__c not in('Never Started','Complete','Discontinued') AND (Patient_Status__c <> 'Active' or Patient_Substatus__c <> 'On Therapy') AND (Patient_Status__c <> 'Pending' or Patient_Substatus__c <> 'PAP') AND (Patient_Status__c <> 'Pending' OR Patient_Substatus__c <> 'COC') AND PAP_Task_created__c!=true AND Current_Calculated_GA_as_of_TODAY__c <=20.6 AND ID NOT IN(Select ContactId FROM CASE WHERE RecordType.Name IN('Urgent Initiation','Continuum of Care','Patient Assistance Program','Quick Start')) AND Copay_Only_Patient__c != 'Yes'];
}

global AMAGBatchCreatePAPCOCUIQSTask(List<Contact> contacts)
{
this.lstCons = contacts;
}


global Iterable<Contact> start(Database.BatchableContext BC)
{

return(lstCons);

}

global void execute(Database.BatchableContext BC,List<Contact> lstcnts)
{

System.debug('******** ExecuteContactListSize.' + lstCons.size() );
  for(Contact c:lstcnts)
  {
     if(!c.PAP_Task_created__c)
     {
    Task t = new Task();
    t.RecordTypeId = [SELECT Id from RecordType where sObjectType='Task' and Name='Evaluate for PAP/COC/UI/QS'].Id;
    t.subject= 'Needs Evaluation for PAP/COC/UI/QS';
    t.Status ='Open';
    t.WhoId= c.Id;
    t.OwnerId = c.OwnerId;
    t.ActivityDate = Date.TODAY();
    t.Priority = 'Normal';
    t.IsReminderSet = true;
    t.ReminderDateTime = Date.TODAY()+3;
    c.PAP_Task_created__c = true;
    logTasksList.add(t); 
    logConstoUpdate.add(c);
    }
  }
  
  if(!logTasksList.isEmpty())
     insert logTasksList;
     
     if(!logConstoUpdate.isEmpty())
     update logConstoUpdate;

}

 global void finish(Database.BatchableContext BC){
 }

 }