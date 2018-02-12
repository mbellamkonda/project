/* Copyright (C) Acuity Management Group, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by James Glaubiger <james@acuitymg.com>
 */

public class AMGNpiResult{
    public Integer result_count {get;set;}  //1
    public results[] results {get;set;}
    public AMGNpiResult() { }
    public AMGNpiResult(String testName) {
        this.results = new List<results>{new results(testName)};
        this.results[0].addresses = new List<addresses>{new addresses(testName)};
    }
    public AMGNpiResult(results results, addresses addresses) {
        this.results = new List<results>{results};
        this.results[0].addresses = new List<addresses>{addresses};
    }
    public class results {
        public taxonomies[] taxonomies {get;set;}
        public addresses[] addresses {get;set;}
        public Integer created_epoch {get;set;} //1249430400
        public identifiers[] identifiers {get;set;}
        public other_names[] other_names {get;set;}
        public Integer id {get;set;}    //1245461417
        public Integer last_updated_epoch {get;set;}    //1386201600
        public basic basic {get;set;}
        public String enumeration_type {get;set;}   //NPI-1
        public results(String name) {
            this.basic = new basic();
            this.basic.name = name;
            this.basic.first_name = name;
            this.basic.last_name = name;
        }
    }
    public class taxonomies {
        public String state {get;set;}  //MA
        public String code {get;set;}   //207V00000X
        public boolean primary {get;set;}
        public String license {get;set;}    //254044
        public String description {get;set;}    //Obstetrics & Gynecology
    }
    public class addresses {
        public String city {get;set;}   //SOMERVILLE
        public String address_2 {get;set;}  //3RD FLOOR
        public String telephone_number {get;set;}   //617-629-6330
        public String fax_number {get;set;} //617-629-6128
        public String state {get;set;}  //MA
        public String postal_code {get;set;}    //021442705
        public String address_1 {get;set;}  //40 HOLLAND ST
        public String country_code {get;set;}   //US
        public String country_name {get;set;}   //United States
        public String address_type {get;set;}   //DOM
        public String address_purpose {get;set;}    //LOCATION
        public addresses() {  }
        public addresses(String name) {
            this.city = name;
            this.address_2 = name;
            this.telephone_number = name;
            this.fax_number = name;
            this.state = name;
            this.postal_code = name;
            this.address_1 = name;
            this.country_code = name;
            this.country_name = name;
            this.address_type = name;
            this.address_purpose = name;
        }
    }
    public class identifiers {
        public String code {get;set;}   //08
        public String issuer {get;set;} //
        public String state {get;set;}  //MA
        public String identifier {get;set;} //003353601
        public String description {get;set;}    //MEDICARE PIN
    }
    public class other_names {
    }
    public class basic {
        public String status {get;set;} //A
        public String credential {get;set;} //M.D.
        public String first_name {get;set;} //JUSTIN
        public String last_name {get;set;}  //RASNER
        public String middle_name {get;set;}    //NEAL
        public String name {get;set;}   //RASNER JUSTIN
        public String sole_proprietor {get;set;}    //NO
        public String gender {get;set;} //M
        public String last_updated {get;set;}   //2013-12-05
        public String name_prefix {get;set;}    //DR.
        public String enumeration_date {get;set;}   //2009-08-05
    }
    public static AMGNpiResult parse(String json){
        return (AMGNpiResult) System.JSON.deserialize(json.replace('"desc"','"description"').replace('"number"', '"id"'), AMGNpiResult.class);
    }
}