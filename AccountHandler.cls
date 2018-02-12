public class AccountHandler {

 public void validateProviderandFax(List < Account > lstAccount, map < id, Account > triggerOldMap, string action) {
  set < string > setNPA = new set < string > ();
  set < string > setFax = new set < string > ();

  string recordTypePROVIDER = CommanClass.findRecordTypeForOrderProduct('Account', 'Providers');
  string recordTypePHARMACY = CommanClass.findRecordTypeForOrderProduct('Account', 'Pharmacy');

  if (action == 'insert') {
   for (Account oAccount: lstAccount) {
    if (oAccount.recordTypeid == recordTypePROVIDER) {
     if (oAccount.MD_NPI__c != null) {
      setNPA.add(oAccount.MD_NPI__c);
     }

    }

    if (oAccount.recordTypeid == recordTypePHARMACY) {
     if (oAccount.Fax != null) {
      setFax.add(oAccount.Fax);
     }

    }

   }
  }


  if (action == 'update') {
       for (Account oAccount: lstAccount) {
       
            if (oAccount.recordTypeid == recordTypePROVIDER) {
                 if (oAccount.MD_NPI__c != null && triggerOldMap.get(oAccount.id).MD_NPI__c != oAccount.MD_NPI__c) {
                  setNPA.add(oAccount.MD_NPI__c);
                 }
        
            }
        
            if (oAccount.recordTypeid == recordTypePHARMACY ) {
                 if (oAccount.Fax != null && triggerOldMap.get(oAccount.id).Fax != oAccount.Fax ) {
                      setFax.add(oAccount.Fax);
                 }
        
            }
    
       }
  }

  System.debug('setFax ==='+setFax);
  map < String, Account > mapNPA = new map < String, Account > ();
  map < String, Account > mapFax = new map < String, Account > ();

  if (setNPA.size() > 0) {
       for (Account oA: [SELECT id, recordtypeid, name, MD_NPI__c from Account where MD_NPI__c in : setNPA AND recordtypeid = : recordTypePROVIDER]) {
            mapNPA.put(oA.MD_NPI__c + oA.recordtypeid, oA);
       }
  }

  if (setFax.size() > 0) {
       for (Account oA: [SELECT id, recordtypeid, name, fax from Account where Fax in : setFax AND recordtypeid = : recordTypePHARMACY]) {
            mapFax.put(oA.fax, oA);
       }
    
  }


  if (mapNPA.size() > 0) {
   for (Account oAccount: lstAccount) {
    if (oAccount.recordTypeid == recordTypePROVIDER) {
     if (oAccount.MD_NPI__c != null && mapNPA.get(oAccount.MD_NPI__c + oAccount.recordtypeid) != null) {
          try{
              oAccount.addError('This NPI Number already exist on the account :' + mapNPA.get(oAccount.MD_NPI__c + oAccount.recordtypeid).name);
            }catch(exception e){}
     }

    }
   }
  }

  if (mapFax.size() > 0) {
   for (Account oAccount: lstAccount) {
    if (oAccount.recordTypeid == recordTypePHARMACY) {
     if (oAccount.fax != null && mapFax.get(oAccount.Fax) != null) {
         try{
             oAccount.addError('This Fax Number already exist on the account :' + mapFax.get(oAccount.Fax).name);
           }catch(exception e){}
     }

    }
   }
  }


 }



}


//=======================