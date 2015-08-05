@isTest
private class TestCleanUpBatchClass {

    static testmethod void test() {
        // The query used by the batch job.
        String query = 'SELECT Id,CreatedDate FROM Merchandise__c ' + 
                   'WHERE Id NOT IN (SELECT Merchandise__c FROM Line_Item__c)';

       // Create some test merchandise items to be deleted
       //   by the batch job.
       Merchandise__c[] ml = new List<Merchandise__c>();
       for (Integer i=0;i<10;i++) {
           Merchandise__c m = new Merchandise__c(
               Name='Merchandise ' + i,
               Description__c='Some description',
               Price__c=2);
           ml.add(m);
       }
       insert ml;

       Test.startTest();
       
       // Note: there is no need to explicitly call start, execute and finish method. 
       exCleanUpRecords c = new exCleanUpRecords(query);
	   // To invoke a batch class, instantiate it first and then 
	   // call Database.executeBatch with the instance of your batch class: 
       Database.executeBatch(c);
       Test.stopTest();

       // Verify merchandise items got deleted 
       Integer i = [SELECT COUNT() FROM Merchandise__c];
       System.assertEquals(i, 0);
    }
}