public class MyControllerExtensions {

    private final Account acct;

    public MyControllerExtensions(ApexPages.StandardController stdcontroller)
    {
        this.acct = (Account)stdcontroller.getRecord();
    }
    
    public String getGreeting()
    {
        return 'hello '+ acct.Name + '('+Acct.id+ ')';
    }


}