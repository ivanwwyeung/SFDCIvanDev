/* Class Name   : ApexShareModel
 * Description  : The purpose of this class is encasulate the logic to manipualte  __Share records. 
 * Created By   : IY
 * Created On   : 10-22-2014

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date                   Modification ID      Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 *                                                                                    
*/

public without sharing class ApexShareModel {

	public static boolean persistApexShare(List<sObject> shareRecords, id parentId) {
		// Insert the sharing record and capture the save result. 
		// The false parameter allows for partial processing if multiple records passed 
		// into the operation.
		
		if ( shareRecords == null || shareRecords.size() == 0 ) {
			return false;
		}
		
		
		System.debug('ApexShareModel::persistApexShare' + 'persist '+shareRecords.size()+' share records' + 'for' + parentId );
		
		List<Database.Saveresult> srList = Database.Insert(shareRecords,false);
		//insert shareRecords;
		//return true;

		// Process the save results.
		for(Database.Saveresult sr : srList) {
			if(sr.isSuccess()){
				// Indicates success 
				//return true;
			} else {
				// Get first save result error.
				Database.Error err = sr.getErrors()[0];
	         
				// Check if the error is related to trival access level.
				// Access levels equal or more permissive than the object's default 
				// access level are not allowed. 
				// These sharing records are not required and thus an insert exception is acceptable. 
				if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  err.getMessage().contains('AccessLevel')){
						
	            	// Indicates success.
	            	//return true;
				} else{
					// Indicates failure.
					//return false;
					System.debug('ApexShareModel::persistApexShare' + err.getStatusCode() + ' '+ err.getMessage() + ' on ' +  parentId );
				}
			}
		}
		
		return true;
		
	}
}