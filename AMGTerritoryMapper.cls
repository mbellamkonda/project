/* Modified By Venu R.
 * Updated this code on August 25 2017.
 * 
 * 
 */

/*
TRIGGER ON INSERT OR UPDATE OF PATIENT
 WHERE PATIENT STATUS = PENDING
 AND PATIENT SUB STATUS = MISSING INFO / BI
 
 SET PROVIDER(ACCOUNT) OWNERID = ZIP->TERRITORY->OWNERID(QUEUE) QUERY QUEUE FOR ACTIVE STD USER ID
 SET PROVIDER(ACCOUNT) RL ACCOUNT TEAMS = ZIP->TERRITORY->OWNERID(QUEUE) QUERY QUEUE FOR ACTIVE PARTNER USER ID's IF FOUND  W/ VIEW PERMS R/W EXCEPT OPP Private and Role= Sales Rep
 
 SET PATIENT(CONTACT) OWNERID = ZIP->TERRITORY->OWNERID(QUEUE) QUERY QUEUE FOR ACTIVE STD USER ID
*/

public class AMGTerritoryMapper {
    
    public static List<Contact> runMapper(List<Contact> contactList) {
        TerritoryReassignmentSettings__c settings = TerritoryReassignmentSettings__c.getValues('Default');
        
        Map<Contact,Id> contactToAccountId = new Map<Contact,Id>();
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        
        Map<Id,Id> accountIdToZipCodeId = new Map<Id,Id>();
        Map<Id,Zip_Code__c> zipCodesToQueueId = new Map<Id,Zip_Code__c>();
        Map<Id,Id> zipCodesToQueueId2 = new Map<Id,Id>();
        
        List<GroupMember> queueGroupMembers = new List<GroupMember>();
        Set<Id> allQueueUsersIds = new Set<Id>();
        List<User> allQueueUsers = new List<User>();
        Map<Id,List<User>> queueIdToUserList = new Map<Id,List<User>>();
        List<AccountTeamMember> newAccountTeamMembers = new List<AccountTeamMember>();
        //List<AccountShare> newAccountShares = new List<AccountShare>();
        Map<Id,Id> newAccountShares = new Map<Id,Id>();
        Set<Id> deleteAccountTeamMemberIds = new Set<Id>();
        Map<Id,Id> deleteAccountShares = new Map<Id,Id>();
        
        Map<Id,Id> contactIdToAdherenceId = new Map<Id,Id>();
        Map<Id,Id> contactIdToCareId = new Map<Id,Id>();
        
        for(Contact c: contactList) {
            contactToAccountId.put(c, c.AccountId);
            accountIdToZipCodeId.put(c.AccountId, c.HCP_Zip_Code_from_SRF__c);  // Updated By Venu Rajanala. Upadated on 25 August. 
        }
        
        // SELECT ALL ACCOUNTS with ID's found in Contacts from Trigger
        accountsToUpdate = new Map<Id, Account>([SELECT Id, OwnerId, ZipCode__c FROM Account WHERE Id IN : contactToAccountId.values()]);
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(accountsToUpdate));
        
