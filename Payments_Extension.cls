public class Payments_Extension
{
	//payment__C record to hold payment info
    public Payment__c thisPayment {get;set;}
    public Statement__c thisStatement {get;set;}
    public boolean success {get;set;}
    Map<Id,String> recordTypeMap {get;set;}
    
    public Payments_Extension(ApexPages.StandardController scon)
    {
        if(scon.getRecord() instanceOf Statement__c)
        {
            thisStatement = [select id,name,rental_agreement__r.renter__c,balance__c
                            from Statement__c where ID =: scon.getId()];
        }
        
        success =false;
        
        recordTypeMap= new Map<Id,String>();
        
        //query for all the record types in payment object
        for(RecordType r : [select id,name from RecordType where sObjectType='Payment__c'])
        {
            recordTypeMap.put(r.Id,r.Name);
        }
        
        //instantiate the payment object
        thisPayment = new Payment__c();
        if(scon.getRecord() instanceOf Statement__c)
        {
            thisPayment.Statement__c = scon.getId();
            thisPayment.Amount__c=thisStatement.balance__c;
        }
        
        //if guest user , preset type to credit card
        if(getIsGuest())
        {
            for(id i:recordTypeMap.keySet())
            {
                if(recordTypeMap.get(i) == 'Credit Card')
                {
                    thisPayment.RecordTypeId = i;
                }
            }
        }
        else if(scon.getRecord() instanceOf Statement__c)
        {
           Contact renter= [select id,firstName,lastName,mailingStreet,mailingCity,mailingPostalCode,MailingState from Contact where id =: thisStatement.Rental_Agreement__r.Renter__c];
           thisPayment.Billing_City__c=renter.MailingCity;
           thisPayment.Billing_Postal_Code__c=renter.MailingPostalCode;
           thisPayment.Billing_State__c = renter.MailingState;
           thisPayment.Billing_Street__c = renter.MailingStreet;
           thisPayment.Billing_Name__c = renter.FirstName + ' ' + renter.LastName;
        }
    }
    
    //this method will process & Save our payments or report any errors
    public pageReference savePayment()
    {
        success =false;
        String paymentType =recordTypeMap.get(thisPayment.RecordTypeId);
        //validations
        
        if(validateFields(paymentType))
        {
            //process credit card payments
            
            if(paymentType=='Credit Card')
            {
                //create a request wrapper
                API_AuthorizeDotNet.authnetreq_wrapper req = new API_AuthorizeDotNet.authnetreq_wrapper();
                //set the wrapper values
                req.amt=String.valueOf(thisPayment.Amount__c);
                req.firstname=(thisPayment.Billing_Name__c.contains(' '))?thisPayment.Billing_Name__c.substringbefore(' '):thisPayment.Billing_Name__c;
                req.lastname=(thisPayment.Billing_Name__c.contains(' '))?thisPayment.Billing_Name__c.subStringAfter(' '):thisPayment.Billing_Name__c;
         		req.billstreet=thisPayment.Billing_Street__c;
                req.billcity=thisPayment.Billing_City__c;
                    req.billstate=thisPayment.Billing_State__c;
                    req.billzip=thisPayment.Billing_Postal_Code__c;
                
                //set credit card fields
               	req.ccnum=thisPayment.Credit_Card_Number__c;
 				req.ccsec=thisPayment.Credit_Card_Security_Card__c;
                req.ccexp=monthmap.get(thisPayment.Credit_Card_Expiration_month__c)+thisPayment.Expiration_Year__c;
                
                //give this req a name
                req.ordername='Payment of '+[Select Id,Name from Statement__c where Id =:thisPayment.Statement__c].name;
                
                //process our authorize.net request
                API_AuthorizeDotNet.authnetresp_wrapper res =API_AuthorizeDotNet.authdotnetCharge(req);
                
                thisPayment.Authorize_net_Transaction_Id__c = res.transactionID;
                thisPayment.Authorize_net_Authorization_code__c=res.authorizationCode;
                thisPayment.Authorize_net_Response__c=res.responseCode+ '|' + res.responseReasonText;
                
                //if transaction fails
                if(res.responseCode!='1' || res.responseReasonText != 'This transaction has been approved.')
                {
                    thisPayment.Status__c='Failed';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Payment Failed'));
                     ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,res.responseReasonText));
                    
                    return null;
                }
                
                //succsess txn
                thisPayment.Status__c='Paid';
                thisPayment.Payment_Date__c=System.now();
                upsert thisPayment;
                success = true;
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'Payment Successful')); 
                
                try{
                    if(thisStatement !=null && thisStatement.Rental_Agreement__r.renter__r.email == null)
                    {
                        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                        msg.setToAddresses(new List<String>{thisStatement.Rental_Agreement__r.Renter__r.email});
                        msg.setSubject('test payment conf');
                        msg.setHtmlBody('Your payment of '+thisPayment.Amount__c+'Has been procsed <br/><br/> Thank You');
                        msg.setPlainTextBody('Your payment of '+thisPayment.Amount__c+'Has been procsd. Thank You');
                        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {msg});
                    }
                }
                catch(Exception e)
                {
                    
                }
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Ples fill all details'));
        }
        return null;
    }
    
    public boolean validateFields(String paymentType)
    {
        boolean valid=true;
        //check common fields
        if(thisPayment.Statement__c == null)
        {
            valid=false;
        }
        if(thisPayment.Amount__c == null)
        {
            valid=false;
        }
        if(String.isBlank(thisPayment.Billing_Name__c))
        {
            valid=false;
        }
        if(string.isBlank(thisPayment.Billing_Street__c))
        {
            valid=false;
        }
        if(String.isBlank(thisPayment.Billing_State__c))
        {
            valid=false;
        }
        if(String.isBlank(thisPayment.Billing_Postal_Code__c))
        {
            valid=false;
        }
        
        //check specific fields related to payment type
        //check fields when payment type is check
        if(paymentType == 'Check')
        {
            if(String.isBlank(thisPayment.Check_Account_Number__c))
                valid=false;
            if(String.isBlank(thisPayment.Check_Routing_Number__c))
                valid=false;
        }
        else if (paymentType=='Credit Card')
        {
            if(String.isBlank(thisPayment.Credit_Card_Number__c))
                valid=false;
            if(String.isBlank(thisPayment.Credit_Card_Expiration_month__c))
                valid=false;
            if(String.isBlank(thisPayment.Expiration_Year__c))
                valid=false;
            if(String.isBlank(thisPayment.Credit_Card_Security_Card__c))
                valid=false;
        }
        return valid;
    }
    
    public boolean getIsGuest()
    {
        return [Select Id,userType from Profile where id =:UserInfo.getProfileId()].userType=='Guest';
    }
   public static map<string,string> monthMap = new map<string,string>{
        'January'=>'01',
        'February'=>'02',
        'March'=>'03',
        'April'=>'04',
        'May'=>'05',
        'June'=>'06',
        'July'=>'07',
        'August'=>'08',
        'September'=>'09',
        'October'=>'10',
        'November'=>'11',
        'December'=>'12'
    }; 
   
        public list<selectOption> getPaymentRecordTypes()
    {
        list<selectOption> temp = new list<selectOption>();
        temp.add(new selectOption ('','Select Payment Method'));
        for(id i: recordTypeMap.keySet())
        {
            temp.add(new SelectOption(i,recordTypeMap.get(i)));
        }
        
        return temp;
    }
    
    public List<SelectOption> getexpirationYears()
    {
        List<SelectOption> temp = new List<SelectOption>();
        
        for(integer i=0; i<5; i++)
        {
            String y=''+System.today().addYears(i).year();
            temp.add(new SelectOption(y,y));
        }
        return temp;
    }
}