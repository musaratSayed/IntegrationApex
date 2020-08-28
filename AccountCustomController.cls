public class AccountCustomController {


 private final Account account;
    
    public AccountCustomController()
    {
        account = [Select Id,Name,Site from Account where Id =: ApexPages.currentPage().getParameters().get('id')];
    }
    
    public PageReference save() {
    update account;
        return null;
    }

   
    
    public Account getAccount(){
        return account;
    }
    
    
}