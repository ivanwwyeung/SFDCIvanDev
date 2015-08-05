global with sharing class SearchController {

@RemoteAction
global static List<Contact> findContactsByName(string startWith){

        List<Contact> contacts = new List<Contact>();
        
        if ( startWith.contains(',')) {
            //search pattern - LastName*, FirstName*
            
            //eliminate space
            startWith.replace(' ', '');
            string[] argu = startWith.splitByCharacterType();
            string lastName = argu[0]+'%';
            string firstName = argu[2] + '%';
            
            contacts = [
                select id, name, email,
                MailingStreet, MailingCity, MailingState, MailingPostalCode,MailingCountry
                From Contact 
                where LastName like :lastName
                and FirstName like :firstName
                order by Name
                limit 25
            ];
            
            
        } else {
        
            string startWithParam = startWith + '%';

            List<Contact> lastNameContacts = [
                select id, name, email,
                MailingStreet, MailingCity, MailingState, MailingPostalCode,MailingCountry 
                From Contact 
                where LastName like :startWithParam
                order by Name
                limit 25
            ];
            
            
            List<Contact> firstNameContacts = [
                select id, name, email,
                MailingStreet, MailingCity, MailingState, MailingPostalCode,MailingCountry
                From Contact 
                where FirstName like :startWithParam
                order by Name
                limit 25
            ];
            
            if ( firstNameContacts.size() == 0 && lastNameContacts.size() == 0) {
                string containParam = '%' + startWith + '%';
                List<Contact> containContacts = [
                    select id, name, email,
                    MailingStreet, MailingCity, MailingState, MailingPostalCode,MailingCountry
                    From Contact 
                    where Name like :containParam 
                    order by Name
                    limit 25
                ];
                contacts.addAll(containContacts);
            } else {
                contacts.addAll(firstNameContacts);
                contacts.addAll(lastNameContacts);
            }

    	}
    
    
    // default values    
       for(contact c : Contacts){
            if (c.email == null) c.email = '';
            if (c.MailingStreet == null ) c.MailingStreet = '';
            if (c.MailingCity == null ) c.MailingCity = '';
            if (c.MailingState == null ) c.MailingState = '';
            if (c.MailingPostalCode == null ) c.MailingPostalCode = '';
            if (c.MailingCountry == null ) c.MailingCountry = '';
             
        }
        
        for (Contact aContact: contacts){
        	system.debug('retreived contact: ' + aContact.Name ); 
        }
        return contacts;
             
    }
	

}