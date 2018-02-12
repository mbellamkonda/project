/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */
 
@isTest
private class AMGNpiApiTest {

    static testMethod void myUnitTest() {
    	test.startTest();
    	
        String json=		'{'+
		'"result_count": 1,'+
		'"results": ['+
		'  {'+
		'"taxonomies": ['+
		'  {'+
		'"state": "MA",'+
		'"code": "207V00000X",'+
		'"primary": true,'+
		'"license": "254044",'+
		'"desc": "Obstetrics & Gynecology"'+
		'}'+
		'],'+
		'"addresses": ['+
		'  {'+
		'"city": "SOMERVILLE",'+
		'"address_2": "3RD FLOOR",'+
		'"telephone_number": "617-629-6330",'+
		'"fax_number": "617-629-6128",'+
		'"state": "MA",'+
		'"postal_code": "021442705",'+
		'"address_1": "40 HOLLAND ST",'+
		'"country_code": "US",'+
		'"country_name": "United States",'+
		'"address_type": "DOM",'+
		'"address_purpose": "LOCATION"'+
		'},'+
		'  {'+
		'"city": "BOSTON",'+
		'"address_2": "C/O NANCY SORDILLO",'+
		'"telephone_number": "617-421-6540",'+
		'"state": "MA",'+
		'"postal_code": "02109",'+
		'"address_1": "147 MILK STREET",'+
		'"country_code": "US",'+
		'"country_name": "United States",'+
		'"address_type": "DOM",'+
		'"address_purpose": "MAILING"'+
		'}'+
		'],'+
		'"created_epoch": 1249430400,'+
		'"identifiers": ['+
		'  {'+
		'"code": "08",'+
		'"issuer": "",'+
		'"state": "MA",'+
		'"identifier": "003353601",'+
		'"desc": "MEDICARE PIN"'+
		'}'+
		'],'+
		'"other_names": [],'+
		'"number": 1245461417,'+
		'"last_updated_epoch": 1386201600,'+
		'"basic": {'+
		'"status": "A",'+
		'"credential": "M.D.",'+
		'"first_name": "JUSTIN",'+
		'"last_name": "RASNER",'+
		'"middle_name": "NEAL",'+
		'"name": "RASNER JUSTIN",'+
		'"sole_proprietor": "NO",'+
		'"gender": "M",'+
		'"last_updated": "2013-12-05",'+
		'"name_prefix": "DR.",'+
		'"enumeration_date": "2009-08-05"'+
		'},'+
		'"enumeration_type": "NPI-1"'+
		'}'+
		']'+
		'}';
		
		AMGSingleRequestMock fakeResponse = new AMGSingleRequestMock(200,
                                                 'OK',
                                                 json,
                                                 null);
		
		Test.setMock(HttpCalloutMock.class, fakeResponse);
		
		AMGNpiResult result = AMGNpiApi.queryNpiByNumber('1245461417');
		
        test.stopTest();
    }
}