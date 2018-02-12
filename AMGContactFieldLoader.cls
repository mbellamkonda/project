public class AMGContactFieldLoader {
    public AMGContactFieldLoader(ApexPages.StandardController sc) {
    	List<String> fields = new List<String>{
			'FirstName',
			'LastName',
			'MiddleName',
			'BirthDate',
			'PT_Address1__c',
			'PT_City__c',
			'PT_State__c',
			'PT_ZipCode__r.Zip_Code__c',
			'HomePhone',
			'Phone',
			'MobilePhone',
			'Best_Time_to_Call__c',
			'Email',
			'PT_Language__c',
			'PBM_Name__c',
			'TMP_Picklist__c',
			'Preferred_Method_of_Contact__c'
    	};
		if (!Test.IsRunningTest()) sc.addFields(fields);
    }
}