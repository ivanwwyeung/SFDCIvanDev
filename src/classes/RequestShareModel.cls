/* Class Name   : RequestShareModel
 * Description  : The purpose of this class is encasulate the logic to manipualte  Request__Share records. 
 * Created By   : IY
 * Created On   : 10-22-2014

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date                   Modification ID      Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 *                                                                                    
*/


public without sharing class RequestShareModel {
	

		// remove share from the old lookup , add share for new lookup
		public static void ManageRequestShare(List<Request__c> oldList, List<Request__c> newList) {
			if ( newList == null || newList.size() == 0) {
				return;
			}
			Map<id, id> deleteRAEMap = new Map<Id, Id>();
			Map<id, id> addRAEMap = new Map<Id, Id>();
			Map<id, id>	newRAEMap = new Map<Id, Id>();
		    Map<id, id>	oldRAEMap = new Map<Id, Id>();

			Map<id, id> deletePaymentDelegatedRAEMap = new Map<Id, Id>();
			Map<id, id> addPaymentDelegatedRAEMap = new Map<Id, Id>();
			Map<id, id>	newPaymentDelegatedRAEMap = new Map<Id, Id>();
		    Map<id, id>	oldPaymentDelegatedRAEMap = new Map<Id, Id>();
		    
			Map<id, id> deleteSubmitterMap = new Map<Id, Id>();
			Map<id, id> addSubmitterMap = new Map<Id, Id>();
			Map<id, id>	newSubmitterMap = new Map<Id, Id>();
		    Map<id, id>	oldSubmitterMap = new Map<Id, Id>();

			Map<id, id> deleteAddContactMap = new Map<Id, Id>();
			Map<id, id> addAddContactMap = new Map<Id, Id>();
			Map<id, id>	newAddContactMap = new Map<Id, Id>();
		    Map<id, id>	oldAddContactMap = new Map<Id, Id>();

			// temp varialbles 
			List <Id> aContactIdList;
			Set <Id>  aRequestIdSet; 
			List <Request__Share>	aRequestShareList;
			List <Request__Share>	aRequestShareDeleteList; 
		    Map <Id, Id> deleteUserContactMap;
		    List <Id> deleteUserIdList; 

			for (Request__c aRequest: newList){
				newRAEMap.put(aRequest.id, aRequest.RAE__c); 
				newSubmitterMap.put(aRequest.id, aRequest.Submitt__c); 	
				newAddContactMap.put(aRequest.id, aRequest.Additional_Cnct__c); 
				newPaymentDelegatedRAEMap.put(aRequest.id, aRequest.Payment_Delegated_RAE__c); 
			}		 		

			
			// if the old request list exist, it means an updated request 
			if (oldList != null || oldList.size() > 0 ){				

				for (Request__c aRequest: oldList){
					oldRAEMap.put(aRequest.id, aRequest.RAE__c); 
					oldSubmitterMap.put(aRequest.id, aRequest.Submitt__c); 	
					oldAddContactMap.put(aRequest.id, aRequest.Additional_Cnct__c); 
					oldPaymentDelegatedRAEMap.put(aRequest.id, aRequest.Payment_Delegated_RAE__c); 
				}		 	
					
				// compare the two list and identify that is changed. 
				for (Id key: newRAEMap.KeySet()){
					if (newRAEMap.get(key)  != oldRAEMap.get(key)  ){
						deleteRAEMap.put(key, oldRAEMap.get(key)); 
						addRAEMap.put(key, newRAEMap.get(key)); 
					}
					if (newPaymentDelegatedRAEMap.get(key)  != oldPaymentDelegatedRAEMap.get(key)  ){
						deletePaymentDelegatedRAEMap.put(key, oldPaymentDelegatedRAEMap.get(key)); 
						addPaymentDelegatedRAEMap.put(key, newPaymentDelegatedRAEMap.get(key)); 
					}
					if (newSubmitterMap.get(key)  != oldSubmitterMap.get(key)  ){
						deleteSubmitterMap.put(key, oldSubmitterMap.get(key)); 
						addSubmitterMap.put(key, newSubmitterMap.get(key)); 
					}
					if (newAddContactMap.get(key)  != oldAddContactMap.get(key)  ){
						deleteAddContactMap.put(key, oldAddContactMap.get(key)); 
						addAddContactMap.put(key, newAddContactMap.get(key)); 
					}
					
				}
				
				// assumption: all request shares are for community users. hence, the relationship is set in User object (vs. Contact)
				 aRequestShareDeleteList = new List <Request__Share>(); 

				// RAE
				aContactIdList = deleteRAEMap.values(); 
				aRequestIdSet = deleteRAEMap.keySet(); 
				List <User> deleteRAEUsers = [select Id, ContactId from User where ContactId in :aContactIdList];
				deleteUserContactMap = new Map<id, Id>(); 
				deleteUserIdList = new List<Id> (); 
				for (User aUser:deleteRAEUsers ){
					deleteUserContactMap.put(aUser.Id, aUser.ContactId); 
					deleteUserIdList.add(aUser.Id); 
				}
			    aRequestShareList = [select Id, ParentId, UserOrGroupId from request__share 
			    where ParentId in :aRequestIdSet and UserOrGroupId in :deleteUserIdList and RowCause = :Schema.Request__Share.RowCause.RAE__c];
				for (Request__Share aRequestShare:  aRequestShareList){
					// only delete the records if the request id - RAE contact pair match 
					if (deleteRAEMap.get( aRequestShare.ParentId )   == deleteUserContactMap.get(aRequestShare.UserOrGroupId)){
						aRequestShareDeleteList.add(aRequestShare);
					}
				}
				
				// Payment Delegated RAE 
				aContactIdList = deletePaymentDelegatedRAEMap.values(); 
				aRequestIdSet = deletePaymentDelegatedRAEMap.keySet(); 
				List <User> deletePaymentDelegatedRAEUsers = [select Id, ContactId from User where ContactId in :aContactIdList];
				deleteUserContactMap = new Map<id, Id>(); 
				deleteUserIdList = new List<Id>(); 
				for (User aUser:deletePaymentDelegatedRAEUsers ){
					deleteUserContactMap.put(aUser.Id, aUser.ContactId); 
					deleteUserIdList.add(aUser.Id); 
				}
			    // aRequestShareList = [select Id, ParentId, UserOrGroupId from request__share 
			    // where ParentId in :aRequestIdSet and UserOrGroupId in :deleteUserIdList and RowCause = :Schema.Request__Share.RowCause.PaymentDelegatedRAE__c];
				for (Request__Share aRequestShare:  aRequestShareList){
					// only delete the records if the request id - RAE contact pair match 
					if (deleteRAEMap.get( aRequestShare.ParentId )   == deleteUserContactMap.get(aRequestShare.UserOrGroupId)){
						aRequestShareDeleteList.add(aRequestShare);
					}
				}

				// Submitter
				aContactIdList = deleteSubmitterMap.values(); 
				aRequestIdSet = deleteSubmitterMap.keySet(); 
				List <User> deleteSubmitterUsers = [select Id, ContactId from User where ContactId in :aContactIdList];
				deleteUserContactMap = new Map<id, Id>(); 
				deleteUserIdList = new List<Id>(); 
				for (User aUser:deleteSubmitterUsers ){
					deleteUserContactMap.put(aUser.Id, aUser.ContactId); 
					deleteUserIdList.add(aUser.Id); 
				}
			    // aRequestShareList = [select Id, ParentId, UserOrGroupId from request__share 
			    // where ParentId in :aRequestIdSet and UserOrGroupId in :deleteUserIdList and RowCause = :Schema.Request__Share.RowCause.Submitter__c];
				for (Request__Share aRequestShare:  aRequestShareList){
					// only delete the records if the request id - Submitter contact pair match 
					if (deleteSubmitterMap.get( aRequestShare.ParentId )   == deleteUserContactMap.get(aRequestShare.UserOrGroupId)){
						aRequestShareDeleteList.add(aRequestShare);
					}
				}
				
				// Additional Contacts
				aContactIdList = deleteAddContactMap.values(); 
				aRequestIdSet = deleteAddContactMap.keySet(); 
				List <User> deleteAddContactUsers = [select Id, ContactId from User where ContactId in :aContactIdList];
				deleteUserContactMap = new Map<id, Id>(); 
				deleteUserIdList = new List<Id>(); 
				for (User aUser:deleteAddContactUsers ){
					deleteUserContactMap.put(aUser.Id, aUser.ContactId); 
					deleteUserIdList.add(aUser.Id); 
				}
			    // aRequestShareList = [select Id, ParentId, UserOrGroupId from request__share 
			    // where ParentId in :aRequestIdSet and UserOrGroupId in :deleteUserIdList and RowCause = :Schema.Request__Share.RowCause.AdditionalContact__c];
				for (Request__Share aRequestShare:  aRequestShareList){
					// only delete the records if the request id - Additional Contact contact pair match 
					if (deleteAddContactMap.get( aRequestShare.ParentId )   == deleteUserContactMap.get(aRequestShare.UserOrGroupId)){
						aRequestShareDeleteList.add(aRequestShare);
					}
				}
								
				
				delete aRequestShareDeleteList; // batch delete 

     						
				
				
			} else {
				// net new Share rules to be added; 
				addRAEMap = newRAEMap; 
			    addPaymentDelegatedRAEMap = newPaymentDelegatedRAEMap; 
		        addSubmitterMap = newSubmitterMap ; 
			    addAddContactMap = newAddContactMap; 								
			}
			
			// add the share rules
			// find out all the users for all the contacts:
			List <id> addRAEUserIds = addRAEMap.values(); 
			List <id> addPaymentDelegatedUserIds = addPaymentDelegatedRAEMap.values(); 	
			List <id> addSubmitterUserIds = addSubmitterMap.values(); 
			List <id> addAddContactUserIds = addAddContactMap.values(); 
					
			List <User> addRequestShareUser = [select id, ContactId from User where ContactId in: addRAEUserIds or 
			ContactId in :addPaymentDelegatedUserIds or ContactId in :addSubmitterUserIds or ContactId in :addAddContactUserIds ]; 
			Map <id, id> addRequestShareContactToUser = new Map<id, id>(); 
			for (User aUser : addRequestShareUser){
				addRequestShareContactToUser.put(aUser.ContactId, aUser.Id);  // setup a contact to user id map
			}
			List <Request__Share> newShareList = new List<Request__Share>(); 
			// RAE
			for (Id aRequestId: addRAEMap.KeySet() ) {
				   Request__Share aRequestShare = new Request__Share();
                   aRequestShare.ParentId = aRequestId; 
                   aRequestShare.UserOrGroupId = addRequestShareContactToUser.get(addRAEMap.get(aRequestId)); 
                   aRequestShare.AccessLevel = 'Edit';
                   aRequestShare.RowCause =Schema.Request__Share.RowCause.RAE__c;  
                   newShareList.add(aRequestShare); 
			}
			// Payment Delegated RAE
			for (Id aRequestId: addPaymentDelegatedRAEMap.KeySet() ) {
				   Request__Share aRequestShare = new Request__Share();
                   aRequestShare.ParentId = aRequestId; 
                   aRequestShare.UserOrGroupId = addRequestShareContactToUser.get(addPaymentDelegatedRAEMap.get(aRequestId)); 
                   aRequestShare.AccessLevel = 'Edit';
                   // aRequestShare.RowCause =Schema.Request__Share.RowCause.PaymentDelegatedRAE__c;  
                   newShareList.add(aRequestShare); 
			}		
			// Submitter
			for (Id aRequestId: addSubmitterMap.KeySet() ) {
				   Request__Share aRequestShare = new Request__Share();
                   aRequestShare.ParentId = aRequestId; 
                   aRequestShare.UserOrGroupId = addRequestShareContactToUser.get(addSubmitterMap.get(aRequestId)); 
                   aRequestShare.AccessLevel = 'Edit';
                   // aRequestShare.RowCause =Schema.Request__Share.RowCause.Submitter__c;  
                   newShareList.add(aRequestShare); 
			}				
			// Additional Contacts
			for (Id aRequestId: addAddContactMap.KeySet() ) {
				   Request__Share aRequestShare = new Request__Share();
                   aRequestShare.ParentId = aRequestId; 
                   aRequestShare.UserOrGroupId = addRequestShareContactToUser.get(addAddContactMap.get(aRequestId)); 
                   aRequestShare.AccessLevel = 'Edit';
                   // aRequestShare.RowCause =Schema.Request__Share.RowCause.AdditionalContact__c;  
                   newShareList.add(aRequestShare); 
			}				
			
			insert newShareList; 

		}	
	

}