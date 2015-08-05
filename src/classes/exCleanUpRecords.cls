/*
Using batch Apex classes, you can process records in batches asynchronously. 
If you have a large number of records to process, for example, for data cleansing or archiving, batch Apex is your solution. Each invocation of a batch class results in a job being placed on the Apex job queue for execution.
*/
global class exCleanUpRecords implements 
   Database.Batchable<sObject> {
/*
To write a batch Apex class, your class must implement the Database.Batchable interface.
Your class declaration must include the implements keyword followed by Database.Batchable<sObject>. 

Note: To invoke a batch class, instantiate it first and then call Database.executeBatch with the instance of your batch class:

*/



   global final String query;
   
   global exCleanUpRecords(String q) {
       query = q;
   }


/* 
The start method is called at the beginning of a batch Apex job. 
It collects the records or objects to be passed to the interface method execute.

Note: the system will provide the BatchableContext parameter
global (Database.QueryLocator | Iterable<sObject>) start(Database.BatchableContext bc)
*/
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

/*
The execute method is called for each batch of records passed to the method. 
Use this method to do all required processing for each chunk of data.
This method takes the following:
A reference to the Database.BatchableContext object.
A list of sObjects, such as List<sObject>, or a list of parameterized types. 
If you are using a Database.QueryLocator, the returned list should be used.

Note: Batches of records are not guaranteed to execute in the order they are received from the start method.

*/   
   global void execute(
                Database.BatchableContext BC, 
                List<sObject> scope){
      delete scope;
      Database.emptyRecycleBin(scope);
   }


/*
The finish method is called after all batches are processed. 
Use this method to send confirmation emails or execute post-processing operations.
*/
   global void finish(Database.BatchableContext BC){
       AsyncApexJob a = 
           [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC.getJobId()];
                          
       // Send an email to the Apex job's submitter 
       //   notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Record Clean Up Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}