public class FutureAccountApexExample{
	@future
	public static void CountContacts(List<Id> accountIds){
		List<Account> accList = new List<Account>();
		for (id accId : accountIds){
			//query acc records based on Id
			//query to find total num of Contacts on the acct
			//set the value on new field and add the updated acct to list
			Account acc = [Select Name
			               from Account
			               where Id = :accId];
			acc.NumberOfContacts__c = [Select count()
			                           from Contact
			                           where accountId = :accId];
			accList.add(acc);
		}
		update accList;
	}

	public FutureAccountApexExample(){
		List<Account> acList = [Select Id
		                        from Account];
		List<Id> accntIds = new List<ID>();
		For (Account ac : acList){
			accntIds.add(ac.Id);
		}
		FutureAccountApexExample.CountContacts(accntIds);
	}
}