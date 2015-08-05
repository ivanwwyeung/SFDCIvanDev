/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest
private class BatchMigrateRequestShareTest {

	public static void CreateData() {
		// MeetingModelData.createData();
	}
	
    static testMethod void unitTest() {
        // TO DO: implement unit test
        
        Test.startTest();
	        BatchMigrateRequestShare.runNow();
        Test.stopTest();
    }
    
}