public class NewAndExistingController {

    public PageReference SaveMethod() {
        try{
            upsert(account);
        }
        catch(System.DMLException e)
        {
            ApexPages.addMessages(e);
        
        return null;
        }
        
        PageReference redirectSuccess = new ApexPages.StandardController(Account).view();
        return redirectSuccess;
    }


public Account account {get; private set;}
 
 public NewAndExistingController()
 {
     Id id=ApexPages.currentPage().getParameters().get('Id');
    account =  (id==null)?new Account():[Select Name,Phone,Industry from Account where Id =:id];
 }

}