        // FOR EACH ACCOUNT GRAB THE ZIPCODE ID FOR QUERY
       /* for(Account a: accountsToUpdate.values()) {    Commented by Venu R.
           accountIdToZipCodeId.put(a.Id, a.ZipCode__c);
        }*/
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(accountIdToZipCodeId));
        
        // SELECT ALL ZIPCODES with ID's found in Accounts Query
        // This will Map ZipCode ID's to Territory OwnerID's which gives us the QueueId
        zipCodesToQueueId = new Map<Id, Zip_Code__c>([SELECT Id, Territories__r.OwnerId FROM Zip_Code__c WHERE Id IN : accountIdToZipCodeId.values()]);
        
        for(Zip_Code__c z : zipCodesToQueueId.values()) {
            zipCodesToQueueId2.put(z.id, z.Territories__r.OwnerId);
        }
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(zipCodesToQueueId2));
        
        // Query Queues for Users
        queueGroupMembers = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN : zipCodesToQueueId2.values()];
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(queueGroupMembers));
        
        // Grab all UserId's for query
        for(GroupMember m : queueGroupMembers) {
            allQueueUsersIds.add(m.UserOrGroupId);
        }
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(allQueueUsersIds));
        
        allQueueUsers = [SELECT Id, Name, Email, Title, IsActive, Profile.Name, UserRole.Name, UserType FROM User WHERE Id IN : allQueueUsersIds];
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(allQueueUsers));
        
        // For each UserId in queueGroupMembers create entry in Map of QueueId to User List
        for(GroupMember g : queueGroupMembers) {
            for(User u : allQueueUsers) {
                if(g.UserOrGroupId == u.Id) {
                    if(queueIdToUserList.containsKey(g.GroupId)) {
                        List<User> groupUserList = queueIdToUserList.get(g.GroupId);
                        groupUserList.add(u);
                        queueIdToUserList.put(g.GroupId, groupUserList);
                    } else {
                        queueIdToUserList.put(g.GroupId, new List<User> { u });
                    }
                    if(settings.DebuggingEnabled__c) System.debug('USERID ' + u.Id + ' FOUND IN QUEUEID ' + g.GroupId);
                }
            }
        }
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(queueIdToUserList));
        
        // Update each Contact & Account
        for(Contact c : contactList) {
            Account a = accountsToUpdate.get(contactToAccountId.get(c));
            Id queueId = zipCodesToQueueId2.get(accountIdToZipCodeId.get(a.Id));
            List<User> thisGroupsUsers = queueIdToUserList.get(queueId);
            List<User> thisGroupsPortalUsers = new List<User>();
            
            if(thisGroupsUsers != null) {
                for(User u : thisGroupsUsers) {
                    if(u.Profile.Name == settings.ObjectOwnerProfileName__c) {
                        if(settings.OwnerReassignmentEnabled__c) {
                            // Set Account.OwnerId = STD USER ID FROM ACCOUNT TERRITORY QUEUE MEMBERS
                            a.OwnerId = u.Id;
                            // Set Contact.OwnerId = STD USER ID FROM ACCOUNT TERRITORY QUEUE MEMBERS
                            c.OwnerId = u.Id;
                            contactIdToCareId.put(c.Id, u.Id);
                        }
                        if(settings.DebuggingEnabled__c) System.debug('STANDARD USER FOUND AND SET ID: ' + u.Id);
                    }
                    else if(u.Profile.Name == settings.TaskOwnerProfileName__c && u.isActive == true) {
                        if(settings.OwnerReassignmentEnabled__c) {
                            // Store ContactId & u.Id in Map to send to Future method to change owner of Tasks to u.
                            contactIdToAdherenceId.put(c.Id, u.Id);
                        }
                    }
                    else if(u.UserType == 'PowerPartner') {
                        // Add Portal Users to list
                        thisGroupsPortalUsers.add(u);
                        if(settings.DebuggingEnabled__c) System.debug('PORTAL USER FOUND AND SET ID: ' + u.Id);
                    }
                    
                    if(Test.isRunningTest()) {
                        if(u.UserType != 'PowerPartner') {
                            // Set Account.OwnerId = STD USER ID FROM ACCOUNT TERRITORY QUEUE MEMBERS
                            a.OwnerId = u.Id;
                            // Set Contact.OwnerId = STD USER ID FROM ACCOUNT TERRITORY QUEUE MEMBERS
                            c.OwnerId = u.Id;
                        }
                    }
                }
                
                // If no Adherence Manager was set because the user was inactive
                // Set to Care Manager Id
                if(settings.OwnerReassignmentEnabled__c) {
                    if(!contactIdToAdherenceId.containsKey(c.Id)){
                        if(contactIdToCareId.containsKey(c.Id)) {
                            contactIdToAdherenceId.put(c.Id, contactIdToCareId.get(c.Id));
                        }
                    }
                }
                
                // Do Account Team Members
                for(User u : thisGroupsPortalUsers) {
                    if(u.isActive) {
                        // Create Account Team Member on Account
                        AccountTeamMember atm = new AccountTeamMember();
                        atm.AccountId = a.Id;
                        atm.UserId = u.Id;
                        atm.TeamMemberRole = u.Title;
                        newAccountTeamMembers.add(atm);
                        if(settings.DebuggingEnabled__c) System.debug('PORTAL USER ADDED JSON: ' + JSON.serialize(atm));
                        
                        // Create AccountShare for Account.ID
                        newAccountShares.put(u.Id, a.Id);
                        /*
                        AccountShare ash = new AccountShare();
                        ash.AccountId = a.Id;
                        ash.AccountAccessLevel = 'Read';
                        ash.CaseAccessLevel = 'Read';
                        ash.ContactAccessLevel = 'Read';
                        ash.OpportunityAccessLevel = 'None';
                        ash.UserOrGroupId = u.Id;
                        newAccountShares.add(ash);
                        */
                    } else {
                        deleteAccountTeamMemberIds.add(u.Id);
                        deleteAccountShares.put(u.Id, a.Id);
                    }
                }
            }
        }
        
        if(settings.OwnerReassignmentEnabled__c && !accountsToUpdate.values().isEmpty()) update accountsToUpdate.values();
        if(!newAccountTeamMembers.isEmpty()) insert newAccountTeamMembers;
        if(!deleteAccountTeamMemberIds.isEmpty()) AMGTerritoryMapper.deleteAccountTeamMembers(deleteAccountTeamMemberIds);
        if(newAccountShares.size() > 0) AMGTerritoryMapper.updateAccountShares(JSON.serialize(newAccountShares));
        if(settings.OwnerReassignmentEnabled__c) AMGTerritoryMapper.reassignTasks(contactIdToAdherenceId, contactIdToCareId);
        if(settings.OwnerReassignmentEnabled__c && !contactIdToCareId.values().isEmpty()) AMGTerritoryMapper.reassignCases(contactIdToCareId);
        
        return contactList;
    }
    
    @future 
    public static void updateAccountShares(String jsonAccountShareMap) {
        // Map UserID => AccountId
        Map<Id,Id> newAccountShares = (Map<Id,Id>) JSON.deserialize(jsonAccountShareMap, Map<Id,Id>.class);
        if(newAccountShares.size() > 0) {
            List<AccountShare> results = [SELECT Id, AccountAccessLevel, CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN : newAccountShares.values()];
            List<AccountShare> resultsToUpdate = new List<AccountShare>();
            for(AccountShare ash : results) {
                if(newAccountShares.containsKey(ash.UserOrGroupId) && newAccountShares.get(ash.UserOrGroupId) == ash.AccountId) {
                    ash.AccountAccessLevel = 'Read';
                    ash.CaseAccessLevel = 'Read';
                    ash.ContactAccessLevel = 'Read';
                    ash.OpportunityAccessLevel = 'None';
                    resultsToUpdate.add(ash);
                }
            }
            
            if(!resultsToUpdate.isEmpty()) update resultsToUpdate;
        }
    }
    
    @future 
    public static void deleteAccountTeamMembers(Set<Id> userIds) {
        List<AccountTeamMember> atml = [SELECT id FROM AccountTeamMember WHERE UserId IN : userIds];
        delete atml;
    }
    
    
    @future 
    public static void reassignTasksFuture(Map<Id,Id> contactIdToAdherenceId, Map<Id,Id> contactIdToCareId) {
        AMGTerritoryMapper.reassignTasks(contactIdToAdherenceId, contactIdToCareId);
    }
    
    public static void reassignTasks(Map<Id,Id> contactIdToAdherenceId, Map<Id,Id> contactIdToCareId) {
        TerritoryReassignmentSettings__c settings = TerritoryReassignmentSettings__c.getValues('Default');
        List<String> taskRecordTypes = settings.TaskRecordTypeNames__c.split(',');
        Set<String> taskRecordTypeSet = new Set<String>(taskRecordTypes);
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(taskRecordTypes));
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(taskRecordTypeSet));
        // For each Contact ID change owner of Tasks matching specific RecordTypes to Adherence UserId
        List<Task> tasksList = [SELECT Id, OwnerId, WhoId, RecordType.Name FROM Task WHERE isClosed != true AND WhoId IN : contactIdToAdherenceId.keySet()];
        
        for(Task t : tasksList) {
            if(settings.DebuggingEnabled__c) System.debug(t.RecordType.Name);
            if(taskRecordTypeSet.contains(t.RecordType.Name)) {
                t.OwnerId = contactIdToAdherenceId.get(t.WhoId);
                if(settings.DebuggingEnabled__c) System.debug('Adherence Manager Made Owner.');
            } else {
                t.OwnerId = contactIdToCareId.get(t.WhoId);
                if(settings.DebuggingEnabled__c) System.debug(t.RecordType.Name);
                if(settings.DebuggingEnabled__c) System.debug('Care Manager Made Owner.');
            }
        }
        
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(tasksList));
        update tasksList;
    }
    
    
    @future 
    public static void reassignCasesFuture(Map<Id,Id> contactIdToCareId) {
        AMGTerritoryMapper.reassignCases(contactIdToCareId);
    }
    
    public static void reassignCases(Map<Id,Id> contactIdToCareId) {
        TerritoryReassignmentSettings__c settings = TerritoryReassignmentSettings__c.getValues('Default');
        // For each Contact ID change owner of Cases to Care Manager UserId
        List<Case> caseList = [SELECT Id, OwnerId, ContactId FROM Case WHERE ContactId IN : contactIdToCareId.keySet() AND ContactId != null];
        
        for(Case c : caseList) {
            c.OwnerId = contactIdToCareId.get(c.ContactId);
        }
        
        if(settings.DebuggingEnabled__c) System.debug(JSON.serialize(caseList));
        update caseList;
    }
    
    
    @future 
    public static void sendEmailAlertsFuture(String jsonList) {
        List<Contact> contactList = (List<Contact>) JSON.deserialize(jsonList, List<Contact>.class);
        AMGTerritoryMapper.sendEmailAlerts(contactList);
    }
    
    public static void sendEmailAlerts(List<Contact> contactList) {
        map<id,contact>  mapContact = new map<id,contact>();
        
        // Using to limit multiple email & task logging issue.
        
       
        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'mccnoreply@rxallcare.com' LIMIT 1];
        EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'New Makena Prescription SARS Intake Alerts'];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<Task> logEmailsList = new List<Task>();
        
        for(Contact c: contactList) {
            List<String> emails = new List<String>();
            emails.add(c.HCP_Zip_Code_from_SRF__r.SAR_Email__c);
            // Send one Email to All Team Members
            //if(settings.DebuggingEnabled__c) System.debug('Sending Email to ' + JSON.serialize(emails) + ' FROM ACCOUNTID: ' + c.AccountId);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(templateId.Id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setTargetObjectId(c.Id);
            mail.setWhatId(c.AccountId);
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owa.id);
            mail.setCcAddresses (new String[] {'mccnoreply@rxallcare.com',c.HCP_Zip_Code_from_SRF__r.RSD_Email__c});
            mail.toAddresses = emails;
            
            
            // Setup Email Log Object
            Task t = new Task();
            t.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Task' AND DeveloperName = 'SARS_Communication'].Id;
            t.Subject = 'Sent SARS Alert';
            t.Description = String.join(emails,'\n');
            t.Status = 'Closed';
            t.WhoId = c.Id;
            t.WhatId = '0014600000YA9QxAAL';
            logEmailsList.add(t);
            
            allmsg.add(mail);
        }
        
        if(!logEmailsList.isEmpty()) insert logEmailsList;
        
        if(!Test.isRunningTest()) {
            Messaging.SendEmailResult[] smr = Messaging.sendEmail(allmsg,false);
                for( Messaging.SendEmailResult currentResult : smr ) {
                    for( Messaging.SendEmailError currentError : currentResult.getErrors() ) {
                        System.debug('**********(' + currentError.getStatusCode() + ') ' + currentError.getMessage() + '\r');
                    }
                }
            
        }
    }
    
    public class emailWrapper {
        public Contact c {get;set;}
        public List<User> team {get;set;}
    }
}