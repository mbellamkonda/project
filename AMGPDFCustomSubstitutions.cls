global class AMGPDFCustomSubstitutions {
	
	global class AdditionalComments implements amgpdfgen.Substitution {
	    global Set<String> getIncludedFields() {
	    	return new Set<String>{'Additional_Comments__c'};
	    }
	    global String substitute(String text, amgpdfgen.ParentRecord record, amgpdfgen.Template template){
	    	Case c = (Case)record.record;
	    	if (String.isBlank(c.Additional_Comments__c)) {
	    		//String textToReplace = '<tr><td style="border: 1px solid #222; background: #222; color: #eee;" colspan="2"><h4 style="margin: 3px; padding-left: 10px;">Additional Comments</h4></td></tr><tr><td style="border: 1px solid #ccc;" colspan="2">{!Additional_Comments__c}</td></tr>';
	    		//String textToReplace = '<tr>.+?</tr>';
	    		String textToReplace = '<tr>\\s*<td style="border: 1px solid #222; background: #222; color: #eee;" colspan="2">\\s*<h4 style="margin: 3px; padding-left: 10px;">Additional Comments</h4>\\s*</td>\\s*</tr>\\s*';
	    		textToReplace += '<tr>\\s*<td style="border: 1px solid #ccc;" colspan="2">.*?</td>\\s*</tr>';
	    		
	    		//'<tr>\\s*<td style="border: 1px solid #ccc;" colspan="2">[^<]+</td>\\s*</tr>';
	    		text = text.replaceAll(textToReplace, '');
	    	}
	    	return text;
	    }
	}
	
	global class FieldLabels implements amgpdfgen.Substitution {
	    global Set<String> getIncludedFields() {
	    	return new Set<String>{'Id'};
	    }
	    global String substitute(String text, amgpdfgen.ParentRecord record, amgpdfgen.Template template){
	    	sObject o = record.record;
			Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
			
			String objectName = '';
			for(Schema.SObjectType objectInstance : gd.values())
				if(objectInstance.getDescribe().getKeyPrefix() == String.valueOf(o.Id).subString(0,3))
					objectName = objectInstance.getDescribe().getName();

			Map<String, Schema.SObjectField> fieldMap = gd.get(objectName).getDescribe().fields.getMap();
			
			// do the subs
			/*

            */
			
			String label = fieldMap.get('CaseNumber').getDescribe().getLabel();
	    	return text;
	    }
	}
	
	/*
	private static String functionWithParameter(String functionName, String text) {
		String regexFunctionName = '';
		for (Integer i = 0; i < functionName.length(); i++) {
			regexFunctionName += '[' + functionName.mid(i, 1).toLowerCase() + functionName.mid(i, 1).toUpperCase() + ']';
		}
		
		Matcher m = Pattern.compile(regexFunctionName + '\\(([^)]+)\\)').matcher(text);
        if (m.find()) {
            do {
                try {
                	text = text.replaceAll(m.group(0).replaceAll('\\(', '\\\\(').replaceAll('\\)', '\\\\)'), m.group(1).split('-')[2].split(' ')[0]);
                } catch (Exception e) { }
            } while (m.find());
        }
        return text;
	}
	*/
}