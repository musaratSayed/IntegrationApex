public class API_AuthorizeDotNet {
	//variables to hold login credentials
	public static String APILOGIN;
    public static String APITRANSKEY;
    
    public static void getAuthNetCreds()
    {
        Authorize_Net_Setting__c apiLoginSetting = Authorize_Net_Setting__c.getInstance('API Login');
        Authorize_Net_Setting__c apiTransKeySetting = Authorize_Net_Setting__c.getInstance('TransKey');
        
        System.debug('apiLoginSetting= '+apiLoginSetting);
        System.debug('apiTransKeySetting= '+apiTransKeySetting);
        
        APILOGIN=apiLoginSetting.Value__c;
        APITRANSKEY=apiTransKeySetting.Value__c;
        
        System.debug(APILOGIN);
        System.debug(APITRANSKEY);
    }

    public static authnetresp_wrapper authdotnetCharge(authnetreq_wrapper input)
    {
        getAuthNetCreds();
        
        //construct our request
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://test.authorize.net/gateway/transact.dll'); 
        req.setMethod('POST');
        
        //build message
        Map<String,String> messageString = new Map<String,String>();    
        messageString.put('x_login',APILOGIN);
        messageString.put('x_tran_key',APITRANSKEY);
        messageString.put('x_version','3.1');
		messageString.put('x_delim_data','TRUE');
        messageString.put('x_delim_char',';');
        messageString.put('x_relay_response','FALSE');
       //type of transaction
       messageString.put('x_type','AUTH_CAPTURE');
        //pass sfdc data
       messageString.put('x_method','CC');
       
       //transcation specific info from VF Page
       messageString.put('x_card_num',input.ccnum);
       messageString.put('x_exp_date',input.ccexp);
       messageString.put('x_card_code',input.ccsec);
        
       //transaction amount
       messageString.put('x_amount',input.amt);
        messageString.put('x_description','Your Txn'+input.ordername);
        
        //billing info from VF Page
        messageString.put('x_first_name',input.firstname);
        messageString.put('x_last_name',input.lastname);
        messageString.put('x_address',input.billstreet);
        messageString.put('x_city', input.billcity);
        messageString.put('x_state',input.billstate);
        messageString.put('x_zip',input.billzip);
        
        String encodeMsg='';
        
        for(String s:messageString.keyset() )
        {
            String v = messageString.get(s);
            //fix null values
            if(String.isBlank(v))
            {
                v= '';
            }
            else
            {
                encodeMsg+= s+ '='+EncodingUtil.urlEncode(v,'UTF-8')+'&';
            }
        }
        
        //add msg termination
        encodeMsg +='endofdata';
        system.debug('Encde ms: '+encodeMsg);
        req.setBody(encodeMsg);
        
        //send & collect response
        Http  http = new Http();
        String resp = http.send(req).getBody();
        System.debug('Response from Auhorize.net: '+resp);
        
        //split the response by delimite
   		List<String> responses=resp.split(';');
        AuthnetResp_Wrapper parsedResponse = parseIntoResponseWrapper(responses);
        return parsedResponse;
          
    }    
    
    public static AuthnetResp_Wrapper parseIntoResponseWrapper(List<String> input)
    {
        AuthnetResp_Wrapper temp = new AuthnetResp_Wrapper();
        
        temp.responseCode=input[0];
        temp.responseSubCode=input[1];
         temp.responseReasonCode=input[2];
      	 temp.responseReasonText =input[3];
        temp.authorizationCode =  input[4]; 
        temp.AVSResponse = input[5];
   	   temp.transactionID =input[6];
         temp.invoiceNumber =input[7];
        temp.description =input[8];
        temp.amount =input[9];
        temp.method =input[10];
        temp.transactionType =input[11];
        temp.customerID =input[12];
        temp.firstname=input[13];
        temp.company =input[14];
         temp.address =input[15];
        temp.city =input[16];
        temp.state=input[17];
        temp.zipcode=input[18];
        temp.country =input[19];
        temp.phone =input[20];
        temp.fax =input[21];
        temp.emailAddress =input[22];
        temp.shipToFirstName =input[23];
        temp.shipToLastName =input[24];
        temp.shipToCompany =input[25];
        temp.shipToCity =input[26];
        temp.shipToAddress =input[27];
        temp.shipToState =input[28];
        temp.shipToZipCode=input[29];
        temp.shipToCountry=input[30];
        temp.tax=input[31];
        temp.duty =input[32];
        temp.freight=input[33];
        temp.taxExempt=input[34];
        temp.purchaseOrderNumber=input[35];
        temp.MD5Hash=input[36];
        temp.cardCodeResponse=input[37];
        temp.cardHolderAuthenticationVerificationResponse =input[38];
        temp.accountNumber =input[39];
        temp.cardType =input[40];
        temp.splitTenderID =input[41];
        temp.requestedAmount =input[42];
 		temp.balanceonCard=input[43];
        
        return temp;
    }
    
    public class authnetreq_wrapper{
        public String ordername {get;set;}
        public String ccnum {get;set;}
        public String ccexp {get;set;}
        public String ccsec {get;set;}
        public String amt {get;set;}
        public String firstname {get;set;}
        public String lastname {get;set;}
        public String billstreet {get;set;}
        public String billcity {get;set;}
        public String billstate {get;set;}
        public String billzip {get;set;}
        public String transid {get;set;}
        public String routingnumber {get;set;}
        public String accountnumber {get;set;}
        public String bankaccounttype {get;set;}
        public String bankname {get;set;}
        public String bankaccountname {get;set;}
        
        public authnetreq_wrapper()
        {
            
        }
    }
    
    public class AuthnetResp_Wrapper{
        public string responseCode {get;set;}
        public string responseSubCode {get;set;}
        public string responseReasonCode {get;set;}
        public string responseReasonText {get;set;}
        public string authorizationCode {get;set;}
        public string AVSResponse {get;set;}
        public string transactionID {get;set;}
        public string invoiceNumber {get;set;}
        public string description {get;set;}
        public string amount {get;set;}
        public string method {get;set;}
        public string transactionType {get;set;}
        public string customerID {get;set;}
        public string firstname {get;set;}
        public string company {get;set;}
        public string address {get;set;}
        public string city {get;set;}
        public string state {get;set;}
        public string zipcode {get;set;}
        public string country {get;set;}
        public string phone {get;set;}
        public string fax {get;set;}
        public string emailAddress {get;set;}
        public string shipToFirstName {get;set;}
        public string shipToLastName {get;set;}
        public string shipToCompany {get;set;}
        public string shipToCity {get;set;}
        public string shipToAddress {get;set;}
        public string shipToState {get;set;}
        public string shipToZipCode {get;set;}
        public string shipToCountry {get;set;}
        public string tax {get;set;}
        public string duty {get;set;}
        public string freight {get;set;}
        public string taxExempt {get;set;}
        public string purchaseOrderNumber {get;set;}
        public string MD5Hash {get;set;}
        public string cardCodeResponse {get;set;}
        public string cardHolderAuthenticationVerificationResponse {get;set;}
        public string accountNumber {get;set;}
        public string cardType {get;set;}
        public string splitTenderID {get;set;}
        public string requestedAmount {get;set;}
        public string balanceonCard{get;set;}
        
        public AuthnetResp_Wrapper()
        {}
    }
}