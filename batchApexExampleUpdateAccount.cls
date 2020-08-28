global class batchApexExampleUpdateAccount implements Database.Batchable<sObject>, Database.Stateful{
	global Integer numOfRowsProcessed = 0;
	global Database.QueryLocator start(Database.BatchableContext bc){
		String query = 'Select Id,Name,Description from Account';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<Account> accList){
		for (Account a : accList){
			a.description = 'BatchApex Testing and Stateful';

			numOfRowsProcessed = numOfRowsProcessed + 1;
		}
		try{
			update accList;
		} catch (Exception e){
			System.Debug(e);
		}
	}

	global void finish(Database.BatchableContext bc){
		System.Debug('FINISHED Processing Batches');
		System.Debug('NUM OF ROWS PROCESSED: ' + numOfRowsProcessed);
	}
}