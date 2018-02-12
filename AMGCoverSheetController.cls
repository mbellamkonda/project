public class AMGCoverSheetController {
	
	public AMGCoverSheetController(AMGPatientController c) { this(); }
	
	public AMGCoverSheetController() {
		this.prescriptionFormAttached = (getParameter('prescriptionFormAttached') == 'true') ? true : false ;
		this.biResultsAttached = (getParameter('biResultsAttached') == 'true') ? true : false ;
		this.paFormAttached = (getParameter('paFormAttached') == 'true') ? true : false ;
		this.copayAssistanceApproved = (getParameter('copayAssistanceApproved') == 'true') ? true : false ;
		this.appealInformationAttached = (getParameter('appealInformationAttached') == 'true') ? true : false ;
		
		this.paStatus = getParameter('paStatus');
		this.submittedDate  = getParameter('submittedDate');
		this.caseNumber = getParameter('caseNumber');
		this.approvedDateBegin = getParameter('approvedDateBegin');
		this.approvedDateEnd = getParameter('approvedDateEnd');
		this.otherReason = getParameter('otherReason');
		this.appealStatus = getParameter('appealStatus');
		this.subject = getParameter('subject');
		this.caseDeniedReason = getParameter('caseDeniedReason');
		
		this.ppID = getParameter('ppID');
		this.ppPCN = getParameter('ppPCN');
		this.ppBIN = getParameter('ppBIN');
		this.ppGROUP = getParameter('ppGROUP');
		
		this.dbcCARD = getParameter('dbcCARD');
		this.dbcEXP = getParameter('dbcEXP');
		this.dbcCVC = getParameter('dbcCVC');
		
		this.recipientName = getParameter('recipientName');
    	this.recipientFax = getParameter('recipientFax');
    	this.recipientPhone = getParameter('recipientPhone');
		
		this.pageCount = (getParameter('pageCount') != null) ? Integer.valueOf(getParameter('pageCount')) : 1;
		//System.debug('**** This: ' + JSON.serialize(this));
	}
	
    public Boolean prescriptionFormAttached {get;set;}
    public Boolean biResultsAttached {get;set;}
    public Boolean paFormAttached {get;set;}
    public String paStatus {get;set;}
    public String submittedDate  {get;set;}
    public String caseNumber {get;set;}
    public String approvedDateBegin {get;set;}
    public String approvedDateEnd {get;set;}
	public String caseDeniedReason {get;set;}
    public Boolean copayAssistanceApproved {get;set;}
    
	public String ppID {get;set;}
	public String ppPCN {get;set;}
	public String ppBIN {get;set;}
	public String ppGROUP {get;set;}
	
	public String dbcCARD {get;set;}
	public String dbcEXP {get;set;}
	public String dbcCVC {get;set;}
    
    public String otherReason {get;set;}
    public Boolean appealInformationAttached {get;set;}
    public String appealStatus {get;set;}
    public Integer pageCount {get;set;}
    
    public Boolean isPaStatus { get { return !String.isBlank(paStatus); } }
    public Boolean otherReasonExists { get { return !String.isBlank(otherReason); } }
    public String todayDate { get { return System.today().format(); } }
    public Boolean isAppealStatus { get { return !String.isBlank(appealStatus); } }
    public String subject {get;set;}
    
    public String recipientName {get;set;}
    public String recipientFax {get;set;}
    public String recipientPhone {get;set;}
        
    private String getParameter(String s) {
    	return ApexPages.currentPage().getParameters().get(s);
    }
}