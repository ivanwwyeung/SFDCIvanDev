global with sharing class AutomatedTestJobQueuer implements schedulable {
// Note: The scheduler runs as system—all classes are executed, whether or not the user has permission to execute the class.
// To schedule an Apex class to run at regular intervals, first write an Apex class that implements the Salesforce-provided interface Schedulable.

/*
 
 http://developer.force.com/cookbook/recipe/automated-unit-test-execution

This class cover step 1 and step 2:  
1. Create a scheduled job that queues the test classes containing the desired unit tests to be executed by inserting "ApexTestQueueItem" objects.
2. Store the Apex Job Id somewhere so that we can process the test results later. This is necessary because the unit tests are executed asynchronously.
3. Create one or more other scheduled jobs that periodically check the status of the unit tests, and when complete, email us the results.

*/

    
    // The Schedulable interface contains one method that must be implemented, execute.
    global void execute(SchedulableContext SC) {
        doExecute();
    }

    // use @future annotation for asyn operation 
    @future (callout=true)
    private static void doExecute(){
        enqueueUnitTests();
    }
    
    // call the following, e.g. in developer console, to create a scheduled job that will execute your unit tests daily at 4 AM.
	// AutomatedTestJobQueuer.createDaily4AMScheduledJob();
	// CronJob/Schedule strign syntax:   Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    public static void createDaily4AMScheduledJob(){
        AutomatedTestJobQueuer atj = new AutomatedTestJobQueuer();  
        string sch = '0 0 4 * * ?';  
        system.schedule('Enqueue Unit Tests 4 AM',sch,atj);
    }

    /* Allows us to externally enqueue our unit tests. For example,
       whenever we check our code into source control, we could
       run our unit tests.
    */
    webservice static void enqueueUnitTests(){      
        enqueueTests();
    }


    // Enqueue all classes beginning with "Test".  
    private static void enqueueTests() {
       /* The first thing you need to do is query the classes that contain
         the unit tests you want executed.

         In our org, our test classes are named "Test<Class_Name_Here>"
         so that all the test classes are grouped together in Eclipse.
         Change the where clause as necessary to query the desired classes.
       */
            
       ApexClass[] testClasses = 
         [SELECT Id,
                 Name
            FROM ApexClass 
           WHERE Name LIKE 'Test%'];
              
       Integer testClassCnt = testClasses != null ? testClasses.size() : 0;
        
       system.debug('   enqueueTests::testClassCnt ' + testClassCnt);
            
       if (testClassCnt > 0) {
          /*
             Insertion of the ApexTestQueueItem causes the unit tests to be 
             executed. Since they're asynchronous, the apex async job id
             needs to be stored somewhere (in this case AutomatedTestingQueue__c) so we can process the test results
             when the job is complete.
          */
          // ApexTestQueueItem - Represents a single Apex class in the Apex job queue. 
          // This object is available in API version 23.0 and later.
          ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
            
          for (ApexClass testClass : testClasses) {
              system.debug('   enqueueTests::testClass ' + testClass);
                
              queueItems.add(new ApexTestQueueItem(ApexClassId=testClass.Id));
          }

          insert queueItems;

          // Get the job ID of the first queue item returned. 
    	  // About ApexTestQueueItem.ParentJobId  - Read-only. Points to the AsyncApexJob that represents the entire test run. 
    	  // If you insert multiple Apex test queue items in a single bulk operation, the queue items will share the same parent job. 
    	  // This means that a test run can consist of the execution of the tests of several classes if all the test queue items are inserted 
    	  // in the same bulk operation.
          ApexTestQueueItem item = 
            [SELECT ParentJobId
               FROM ApexTestQueueItem 
              WHERE Id=:queueItems[0].Id
              LIMIT 1];
          
          //  
          AutomatedTestingQueue__c atq = new AutomatedTestingQueue__c(
              AsyncId__c = item.parentjobid
          );

          insert atq;
       }
    }
}