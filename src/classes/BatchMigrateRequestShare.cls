/* Class Name   : BatchMigrateRequestShare
 * Description  : Create batch job to populate Request_Share during migration from C3 portal to community. 
 * Created By   : IY
 * Created On   : 10-22-2014

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date                   Modification ID      Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 *                                                                                    
*/

global class BatchMigrateRequestShare extends BatchBase 
	implements Database.Batchable<SObject>,Database.Stateful {

	// process all requests
    public String SOQL = 'select id, Payment_Delegated_RAE__c, RAE__c, Submitt__c, Additional_Cnct__c from Request__c';
    
    public BatchMigrateRequestShare() {
		super();
    	if ( Test.isRunningTest()){
    		SOQL = SOQL + ' limit 10';
    	}
    	AddMessage(SOQL);
        system.debug(SOQL);
    }
    
    //Apex Batch method stub. The maximum number of records that can be returned in the Database.QueryLocator object is 50 million.
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	// BatchBase attributes
        batchableContext = BC;
        batchName = 'BatchMigrateRequestShare';
        // BatchBase attributes
        System.Debug(SOQL);
        return Database.getQueryLocator(SOQL);
    }
    
    
	//Apex Batch method stub. The list of batch records to process is passed in the second parameter of the execute method.
    global void execute(Database.BatchableContext BC, List<Request__c> requests){
		// create request share 
		List<Request__c> aEmptyList = new List<Request__c>();
		RequestShareModel.ManageRequestShare(aEmptyList,requests ); 
    }
    

    global void finish(Database.BatchableContext BC){
		SendBatchCompletionEmail(); // call BatchBase parent 
	}
	
	//BatchMigrateRequestShare.runNow();
	public static void runNow(){

        String day = string.valueOf(system.now().day());
	    String month = string.valueOf(system.now().month());
	    String hour = string.valueOf(system.now().hour());
	    String minute = string.valueOf(system.now().minute() + 5);
	    String second = string.valueOf(system.now().second());
	    String year = string.valueOf(system.now().year());
	
	    String strJobName = 'BatchMigrateRequestShare Job-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
	    
    	BatchMigrateRequestShare batch = new BatchMigrateRequestShare();
    	// Database.executeBatch(batch, 1000);
        Database.scheduleBatch((Database.Batchable) batch, strJobName, 0, 1000);  // use scheduleBatch instead of executeBatch for it can provides a name 
	}


	
}