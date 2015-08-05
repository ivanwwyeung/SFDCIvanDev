global with sharing class AutomatedTestingJob implements Schedulable {
// Note: The scheduler runs as system—all classes are executed, whether or not the user has permission to execute the class.
// To schedule an Apex class to run at regular intervals, first write an Apex class that implements the Salesforce-provided interface Schedulable.

/*
 
 http://developer.force.com/cookbook/recipe/automated-unit-test-execution

This class cover step 3: 
1. Create a scheduled job that queues the test classes containing the desired unit tests to be executed by inserting "ApexTestQueueItem" objects.
2. Store the Apex Job Id somewhere so that we can process the test results later. This is necessary because the unit tests are executed asynchronously.
3. Create one or more other scheduled jobs that periodically check the status of the unit tests, and when complete, email us the results.

*/

    // The Schedulable interface contains one method that must be implemented, execute.    
    global void execute(SchedulableContext SC) {
        doExecute();
    }

    // Have to use a future method so the email will be sent out.
    @future (callout=true)
    private static void doExecute(){
        processAsyncResults();
    }
    
    /*
        Schedule String Format: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    */
    // run the following (in developer console) to create four scheduled jobs that effectively will process the test results and 
    // email them every 15 minutes, if needed.
    // AutomatedTestingJob.createEvery15MinuteScheduledJobs();
    
    public static void createEvery15MinuteScheduledJobs(){
        AutomatedTestingJob atj = new AutomatedTestingJob();  
        string sch = '0 0 * * * ?';  
        system.schedule('Process Queued Unit Tests Every Top Of The Hour',sch,atj);
        
        sch = '0 15 * * * ?';  
        system.schedule('Process Queued Unit Tests At Each Quarter After',sch,atj);
        
        sch = '0 30 * * * ?';  
        system.schedule('Process Queued Unit Tests At Each Bottom Of The Hour',sch,atj);
        
        sch = '0 45 * * * ?';  
        system.schedule('Process Queued Unit Tests At Each Quarter To The Hour',sch,atj);
    }
    
    public static void processAsyncResults(){
        List<AutomatedTestingQueue__c> queuedTests = 
           [select id,
                   name,
                   AsyncId__c
              from AutomatedTestingQueue__c
             limit 5];
        
        if (queuedTests != null && queuedTests.size() > 0){
            Set<Id> AsyncIds = new Set<Id>();

            for (AutomatedTestingQueue__c queuedJob : queuedTests){
                 AsyncIds.add(queuedJob.AsyncId__c);
            }
            
            // return all the ApexTestQueueItem from the stored parentjobid. 
            List<ApexTestQueueItem> queuedItems = checkClassStatus(AsyncIds);
            
            Map<Id, List<ApexTestQueueItem>> groupedTestsByJob = new Map<Id, List<ApexTestQueueItem>>();

		    // group the jobs by the same parentjobid
            for (ApexTestQueueItem atqi : queuedItems){
                 if (groupedTestsByJob.containsKey(atqi.ParentJobId) == true){
                     List<ApexTestQueueItem> groupedTests = groupedTestsByJob.get(atqi.ParentJobId);
                     groupedTests.add(atqi);
                 }
                 else{
                     List<ApexTestQueueItem> groupedTests = new List<ApexTestQueueItem>();
                     groupedTests.add(atqi);
                     groupedTestsByJob.put(atqi.ParentJobId, groupedTests);
                 }
            }

            // return a list of ParentJobIds where all the associatd jobs are completed
            Set<Id> completedAsyncIds = getCompletedAsyncJobsIds(groupedTestsByJob);
            
            if (completedAsyncIds != null && completedAsyncIds.size() > 0){
                
                // return all results with the same ParentJobId
                List<ApexTestResult> testResults = checkMethodStatus(completedAsyncIds);
                
                
                Map<Id, List<ApexTestResult>> groupedTestResultsByJob = new Map<Id, List<ApexTestResult>>();
                
                for (ApexTestResult testResult : testResults){
                	// Note: ApexTestResult.AsyncApexJobId field points to the same object as ApexTestQueueItem.ParentJobId.
                    if (groupedTestResultsByJob.containsKey(testResult.AsyncApexJobId)){
                        List<ApexTestResult> groupedTestsResults = groupedTestResultsByJob.get(testResult.AsyncApexJobId);
                        groupedTestsResults.add(testResult);
                    }
                    else{
                        List<ApexTestResult> groupedTestsResults = new List<ApexTestResult>();
                        groupedTestsResults.add(testResult);
                        
                        groupedTestResultsByJob.put(testResult.AsyncApexJobId, groupedTestsResults );
                    }
                }

				// groupedTestResultsByJob.values() returns a list of  List<ApexTestResult>
                for (List<ApexTestResult> jobTestResults : groupedTestResultsByJob.values()){
                    sendTestResultEmail(jobTestResults);
                }


			    // if all the jobs in the same ParentJobId is completed, delete from the custom object AutomatedTestingQueue__c
                List<AutomatedTestingQueue__c> queuedTestsToDelete = new List<AutomatedTestingQueue__c>();                 
                for (AutomatedTestingQueue__c queuedTest : queuedTests){
                    for (Id completedAsyncId : completedAsyncIds){
                        if (queuedTest.AsyncId__c == completedAsyncId){
                            queuedTestsToDelete.add(queuedTest);
                            break;
                        }
                    }
                    if (groupedTestsByJob.containsKey(queuedTest.asyncId__c) == false){
                        queuedTestsToDelete.add(queuedTest);
                    }
                }
                if (queuedTestsToDelete.size() > 0){
                    delete queuedTestsToDelete;
                }
                
                
            }
        }
    }
    
    public static Set<Id> getCompletedAsyncJobsIds(Map<Id, List<ApexTestQueueItem>> groupedTestsByJob){
	    // this function return the ParentJobId (aka AsyncJobId) where all the associated jobs are completed. 
	    
        Set<Id> completedAsyncJobIds = new Set<Id>();
        
        // map.values() Returns a list that contains all of the values in the map in arbitrary order.
        // in this case, each value is a list of ApexTestQueueItem with the same parentJobid
        for (List<ApexTestQueueItem> jobTests : groupedTestsByJob.values()){
            if (jobTests == null || jobTests.size() == 0){
                continue;
            }
            
            Boolean allCompleted = true;
            
			/* ApexTestQueueItem.status of the job. Valid values are:
			Holding
			Queued
			Preparing
			Processing
			Aborted
			Completed
			Failed
			*/
            for (ApexTestQueueItem queuedTest : jobTests){
                if (queuedTest.Status != 'Completed' && queuedTest.Status != 'Failed' && queuedTest.Status != 'Aborted'){
                    allCompleted = false;
                    break;
                }
            }
            
            if (allCompleted == true){
                completedAsyncJobIds.add(jobTests[0].ParentJobId);
            }
        }
        
        return completedAsyncJobIds;
    }
    
    private static void sendTestResultEmail(List<ApexTestResult> jobTestResults){
        system.debug(' In sendTestResultEmail');
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String emailAddress = 'Your email address here';
        
        String[] toAddresses = new String[] { emailAddress };
    
        mail.setToAddresses(toAddresses);
        
        String emailSubject = 'Dev Unit Test Results ' + String.valueOf(Date.today()); 
    
        mail.setSubject(emailSubject);

        String testResultEmailbody = getTestResultHtmlEmailBody(jobTestResults);

        mail.setHtmlBody(testResultEmailbody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
        
        system.debug(' sent test results email');
    }
    
    private static String getTestResultHtmlEmailBody(List<ApexTestResult> jobTestResults){
        system.debug(' In getTestResultHtmlEmailBody');
        
        List<ApexTestResult> successTests = new List<ApexTestResult>();
        List<ApexTestResult> failedTests = new List<ApexTestResult>();
        
        for (ApexTestResult jobTestResult : jobTestResults){
            if (jobTestResult.Outcome == 'Pass'){
                successTests.add(jobTestResult);
            }
            else{
                failedTests.add(jobTestResult);
            }
        }
        
        Integer numTestsRun = successTests.size() + failedTests.size();
        Integer numFailures = failedTests.size();
        Integer successNum = numTestsRun - numFailures;
        
        if (successNum < 0){
            successNum = 0;
        }
        
        String testResultBody = '';
        
        // Unfortunately, css has to be inlined because many email service providers now exclude external CSS
        // because it can pose a security risk.
        testResultBody += '<td style="text-align: right;">' + numTestsRun + '';
        testResultBody += '<td style="text-align: right;">' + numFailures + '';
        testResultBody += '<td style="text-align: right;">' + successNum + '';
        
        testResultBody += '<table><tbody><tr class="firstTr"><td>Tests Run:</td></tr><tr><td>Failure Count:</td></tr><tr><td>Success Count:</td></tr></tbody></table>';
                
        if (numFailures > 0){
            
            testResultBody += '<div style="margin: 5px 0px; font-weight: bold;">Test Failures</div>';
            
            testResultBody += '';
            
            testResultBody += '';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Test Class</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Unit Test</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Message</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Stack Trace</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Time (Ms)</th>';
            testResultBody += '';
            
            for (ApexTestResult testFailure : failedTests){
                testResultBody += '';
                
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexClass.Name +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.MethodName +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.message +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.stackTrace +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexLog.DurationMilliseconds +'';
                //testResultBody += '<td style="vertical-align: top;">' + testFailure.type_x +'';
                
                testResultBody += '';
            }
            
            testResultBody += '<table><tbody><tr></tr><tr></tr></tbody></table>';
        }       
        
        return testResultBody;
    }


    // Get the status and pass rate for each class 
    // whose tests were run by the job. 
    // that correspond to the specified job ID. 
    // About ApexTestQueueItem.extendedStatus The pass rate of the test run.
	// 		For example: “(4/6)”. This means that four out of a total of six tests passed.
	// 		If the class fails to execute, this field contains the cause of the failure.

    public static List<ApexTestQueueItem> checkClassStatus(Set<ID> jobIds) {
        ApexTestQueueItem[] items = 
           [SELECT ApexClass.Name,
                   Status,
                   ExtendedStatus,
                   ParentJobId
            FROM ApexTestQueueItem 
            WHERE ParentJobId in :jobIds];
            
        for (ApexTestQueueItem item : items) {
            String extStatus = item.extendedstatus == null ? '' : item.extendedStatus;
            System.debug(item.ApexClass.Name + ': ' + item.Status + extStatus);
        }
        
        return items;
    }


    public static List<ApexTestResult> checkMethodStatus(Set<ID> jobIds) {
    // Get the result for each test method that was executed. 
    
    	// ApexTestResult: Represents the result of an Apex test method execution. This object is available in API version 23.0 and later.
        ApexTestResult[] results = 
           [SELECT Outcome,
                   MethodName,
                   Message,
                   StackTrace,
                   AsyncApexJobId, 
                   ApexClass.Name,
                   ApexClass.Body,
                   ApexClass.LengthWithoutComments,
                   ApexClass.NamespacePrefix,
                   ApexClass.Status,
                   ApexLogId,
                   ApexLog.DurationMilliseconds,
                   ApexLog.Operation,
                   ApexLog.Request,
                   ApexLog.Status,
                   ApexLog.Location,
                   ApexLog.Application
            FROM ApexTestResult 
            WHERE AsyncApexJobId in :jobIds];
            
        for (ApexTestResult atr : results) {
            System.debug(atr.ApexClass.Name + '.' + atr.MethodName + ': ' + atr.Outcome);
            if (atr.message != null) {
                System.debug(atr.Message + '\n at ' + atr.StackTrace);
            }
        }
        
        return results;
    }
}