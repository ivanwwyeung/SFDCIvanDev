public class exAccountContactController {

public Id selectedAccount { get; set; }
public List <Contact> contactsInformation {get; set;} 

   public List <Account> getMyAccounts() {
   return [SELECT Id, Name, AccountNumber FROM Account ORDER BY LastModifiedDate DESC LIMIT 10];
}

public void accountClicked() {
    contactsInformation = [SELECT FirstName, LastName FROM Contact]; 
}

}