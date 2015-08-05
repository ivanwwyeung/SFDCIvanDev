public class ConnectionHelper {

/* Note:

salesforce to salesforce overview
http://help.salesforce.com/HTViewHelpDoc?id=business_network_enabling.htm&language=en_US



When you enable Salesforce to Salesforce, a new user named “Connection User” is created. This user does not count towards the number of used licenses for your organization, and is not included in any user management view.
When your business partner updates a shared record, the Last Modified By field on the record in your organization displays Connection User, allowing you to easily track all changes made by your business partners.
The Connection User is automatically assigned to the Partner Network profile. The Partner Network profile cannot be modified and is not included in any profile management view.

*/ 

    public static Id getConnectionId(String connectionName) {
    
    	// note: If the organization does not have Salesforce to Salesforce enabled, the PartnerNetworkConnection object is not available, and you can’t access it via the API.
    	
        List<PartnerNetworkConnection> partnerNetConList =
           [Select Id from PartnerNetworkConnection where connectionStatus = 
           'Accepted' and connectionName =:connectionName];
        
        if ( partnerNetConList.size() != 0 ) {
            return partnerNetConList.get(0).Id;
        }
        
        return null;
    }
    
    public static Id getConnectionOwnerId(String connectionName) {
    
        List<PartnerNetworkConnection> partnerNetConList = 
          [Select createdById from PartnerNetworkConnection where connectionStatus = 'Accepted' 
          and connectionName = :connectionName];
        
        if ( partnerNetConList.size() != 0 ) {
            return partnerNetConList.get(0).createdById;
        }
        
        return null;
    }
}