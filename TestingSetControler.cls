public class TestingSetControler {

    public ApexPages.StandardSetController  objController {
        get{
        if(objController == null)
        {
            List<Account> accList = [Select Name,Industry from Account];
            this.objController = new ApexPages.StandardSetController(accList);
            objController.setPageSize(5);
        }
        return objController;
        }
        
        set;
    }

    public List<Account> getAccounts() {
    
        return (List<Account>)this.objController.getRecords();
    }
    



}