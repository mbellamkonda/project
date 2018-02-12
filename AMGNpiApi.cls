/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

public class AMGNpiApi {
	public static AMGNpiResult queryNpiByNumber(String npiNumber) {
		HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint('https://npiregistry.cms.hhs.gov/api?number=' + npiNumber);
        req.setMethod('GET');

        try {
            res = http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
        
        return AMGNpiResult.parse(res.getBody());
	}
}