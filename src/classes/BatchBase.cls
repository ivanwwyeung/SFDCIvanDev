/* Class Name   : BatchBase
 * Description  : Meant to be extended by class implement Apex Batch Database.Batchable<sObject> interface. provides unified format for email when batch is done
 * Created By   : 
 * Created On   : 

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date                   Modification ID      Description 
 * IY                       10/24/14               n/a                  remove ScheduleNextJob as there are new way to schedule batch job
 * ---------------------------------------------------------------------------------------------------------------------------------------
 *                                                                                 b   
*/
global abstract class BatchBase {
    
    private List<string> messages = new List<String>();
    protected DateTime startTime = DateTime.Now();
    protected string env = System.URL.getSalesforceBaseUrl().getHost();
    protected integer successCount = 0;
    protected integer failureCount = 0; 
    protected boolean IsSendEmailNotification { get; set; }
    protected string batchName; 
    protected Database.BatchableContext batchableContext;


    //constructor
    public BatchBase() {
    	IsSendEmailNotification = false;
    }
            
    private integer pMessageLineLimit = 2000;
    public integer MsgLineLimit {
    	get {
    		return pMessageLineLimit;
    	}
    	set {
    		if ( value > 10 && value < 2000){
    			pMessageLineLimit = value;
    		}
    	}
    }
    
    
    protected void AddMessage(string msg){
        messages.add(msg);
        if ( messages.size() > MsgLineLimit) {
            SendBatchCompletionEmail();      
            messages.clear();
        } 
    }
    
    protected void SetMessage(integer pos, string msg) {
        messages[0] = msg;
    }
    
    protected List<string> GetMessages(){
        return messages; 
    }

    protected void SendBatchCompletionEmail() {
        List<String> emailIds = new List<String>();
        emailIds.add('');
        SendBatchCompletionEmail(batchableContext, batchName, startTime, messages, emailIds);
    }

    
    private void SendBatchCompletionEmail(
        Database.BatchableContext BC, string BatchName, DateTime startTime,
        List<string> messages, List<String> emailIds)
      	{
      		if ( !IsSendEmailNotification ){
    			return;
    		}
    		
      		// Send an email to the Apex job's submitter notifying of job completion.  
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	string body = '';
			if ( BC <> null){
			  // Get the ID of the AsyncApexJob representing this batch job  
			  // from Database.BatchableContext.    
			  // Query the AsyncApexJob object to retrieve the current job's information.  
			      
			  AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
			   TotalJobItems, CreatedBy.Email
			   from AsyncApexJob where Id =:BC.getJobId()];
			
			  
			  List<String> toAddresses = new List<String> {};
			  toAddresses.add(a.CreatedBy.Email);
			  //toAddresses.add('blau@salesforce.com');
			  if(emailIds != null && emailIds.size()>0) { 
			      toAddresses.addAll(emailIds);
			  }
			  mail.setToAddresses(toAddresses);

			  env = cleanUpEnv(env);
			  
			  string subject = 'Apollo SRM ['+env+'] Batch :'+ BatchName + ' ' + a.Status;
			  mail.setSubject(subject);
			  
			  body = 'The batch Apex job ['+ BatchName +'] processed ' + a.TotalJobItems +
            		' batches with '+ a.NumberOfErrors + ' failures. \r\n\r\n';
        	} else {
        		mail.setSubject(batchName);
        	}
        	
          
          
          if ( startTime <> null){
            DateTime endTime = DateTime.Now();
            String duration = DateTimeUtil.duration_between_two_date_times(startTime, endTime);
            body = body + duration + '\r\n\r\n';
          }
            
          if ( messages <> null){
            for(string s : messages){
                body = body + s + '\r\n\r\n';
            }
          }
          
          mail.setPlainTextBody(body);
          system.debug('To Addresses : '+mail.getToAddresses());
          system.debug('Sending email -------------------------'+body);
          if (mail.getToAddresses() <> null && mail.getToAddresses().size() > 0){
	          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail })  ; 
	          system.debug('email sent------------------------'+body);
          } else {
          	System.Debug('email sent aborted since there is no ToAddressesses');
          }
    }
    

	// make it a generic function to take oSchedulableObject as parameter
/*
   	private static void ScheduleNextJob(string jobName, integer jobInterval, Scheduleable oSchedulableObject) {
	    
	    String day = string.valueOf(system.now().day());
	    String month = string.valueOf(system.now().month());
	    String hour = string.valueOf(system.now().hour());
	    String minute = string.valueOf(system.now().minute() + 5);
	    String second = string.valueOf(system.now().second());
	    String year = string.valueOf(system.now().year());
	
	    String strJobName = 'BatchAppLogPubId Job-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
	    String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
	    System.schedule(strJobName, strSchedule, oSchedulableObject);		
	}
*/
	
    
    public string cleanUpEnv(string env){
    	if(env != null && env.contains('.')) {
			env = env.substring(0,env.indexOf('.'));
		} 
		return env;
    }
    
    
    
    // a few of the batches generated too many messages and got overflowed
    // changing the structure to send email if size of message exceed 5meg.
    
    
}