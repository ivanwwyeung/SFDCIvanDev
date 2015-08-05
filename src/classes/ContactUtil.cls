public without sharing class ContactUtil {    
    // a collection of methods for Contact related functions
    // Author: IY
    // Date: 2013-12-02

   public static void InsertPartnerContact(List<Contact> listContacts, Id networkId ) {

      if (listContacts != null && listContacts.isEmpty() == false) {
     
           
        Set<Id> localContactAccountSet = new Set<Id>(); 
        List<Contact> localContacts = new List<Contact>(); 
        Set<Id> sharedAccountSet = new Set<Id>();    
      
        // only share records created in this org, do not add contacts received from another org.
        // ConnectionReceivedId- ID of the PartnerNetworkConnection that shared this record with your organization. This field is only available if you have enabled Salesforce to Salesforce. 
        for (Contact newContact : listContacts) { 
            if (newContact.ConnectionReceivedId == null && newContact.AccountId != null) { 
                localContactAccountSet.add(newContact.AccountId); 
                localContacts.add(newContact); 
            }         
        } 
      
       System.Debug('# of Local Contact Account : ' + localContactAccountSet.size() );
       System.Debug('# of Local Contact  : ' + localContacts.size() );
              
        if (localContactAccountSet.size() > 0) { 
            // Get the contact account's partner network record connections 
            for (PartnerNetworkRecordConnection accountSharingRecord:  
                                      [SELECT p.Status, p.LocalRecordId, p.ConnectionId 
                                       FROM PartnerNetworkRecordConnection p              
                                       WHERE p.LocalRecordId IN :localContactAccountSet]) { 
                      
                // for each partner connection record for contact's account, check if it is active 
                if ((accountSharingRecord.status.equalsignorecase('Sent') 
                  || accountSharingRecord.status.equalsignorecase('Received')) 
                  && (accountSharingRecord.ConnectionId == networkId)) { 
                    sharedAccountSet.add(accountSharingRecord.LocalRecordId); 
                }               
            } 
                
            if (sharedAccountSet.size() > 0) { 
                List<PartnerNetworkRecordConnection> contactConnections =  new  List<PartnerNetworkRecordConnection>(); 
                
                for (Contact newContact : localContacts) { 
      
                    if (sharedAccountSet.contains(newContact.AccountId)) { 
                       

              // When you create a PartnerNetworkRecordConnection, you forward a record to a connection.Note
              // Attempting to forward a record from an object to which the connection is not subscribed results in an Invalid Partner Network Status error.
              // Note: Don’t forward a record to the connection that originally shared it. 
              //       Doing so causes errors when Apex triggers run.

                      PartnerNetworkRecordConnection newConnection = 
                        new PartnerNetworkRecordConnection( 
                            ConnectionId = networkId, 
                            LocalRecordId = newContact.Id, 
                            SendClosedTasks = false, 
                            SendOpenTasks = false, 
                            SendEmails = false, 
                            ParentRecordId = newContact.AccountId); 
                            
                      contactConnections.add(newConnection); 
                    
                    } 
                } 
      
                if (contactConnections.size() > 0 ) { 
                       database.insert(contactConnections); 
                } 
            } 
        } // localContactAccountSet
        
      }  // listContacts

  }  // SetAccountLookup

 
}