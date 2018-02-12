public class AMGPrintableRadioButtonController {
	public sObject theRecord {get;set;}
	public String fieldName {get;set;}
	
	public List<SelectOption> options {
		get {
			List<SelectOption> options = new List<SelectOption>();
			List<Schema.PicklistEntry> ple = Schema.getGlobalDescribe().get(String.valueOf(theRecord.getsObjectType())).getDescribe().Fields.getMap().get(fieldName).getDescribe().getPicklistValues();
			for (Schema.PicklistEntry f : ple) options.add(new SelectOption(f.getLabel(), f.getValue()));  
			return options;
		}
	}
}